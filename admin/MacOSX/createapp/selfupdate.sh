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

########################################################################
# This file is meant for developers only who know how to look at the   #
# one or other problem that might appear when using this script. Write #
# me an email offside any list if you think the script could be        #
# improved in a better way than this. In any case:                     #
# DON'T USE ANY OF THE OCTAVE AND OCTAVE-FORGE MAILING-LISTS TO REPORT #
# ERRORS OR BUGS THAT MAY OCCUR IF THIS SCRIPT FAILS.                  #
########################################################################

# Put this script into the root directory of your Octave sources.
# Before you start this script make sure that you don't use Apple's
# original programs 'sed', 'awk', 'aclocal', 'automake' and 'bison'
# anymore. Download these latest GNU tools from the GNU website and
# install them eg. in /usr/local (make sure that you set the $PATH
# environment variable correctly below). Change the version number in
# the file src/version.h to the version number of the current
# Octave.app that should be replaced. Then modify the following
# APPPATH variable for your needs (the absolut path including
# Octave.app that should be updated).
APPPATH=/Applications/Octave.app

# Don't change one of the following three lines. These lines are used
# internally here and are already set up correctly if APPPATH is set
# up correctly.
PRFPATH=${APPPATH}/Contents/Resources
INCPATH=${PRFPATH}/include
LIBPATH=${PRFPATH}/lib

# Add the option -gdwarf-2 to CFLAGS, CPPFLAGS and CXXFLAGS if you
# want to create a gdb version of Octave.
CFLAGS="-O3 -ftree-vectorize -I${INCPATH} -I${INCPATH}/curl -I${INCPATH}/readline" 
CPPFLAGS="-O3 -ftree-vectorize ${CFLAGS}"
CXXFLAGS="-O3 -ftree-vectorize ${CFLAGS}"
LDFLAGS="-L${LIBPATH} -L${LIBPATH}/pkgconfig"

# I have installed the GNU tools in /usr/local/bin, that's why I need
# to use this path. We use f2c from the current Octave.app, that's why
# we add ${PRFPATH}/bin to the current path.
export PATH=/usr/local/bin:${PRFPATH}/bin:$PATH
export DYLD_LIBRARY_PATH=${LIBPATH}

# Function:    evalfailexit
# Input args:  ${1} is the string that has to be evaluated
# Description: Evaluates the ${1} string prints a message to ${MSGFILE} 
#              and exits with an error number 1 on fail
evalfailexit() {
  if ( ! eval "${1} 2>&1 >>${MSGFILE}" ); then
    echo "selfupdate.sh: Building Octave.app has failed !!!"
    echo "selfupdate.sh: The command that failed was: ${1}"
    exit 1
  fi
}

# Use another file for output while './configure' and 'make' and
# 'make install', eg. MSGFILE=/tmp/mymessages.log
MSGFILE=/dev/stdout 

# Rebuild the './configure' script with './autogen.sh' to make sure
# that we have the latest changes available.
evalfailexit "./autogen.sh"
evalfailexit "./configure CFLAGS=\"${CFLAGS}\" CPPFLAGS=\"${CPPFLAGS}\" \
  CXXFLAGS=\"${CXXFLAGS}\" LDFLAGS=\"${LDFLAGS}\" --prefix=${PRFPATH} \
  --enable-shared --with-f2c"
evalfailexit "make -j 2"

# This is the point of *no return*: If something goes wrong in the
# following six lines then your new Octave.app may be definitely be
# broken. We need to store the startup scripts of Octave.app with the
# following two lines because they will be overwritten.
evalfailexit "mv ${PRFPATH}/bin/octave ${PRFPATH}/bin/_octave"
evalfailexit "mv ${PRFPATH}/bin/mkoctfile ${PRFPATH}/bin/_mkoctfile"

# Cleanup as much as possible of the current Octave.app and install
# the new binaries.
evalfailexit "make uninstall"
evalfailexit "make install"

# Replace the new created startup scripts that have been installed
# with the old startup scripts of Octave.app.
evalfailexit "mv ${PRFPATH}/bin/_octave ${PRFPATH}/bin/octave"
evalfailexit "mv ${PRFPATH}/bin/_mkoctfile ${PRFPATH}/bin/mkoctfile"

# Let's run make check at the end of the installation process to have
# a look how many of the tests succeed.
evalfailexit "make check"