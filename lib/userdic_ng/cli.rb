#!/usr/bin/env ruby
# coding: utf-8
#
#  Copyright (C) 2017 Noriaki TANAKA (dtana@startide.jp)
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
#  02111-1307, USA.
#
# $Id: userdic.rb,v 1.34 2017/01/21 08:50:09 dtana Exp $
#
require 'optparse'
require 'rexml/document'

require_relative 'version'
require_relative 'hinshi'
require_relative 'record'
require_relative 'kana_normalizer'
require_relative 'hinshi_map'
require_relative 'apple_plist'
require_relative 'encoding_io'
require_relative 'formats'
require_relative 'converter'

module UserdicNg
  class CLI
    USAGE = <<~TEXT.freeze
      Usage: userdic-ng [--input-encoding ENCODING] [--output-encoding ENCODING] <from> <to> < input > output
             from, to = mozc, google, anthy, canna, atok, msime, wnn, apple, generic
    TEXT

    class << self
      def run(argv, stdout: STDOUT, stderr: STDERR)
        options = parse_options(argv, stdout: stdout, stderr: stderr)
        return 0 if options[:show_version]

        return usage(stderr) unless argv.size == 2

        from_type, to_type = argv
        validate_input_options!(from_type, to_type, options, stderr: stderr)

        converter = Converter.new
        records = converter.load(from_type, input_encoding: options[:input_encoding], warn_io: stderr)
        converter.save(records, to_type, output_encoding: options[:output_encoding], output: stdout)
        0
      end

      private

      def parse_options(argv, stdout:, stderr:)
        options = {}
        parser = OptionParser.new do |opts|
          opts.on('--input-encoding ENCODING') { |value| options[:input_encoding] = EncodingIO.validate!(value) }
          opts.on('--output-encoding ENCODING') { |value| options[:output_encoding] = EncodingIO.validate!(value) }
          opts.on('--version') do
            stdout.puts VERSION
            options[:show_version] = true
          end
        end
        parser.order!(argv)
        options
      rescue ArgumentError => e
        stderr.printf "userdic-ng: error: %s\n", e.message
        exit 1
      rescue OptionParser::ParseError => e
        stderr.printf "userdic-ng: error: %s\n", e.message
        exit usage(stderr)
      end

      def usage(stderr)
        stderr.print USAGE
        1
      end

      def validate_input_options!(from_type, to_type, options, stderr:)
        if from_type == 'apple' && options[:input_encoding]
          stderr.printf "userdic-ng: error: --input-encoding is not supported with apple input\n"
          exit 1
        end
        return unless to_type == 'apple' && options[:output_encoding]

        stderr.printf "userdic-ng: error: --output-encoding is not supported with apple output\n"
        exit 1
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  exit UserdicNg::CLI.run(ARGV.dup)
end
