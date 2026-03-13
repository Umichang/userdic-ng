#!/usr/bin/env ruby
# coding: utf-8

require 'minitest/autorun'
require 'open3'
require 'shellwords'

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
end
