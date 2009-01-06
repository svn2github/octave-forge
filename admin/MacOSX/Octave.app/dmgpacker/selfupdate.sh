#!/bin/sh
# Copyright (C) 2007, Thomas Treichl and Paul Kienzle
# Copyright (C) 2008, Thomas Treichl
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

# Cf. the manpage of bash: "set -e" exits the script immediately if a
# simple command exits with a non-zero status. "set -u" treats unset
# variables as an error. "set -v" print shell input lines as they are
# read.
set -euv

# USAGE:
#   Put this script into the root directory of your Octave sources.
#
#   Before you start this script by a call of './selfupdate.sh' make
#   sure that you don't use Apple's original programs 'sed', 'awk',
#   'aclocal', 'automake', 'bison' and 'flex' anymore. Download these
#   latest GNU tools from the GNU website and install them anywhere on
#   your system where they can be found (eg. in /usr/local/bin, make
#   sure that you set the $PATH environment variable correctly
#   below). On my system this looks like
#
#       bash ~$ which {sed,awk,aclocal,automake,bison,flex}
#       /usr/local/bin/sed
#       /usr/local/bin/awk
#       /usr/local/bin/aclocal
#       /usr/local/bin/automake
#       /usr/local/bin/bison
#       /usr/local/bin/flex
#       /usr/local/bin/sed
#
#   Change the version number in the file src/version.h to that
#   version number of the current Octave.app that should be
#   updated. Then modify the following APPPATH variable for your
#   needs (the absolut path including Octave.app that should be
#   updated).
APPPATH=/Applications/Octave.app

# Don't change one of the following four lines. These lines are used
# internally here and are already set up correctly if APPPATH is set
# up correctly.
PRFPATH=${APPPATH}/Contents/Resources
INCPATH=${PRFPATH}/include
LIBPATH=${PRFPATH}/lib
BINPATH=${PRFPATH}/bin

# Add the option -ggdb to CFLAGS, CPPFLAGS and CXXFLAGS if you want to
# create a debug version of Octave by adding -ggdb to OPTFLAGS.
ARCH="-arch i386"
OPTFLAGS="-O3 -fforce-addr -march=i686 -mfpmath=sse,387 -mieee-fp \
-msse3 -msse2 -msse -mmmx -ggdb"

# Here are the optimization flags that can be used on a PPC platform
# ARCH="-arch ppc"
# OPTFLAGS="-O3 -mpowerpc -faltivec -maltivec -mabi=altivec"

# The MacOSX deployment target must be set to 10.4 for PPC and i386
export MACOSX_DEPLOYMENT_TARGET=10.4

# The compiler directives
GCC="gcc ${ARCH} ${OPTFLAGS}"
CPP="gcc ${ARCH} -E"
CXX="g++ ${ARCH} ${OPTFLAGS}"

# The compiler flags
CFLAGS="-isysroot /Developer/SDKs/MacOSX10.4u.sdk -I/usr/X11R6/include \
-I${INCPATH} -I${INCPATH}/curl -I${INCPATH}/readline -I${INCPATH}/freetype \
-I${INCPATH}/GraphicsMagick" 
CPPFLAGS="${CFLAGS}"
CXXFLAGS="${CFLAGS}"
LDFLAGS="-L${LIBPATH} -L${LIBPATH}/pkgconfig -Wl,-headerpad_max_install_names \
-Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.4u.sdk"
# LDFLAGS="-L${LIBPATH} -L${LIBPATH}/pkgconfig -Wl,-headerpad_max_install_names \
# -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.4u.sdk -Xlinker -m"

# Note: another architecture flag here, change this if you are running
# a Mac OS X on the PPC platform
F77="fort77 ${OPTFLAGS}"
FLIBS="-L${LIBPATH} -lf2c"
FFLAGS="${OPTFLAGS} -I${INCPATH} -Wc,-arch -Wc,i386 \
-Wc,-isysroot -Wc,/Developer/SDKs/MacOSX10.4u.sdk"

# This is just used to display the right message at startup of
# Octave.app, for PPC use EXTRACONF="--host=i386-apple-darwin7.9.1"
EXTRACONF="--host=i386-apple-darwin8.9.1"

# I have installed the GNU tools in /usr/local/bin, that's why I need
# to use this path. I use f2c from the current Octave.app, that's why
# I add ${PRFPATH}/bin to the current path.
export PATH=${BINPATH}:/usr/local/bin:${PATH}  
export DYLD_LIBRARY_PATH=${LIBPATH}

# Use another file for output while './configure' and 'make' and
# 'make install', eg. MSGFILE=/tmp/mymessages.log
MSGFILE=/tmp/messages.log # /dev/stdout 

# Rebuild the './configure' script with './autogen.sh' to make sure
# that we have the latest changes available.
./autogen.sh >>${MSGFILE} 2>&1
eval "./configure CC=\"${GCC}\" CPP=\"${CPP}\" CXX=\"${CXX}\" \
  F77=\"${F77}\" FLIBS=\"${FLIBS}\" FFLAGS=\"${FFLAGS}\" \
  CFLAGS=\"${CFLAGS}\" CPPFLAGS=\"${CPPFLAGS}\" CXXFLAGS=\"${CXXFLAGS}\" \
  LDFLAGS=\"${LDFLAGS}\" --prefix=${PRFPATH} --enable-shared >>${MSGFILE} 2>&1"
make >>${MSGFILE} 2>&1

# This is the point of *no return*: If something goes wrong in the
# following six lines then your new Octave.app may be definitely be
# broken. We need to store the startup scripts of Octave.app with the
# following two lines because they will be overwritten.
mv ${PRFPATH}/bin/octave ${PRFPATH}/bin/_octave
mv ${PRFPATH}/bin/mkoctfile ${PRFPATH}/bin/_mkoctfile

# Cleanup as much as possible of the current Octave.app and install
# the new binaries.
make uninstall >>${MSGFILE} 2>&1
make install >>${MSGFILE} 2>&1

# Replace the new created startup scripts that have been installed
# with the old startup scripts of Octave.app - keep the _* files.
mv ${PRFPATH}/bin/_octave ${PRFPATH}/bin/octave
mv ${PRFPATH}/bin/_mkoctfile ${PRFPATH}/bin/mkoctfile

# Let's run make check at the end of the installation process to have
# a look how many of the tests succeed.
make check >>${MSGFILE} 2>&1
