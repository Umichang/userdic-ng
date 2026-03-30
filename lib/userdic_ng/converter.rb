# coding: utf-8

module UserdicNg
  class Converter
    def initialize(hinshi_map: HinshiMap.new)
      @hinshi_map = hinshi_map
    end

    def load(type, input_encoding: nil, input: STDIN, warn_io: STDERR)
      lines = EncodingIO.read_lines(io: input, input_encoding: input_encoding)
      Formats.parse_lines(type, lines, hinshi_map: @hinshi_map, warn_io: warn_io)
    end

    def save(records, type, output_encoding: nil, output: STDOUT)
      Formats.serialize_records(type, records, hinshi_map: @hinshi_map, output_encoding: output_encoding, io: output)
    end
  end
end
