# coding: utf-8

module UserdicNg
  module ApplePlist
    module_function

    def encode(records)
      lines = ['<?xml version="1.0" encoding="UTF-8"?>' \
               '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" ' \
               '"http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
               '<plist version="1.0"><array>']
      records.each do |record|
        lines << "<dict>\n" \
                 "<key>phrase</key>\n" \
                 "<string>#{record.word}</string>\n" \
                 "<key>shortcut</key>\n" \
                 "<string>#{record.pron}</string>\n" \
                 "</dict>\n"
      end
      lines + ['</array></plist>']
    end

    def decode(lines)
      data = lines.join
      records = []
      doc = REXML::Document.new(data)
      doc.elements.each('plist/array/dict') do |element|
        word = element.elements['string[1]'].text
        pron = element.elements['string[2]'].text
        records << Record.new(pron, word, '名詞')
      end
      records
    end
  end
end
