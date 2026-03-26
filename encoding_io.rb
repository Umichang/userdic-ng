# coding: utf-8

module UserdicNg
  module EncodingIO
    DEFAULT_INPUT_ENCODINGS = ['UTF-16', 'CP932', 'EUC-JP', 'UTF-8'].freeze

    module_function

    def validate!(name)
      Encoding.find(name)
    rescue ArgumentError
      raise ArgumentError, "unknown encoding: #{name}"
    end

    def read_lines(io: STDIN, input_encoding: nil)
      io.binmode
      data = io.read
      decoded = if input_encoding
                  decode(data, input_encoding)
                else
                  detect_and_decode(data)
                end
      decoded.split("\n")
    end

    def write_lines(lines, output_encoding, io: STDOUT)
      case output_encoding
      when 'UTF-16'
        io.binmode
        io.printf "\xff\xfe"
        lines.each { |line| io.write("#{line}\n".encode('UTF-16LE')) }
      else
        lines.each { |line| io.write("#{line}\n".encode(output_encoding, undef: :replace)) }
      end
    end

    def default_output_encoding(type)
      case type
      when 'msime', 'atok'
        'UTF-16'
      when 'wnn', 'canna'
        'EUC-JP'
      else
        'UTF-8'
      end
    end

    def decode(data, input_encoding)
      data.encode('UTF-8', input_encoding)
    rescue EncodingError => e
      raise EncodingError, "failed to decode input as #{input_encoding}: #{e.message}"
    end

    def detect_and_decode(data)
      DEFAULT_INPUT_ENCODINGS.each do |encoding|
        begin
          return data.encode('UTF-8', encoding)
        rescue StandardError
          next
        end
      end
      ''
    end
  end
end
