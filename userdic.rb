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
require 'rexml/document'

require './hinshi.rb'
require './normkana.rb'

def usage
    STDERR.printf "Usage: userdic <from> <to> < input > output\n"
    STDERR.printf "       from, to = mozc, google, anthy, canna, "
    STDERR.printf "atok, msime, wnn, apple, generic\n"
    exit 1
end

def getr(type, s)
    s.strip!
    return nil if (s == '' || s =~ /^!/ || s[0] == "\\")
    case type
    when 'generic', 'mozc', 'msime', 'wnn'
        pron, word, prop = s.split(/\t+/)
        prop_ = $hinshi_f[type][prop]
    when 'google'
        return getr('mozc', s)
    when 'atok'
        s.gsub!(/[､,]/, "\t") if s !~ /\t/
        pron, word, prop = s.split(/\t+/)
        pron = pron.norm_kana
        prop = prop.gsub(/\*$/, '') if prop
        prop_ = $hinshi_f[type][prop]
    when 'anthy'
        pron, prop, word = s.split
        prop = prop.gsub('#', '').gsub(/\*.*$/, '')
        prop_ = $hinshi_f[type][prop]
    when 'canna'
        return getr('anthy', s)
    when 'apple'
        pron, word = s.split(/\t+/)
        prop_ = '名詞'
    else
        STDERR.printf "%s: not supported yet\n", type
        usage
    end
    if word == nil
        STDERR.printf "%s: incorrect record\n", s
        return nil
    end
    if prop_ == nil
        STDERR.printf "%s: Unknown 品詞: %s\n", s, prop
        prop_ = '名詞'
    end
    sprintf "%s\t%s\t%s", pron, word, prop_
end

def putr(type, s)
    return nil if s == nil
    pron, word, prop = s.split(/\t+/)
    case type
    when 'generic', 'mozc', 'atok', 'msime', 'wnn'
        prop = $hinshi_t[type][prop]
        r = sprintf "%s\t%s\t%s", pron, word, prop
    when 'apple'
        r = sprintf "%s\t%s", pron, word
    when 'anthy'
        prop = $hinshi_t[type][prop]
        r = sprintf "%s #%s*500 %s", pron, prop, word
    when 'google'
        return putr('mozc', s)
    when 'canna'
        return putr('anthy', s)
    else
        STDERR.printf "%s: not supported yet\n", type
        usage
    end
    r
end

def puth(type, n)
    case type
    when 'msime'
        return "!Microsoft IME Dictionary Tool"
    when 'atok'
        return "!!ATOK_TANGO_TEXT_HEADER_1"
    when 'wnn'
        return sprintf("\\comment \n\\total %d\n\n", n)
    end
    nil
end

class Array
    def save_with_en(en, f = STDOUT)
        case en
        when 'UTF-16'
            f.binmode
            f.printf "\xff\xfe"
            self.each {|s| f.write (s + "\n").encode('UTF-16LE')}
        else
            self.each {|s| f.puts s.encode(en, :undef => :replace)}
        end
    end
    def encoding(type)
        case type
        when 'msime', 'atok'
            e = 'UTF-16'
        when 'wnn', 'canna'
            e = 'EUC-JP'
        else
            e = 'UTF-8'
        end
        e
    end
    def save(type)
        r = [puth(type, self.size)]
        r += self.map do |s|
            putr(type, s)
        end
        r.delete(nil)
        r = r.encode_plist if type == 'apple'
        r.save_with_en(encoding(type))
    end

    def encode_plist
        r = ['<?xml version="1.0" encoding="UTF-8"?>' +
             '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" ' +
             '"http://www.apple.com/DTDs/PropertyList-1.0.dtd">' +
             '<plist version="1.0"><array>']
        self.each do |s|
            pron, word = s.split(/\t+/)
            t =  "<dict>\n"
            t += "<key>phrase</key>\n"
            t += sprintf("<string>%s</string>\n", word)
            t += "<key>shortcut</key>\n"
            t += sprintf("<string>%s</string>\n", pron)
            t += "</dict>\n"
            r << t
        end
        r + ['</array></plist>']
    end
    def decode_plist
        data = ''
        self.each {|s| data += s}
        r = []
        doc = REXML::Document.new(data)
        doc.elements.each('plist/array/dict') do |e|
            word = e.elements['string[1]'].text
            pron = e.elements['string[2]'].text
            r << pron + "\t" + word
        end
        r
    end
end

def load_with_en(f = STDIN)
    f.binmode
    r = f.read
    t = ''
    ['UTF-16', 'CP932', 'EUC-JP', 'UTF-8'].each do |en|
        begin
            t = r.encode('UTF-8', en)
        rescue
            # STDERR.printf "%s: invalid encoding\n", en
            next
        end
        # STDERR.puts en
        break
    end
    t.split("\n")
end

def load(type)
    t = load_with_en
    t = t.decode_plist if type == 'apple'
    r = t.map do |s|
        getr(type, s)
    end
    r.delete(nil)
    r
end

def expand_require(path)
    r = []
    open(path).each do |s|
        c, a = s.split
        if c == 'require' && a =~ /\'\./
            p = a[1,a.size - 2]
            r += expand_require(p)
        else
            r << s
        end
    end
    r
end

if ARGV[0] == 'build'
    expand_require('userdic.rb').each {|s| puts s}
    exit
end
usage if ARGV.size != 2
load(ARGV[0]).save(ARGV[1])
