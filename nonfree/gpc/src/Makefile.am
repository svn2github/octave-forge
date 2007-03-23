## Makefile.am for Octave-GPC
##
## Copyright (C) 2001, 2004, 2006  Rafael Laboissiere
##
## This file is part of Octave-GPC
##
## Octave-GPC is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave-GPC is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave-GPC; see the file COPYING.  If not, write to the
## Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.


octdir = $(OCTDIR)/gpc

linked_oct_files = \
  gpc_clip.oct \
  gpc_write.oct \
  gpc_read.oct \
  gpc_get.oct \
  gpc_tristrip.oct \
  gpc_is_polygon.oct

oct_SCRIPTS = \
  $(linked_oct_files) \
  gpc_create.oct

m_scriptdir = $(MDIR)/gpc

m_script_DATA = gpc_plot.m

CCFILES = \
  $(oct_SCRIPTS:.oct=.cc) \
  octave-gpc.cc

OBJFILES = $(CCFILES:.cc=.o)

EXTRA_DIST = \
  bootstrap.sh \
  gpc_plot.m \
  $(CCFILES) \
  octave-gpc.h \
  INDEX

%.o: %.cc octave-gpc.h
	$(MKOCTFILE) -v -s -c $<

gpc_create.oct: $(OBJFILES)
	$(MKOCTFILE) -v -s -lgpcl -o $@ $^

%.oct: gpc_create.oct
	ln -sf $< $@

CLEANFILES = *.oct *.o *core

.PHONY: clean
