#!/bin/sh
# Copyright (C) 2007, Thomas Treichl and Paul Kienzle
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 USA

### DON'T USE THIS SCRIPT - IT IS CURRENTLY UNDER DEVELOPMENT. ###
###                YOU MAY CRASH YOUR OCTAVE.APP.              ###

# Check the ./configure script and comment out the 'sed lines' if the
# local installed sed from /usr/local/bin is used. Change the version
# number in src/version.h to 2.9.12 instead of 2.9.12+.

APPPATH=~/tmp/octave.app

PRFPATH=${APPPATH}/Contents/Resources
INCPATH=${PRFPATH}/include
LIBPATH=${PRFPATH}/lib

CFLAGS="-I${INCPATH} -I${INCPATH}/curl -I${INCPATH}/readline" 
CPPFLAGS="${CFLAGS}"
CXXFLAGS="${CFLAGS}"
LDFLAGS="-L${LIBPATH} -L${LIBPATH}/pkgconfig"

export PATH=/usr/local/bin:${PRFPATH}/bin:$PATH
export DYLD_LIBRARY_PATH=${LIBPATH}

mv ${PRFPATH}/bin/octave ${PRFPATH}/bin/_octave
mv ${PRFPATH}/bin/mkoctfile ${PRFPATH}/bin/_mkoctfile

# ./autogen.sh
# eval "./configure CFLAGS=\"${CFLAGS}\" CPPFLAGS=\"${CPPFLAGS}\" CXXFLAGS=\"${CXXFLAGS}\" LDFLAGS=\"${LDFLAGS}\" --prefix=${PRFPATH} --enable-shared --with-f2c"

make -j 2
make uninstall
make install 

mv ${PRFPATH}/bin/_octave ${PRFPATH}/bin/octave
mv ${PRFPATH}/bin/_mkoctfile ${PRFPATH}/bin/mkoctfile
