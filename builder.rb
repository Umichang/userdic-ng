# coding: utf-8

module UserdicNg
  module Builder
    module_function

    def expand_require(path)
      lines = []
      File.open(path).each do |line|
        command, argument = line.split
        if command == 'require' && argument =~ /'\./
          child_path = argument[1, argument.size - 2]
          lines.concat(expand_require(child_path))
        else
          lines << line
        end
      end
      lines
    end
  end
end
