## Copyright (C) 2006   Torsten Finke   <fi@igh-essen.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# $Revision$
# $Date$
# $RCSfile$

PART = partition.oct
HDR = partition.h
OCT = partcnt.oct partint.oct
SRC := $(OCT:.oct=.cc)
BASE := $(OCT:.oct=)

.phony: all
all: $(OCT)

$(OCT): $(PART)
	$(RM) $@
	ln -s $< $@

%.oct: %.cc $(HDR)
	mkoctfile -s $<

.phony: test
test: $(BASE)
	for i in $^; do echo "test $$i"; done | octave --silent

.phony: clean
clean: 
	$(RM) $(PART) *.o *.oct octave-core *~