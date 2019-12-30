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
# $Id: mkhinshi.rb,v 1.9 2017/01/17 11:19:53 dtana Exp $
#
def load_data(path = nil)
    f = path ? open(path) : STDIN
    t = f.map do |s|
        (s =~ /^#/ || s.strip == '') ? nil : s
    end
    t.delete(nil)
    t
end

class Array
    def make_hash(fn, tn)
        f = {}
        self.each do |s|
            r = s.split
            next if r[fn][0] == '*'
            fw = r[fn].gsub(/^\*/, '').gsub(/\/.*$/, '')
            tw = r[tn].gsub(/^\*/, '').gsub(/\/.*$/, '')
            f[fw] = tw
        end
        f
    end
end

t = load_data
hinshi_f = {}
hinshi_t = {}
['generic', 'mozc', 'anthy', 'atok', 'msime', 'wnn'].each_with_index do |type, n|
    hinshi_f[type] = t.make_hash(n, 0)
    hinshi_t[type] = t.make_hash(0, n)
end
printf "$hinshi_f = "
p hinshi_f
printf "$hinshi_t = "
p hinshi_t
