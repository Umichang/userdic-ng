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

require './hinshi.rb'
require './record.rb'
require './kana_normalizer.rb'
require './hinshi_map.rb'
require './apple_plist.rb'
require './encoding_io.rb'
require './formats.rb'
require './converter.rb'
require './builder.rb'

USAGE = <<~TEXT.freeze
  Usage: userdic-ng [--input-encoding ENCODING] [--output-encoding ENCODING] <from> <to> < input > output
         from, to = mozc, google, anthy, canna, atok, msime, wnn, apple, generic
TEXT

def usage
  STDERR.print USAGE
  exit 1
end

def validate_input_options!(from_type, to_type, options)
  if from_type == 'apple' && options[:input_encoding]
    STDERR.printf "userdic-ng: error: --input-encoding is not supported with apple input\n"
    exit 1
  end
  if to_type == 'apple' && options[:output_encoding]
    STDERR.printf "userdic-ng: error: --output-encoding is not supported with apple output\n"
    exit 1
  end
end

if ARGV[0] == 'build'
  UserdicNg::Builder.expand_require('userdic.rb').each { |line| puts line }
  exit
end

options = {}
parser = OptionParser.new do |opts|
  opts.on('--input-encoding ENCODING') { |value| options[:input_encoding] = UserdicNg::EncodingIO.validate!(value) }
  opts.on('--output-encoding ENCODING') { |value| options[:output_encoding] = UserdicNg::EncodingIO.validate!(value) }
end

begin
  parser.order!(ARGV)
rescue ArgumentError => e
  STDERR.printf "userdic-ng: error: %s\n", e.message
  exit 1
rescue OptionParser::ParseError => e
  STDERR.printf "userdic-ng: error: %s\n", e.message
  usage
end

usage if ARGV.size != 2

from_type, to_type = ARGV
validate_input_options!(from_type, to_type, options)

converter = UserdicNg::Converter.new
records = converter.load(from_type, input_encoding: options[:input_encoding])
converter.save(records, to_type, output_encoding: options[:output_encoding])
