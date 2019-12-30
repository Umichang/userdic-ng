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
# $Id: Makefile,v 1.17 2017/01/17 11:19:53 dtana Exp $
#
UD_GENERIC = generic.txt
UD_MOZC    = mozc.txt
UD_ANTHY   = private_words_default
UD_ATOK    = atok.txt
UD_MSIME   = msime.txt
UD_APPLE   = apple.plist
BINDIR	   = /usr/local/bin
COMMAND    = userdic
VERSION    = 1.0
DISTDIR    = userdic-${VERSION}

${COMMAND}: userdic.rb hinshi.rb normkana.rb
	./userdic.rb build > $@
	chmod +x $@
hinshi.rb: hinshi mkhinshi.rb
	./mkhinshi.rb < hinshi > $@

mozc:  ${UD_MOZC}
google:${UD_MOZC}
anthy: ${UD_ANTHY}
atok:  ${UD_ATOK}
msime: ${UD_MSIME}
apple: ${UD_APPLE}
${UD_MOZC}:  ${UD_GENERIC} ${COMMAND}
	./${COMMAND} generic mozc  < ${UD_GENERIC} > $@
${UD_ANTHY}: ${UD_GENERIC} ${COMMAND}
	./${COMMAND} generic anthy < ${UD_GENERIC} > $@
${UD_ATOK}:  ${UD_GENERIC} ${COMMAND}
	./${COMMAND} generic atok  < ${UD_GENERIC} > $@
${UD_MSIME}: ${UD_GENERIC} ${COMMAND}
	./${COMMAND} generic msime < ${UD_GENERIC} > $@
${UD_APPLE}: ${UD_GENERIC} ${COMMAND}
	./${COMMAND} generic apple < ${UD_GENERIC} > $@

${UD_GENERIC}:; ln -s ${HOME}/.userdic $@

install:; install -c ${COMMAND} ${BINDIR}
clean:
	rm -rf ${COMMAND} hinshi.rb ${UD_GENERIC} \
	   ${UD_MOZC} ${UD_ANTHY} ${UD_ATOK} ${UD_MSIME} ${UD_APPLE} \
	   ${DISTDIR} ${DISTDIR}.tar.gz
dist: ${COMMAND}
	rm -rf ${DISTDIR}
	mkdir  ${DISTDIR}
	cp -p Makefile userdic.rb mkhinshi.rb COPYING \
	   normkana.rb hinshi ${COMMAND} ${DISTDIR}
	tar czvpf ${DISTDIR}.tar.gz ${DISTDIR}
