#!/usr/bin/env ruby
# coding: utf-8

require 'minitest/autorun'
require 'open3'
require 'shellwords'
require 'tempfile'

class UserdicNgTest < Minitest::Test
  REPO = File.expand_path(__dir__)

  def setup
    hinshi_rb = File.join(REPO, 'hinshi.rb')
    return if File.exist?(hinshi_rb)

    system("cd #{REPO.shellescape} && ./mkhinshi.rb < hinshi > hinshi.rb", exception: true)
  end

  def run_userdic(args, stdin_data = ''.b)
    Open3.capture3('ruby', 'userdic.rb', *args, stdin_data: stdin_data, chdir: REPO, binmode: true)
  end

  def run_built_userdic(args, stdin_data = ''.b)
    Tempfile.create(['userdic-ng-built', '.rb']) do |file|
      stdout, stderr, status = run_userdic(%w[build])
      assert status.success?, stderr
      file.binmode
      file.write(stdout)
      file.flush
      Open3.capture3('ruby', file.path, *args, stdin_data: stdin_data, chdir: REPO, binmode: true)
    end
  end

  def decode_output(bytes, encoding = 'UTF-8')
    bytes.dup.force_encoding(encoding)
  end

  def test_default_fallback_reads_utf8
    stdout, stderr, status = run_userdic(%w[generic generic], "あ\t亜\t名詞\n".b)
    assert status.success?, stderr
    assert_equal "あ\t亜\t名詞\n".b, stdout
  end

  def test_explicit_input_encoding_cp932
    input = "あ\t亜\t名詞\n".encode('CP932')
    stdout, stderr, status = run_userdic(%w[--input-encoding CP932 --output-encoding UTF-8 generic generic], input)
    assert status.success?, stderr
    assert_equal "あ\t亜\t名詞\n".b, stdout
  end

  def test_explicit_output_encoding_utf16le_has_no_bom
    stdout, stderr, status = run_userdic(%w[--output-encoding UTF-16LE generic generic], "あ\t亜\t名詞\n".b)
    assert status.success?, stderr
    refute stdout.start_with?("\xff\xfe".b, "\xfe\xff".b)
    assert_equal "あ\t亜\t名詞\n".encode('UTF-16LE').b, stdout
  end

  def test_invalid_encoding_name_fails
    _stdout, stderr, status = run_userdic(%w[--input-encoding NOT_A_REAL_ENCODING generic generic], "x".b)
    refute status.success?
    assert_includes stderr, 'unknown encoding: NOT_A_REAL_ENCODING'
  end

  def test_apple_input_rejects_input_encoding
    _stdout, stderr, status = run_userdic(%w[--input-encoding UTF-8 apple generic], ''.b)
    refute status.success?
    assert_includes stderr, '--input-encoding is not supported with apple input'
  end

  def test_apple_output_rejects_output_encoding
    _stdout, stderr, status = run_userdic(%w[--output-encoding UTF-8 generic apple], "あ\t亜\t名詞\n".b)
    refute status.success?
    assert_includes stderr, '--output-encoding is not supported with apple output'
  end

  def test_google_matches_mozc_output
    input = "あ\t亜\t名詞\n".b
    mozc_stdout, mozc_stderr, mozc_status = run_userdic(%w[generic mozc], input)
    google_stdout, google_stderr, google_status = run_userdic(%w[generic google], input)

    assert mozc_status.success?, mozc_stderr
    assert google_status.success?, google_stderr
    assert_equal mozc_stdout, google_stdout
  end

  def test_canna_matches_anthy_output
    input = "あ\t亜\t名詞\n".b
    anthy_stdout, anthy_stderr, anthy_status = run_userdic(%w[generic anthy], input)
    canna_stdout, canna_stderr, canna_status = run_userdic(%w[generic canna], input)

    assert anthy_status.success?, anthy_stderr
    assert canna_status.success?, canna_stderr
    assert_equal decode_output(anthy_stdout, 'UTF-8'), decode_output(canna_stdout, 'EUC-JP').encode('UTF-8')
  end

  def test_unknown_part_of_speech_warns_and_falls_back_to_noun
    stdout, stderr, status = run_userdic(%w[mozc generic], "あ\t亜\t未知品詞\n".b)

    assert status.success?, stderr
    assert_includes decode_output(stderr), 'Unknown 品詞: 未知品詞'
    assert_equal "あ\t亜\t名詞\n".b, stdout
  end

  def test_atok_reader_normalizes_kana_and_commas
    input = "ｶﾞｸｾｲ,学生,名詞\n".encode('UTF-8')
    stdout, stderr, status = run_userdic(%w[atok generic], input)

    assert status.success?, stderr
    assert_equal "がくせい\t学生\t名詞\n".b, stdout
  end

  def test_apple_round_trip_preserves_phrase_and_shortcut
    plist = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <array>
          <dict>
            <key>phrase</key>
            <string>亜</string>
            <key>shortcut</key>
            <string>あ</string>
          </dict>
        </array>
      </plist>
    XML

    generic_stdout, generic_stderr, generic_status = run_userdic(%w[apple generic], plist.b)
    assert generic_status.success?, generic_stderr
    assert_equal "あ\t亜\t名詞\n".b, generic_stdout

    apple_stdout, apple_stderr, apple_status = run_userdic(%w[generic apple], "あ\t亜\t名詞\n".b)
    assert apple_status.success?, apple_stderr
    assert_includes decode_output(apple_stdout), '<string>亜</string>'
    assert_includes decode_output(apple_stdout), '<string>あ</string>'
  end

  def test_built_script_matches_runtime_behavior
    stdout, stderr, status = run_built_userdic(%w[generic generic], "あ\t亜\t名詞\n".b)

    assert status.success?, stderr
    assert_equal "あ\t亜\t名詞\n".b, stdout
  end
end
