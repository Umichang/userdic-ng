# coding: utf-8

module UserdicNg
  Record = Struct.new(:pron, :word, :part_of_speech) do
    def to_generic_line
      "#{pron}\t#{word}\t#{part_of_speech}"
    end
  end
end
