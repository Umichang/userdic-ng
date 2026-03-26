# coding: utf-8

module UserdicNg
  module Formats
    ALIASES = {
      'google' => 'mozc',
      'canna' => 'anthy',
    }.freeze

    module_function

    def canonical_type(type)
      ALIASES.fetch(type, type)
    end

    def parse_lines(type, lines, hinshi_map:, warn_io: STDERR)
      if type == 'apple'
        ApplePlist.decode(lines)
      else
        lines.filter_map do |line|
          parse_line(type, line, hinshi_map: hinshi_map, warn_io: warn_io)
        end
      end
    end

    def parse_line(type, line, hinshi_map:, warn_io: STDERR)
      stripped = line.strip
      return nil if stripped.empty? || stripped.match?(/^!/) || stripped[0] == "\\"

      resolved_type = canonical_type(type)
      record = case resolved_type
               when 'generic', 'mozc', 'msime', 'wnn'
                 pron, word, prop = stripped.split(/\t+/)
                 build_record(pron, word, hinshi_map.from(resolved_type, prop), prop, stripped, warn_io)
               when 'atok'
                 normalized = stripped.include?("\t") ? stripped.dup : stripped.gsub(/[､,]/, "\t")
                 pron, word, prop = normalized.split(/\t+/)
                 prop = prop.gsub(/\*$/, '') if prop
                 build_record(KanaNormalizer.normalize(pron), word, hinshi_map.from(resolved_type, prop), prop, stripped, warn_io)
               when 'anthy'
                 pron, prop, word = stripped.split
                 prop = prop.gsub('#', '').gsub(/\*.*$/, '')
                 build_record(pron, word, hinshi_map.from(resolved_type, prop), prop, stripped, warn_io)
               when 'apple'
                 pron, word = stripped.split(/\t+/)
                 build_record(pron, word, '名詞', nil, stripped, warn_io)
               else
                 raise ArgumentError, "#{type}: not supported yet"
               end
      return nil unless record

      record
    end

    def serialize_records(type, records, hinshi_map:, output_encoding: nil, io: STDOUT)
      lines = if type == 'apple'
                ApplePlist.encode(records)
              else
                build_plain_lines(type, records, hinshi_map)
              end
      encoding = output_encoding || EncodingIO.default_output_encoding(type)
      EncodingIO.write_lines(lines, encoding, io: io)
    end

    def build_plain_lines(type, records, hinshi_map)
      lines = [header_for(type, records.size)]
      lines.concat(records.map { |record| serialize_record(type, record, hinshi_map: hinshi_map) })
      lines.compact
    end

    def serialize_record(type, record, hinshi_map:)
      resolved_type = canonical_type(type)
      case resolved_type
      when 'generic', 'mozc', 'atok', 'msime', 'wnn'
        "#{record.pron}\t#{record.word}\t#{hinshi_map.to(resolved_type, record.part_of_speech)}"
      when 'anthy'
        "#{record.pron} ##{hinshi_map.to(resolved_type, record.part_of_speech)}*500 #{record.word}"
      when 'apple'
        "#{record.pron}\t#{record.word}"
      else
        raise ArgumentError, "#{type}: not supported yet"
      end
    end

    def header_for(type, count)
      case type
      when 'msime'
        '!Microsoft IME Dictionary Tool'
      when 'atok'
        '!!ATOK_TANGO_TEXT_HEADER_1'
      when 'wnn'
        "\\comment \n\\total #{count}\n\n"
      end
    end

    def build_record(pron, word, part_of_speech, source_part_of_speech, original_line, warn_io)
      if word.nil?
        warn_io.printf "%s: incorrect record\n", original_line
        return nil
      end
      if part_of_speech.nil?
        warn_io.printf "%s: Unknown 品詞: %s\n", original_line, source_part_of_speech
        part_of_speech = '名詞'
      end
      Record.new(pron, word, part_of_speech)
    end
  end
end
