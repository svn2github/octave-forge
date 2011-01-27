Octave-mingw64 dependency libraries & tools
===========================================

This directory contains a minimal environment to build libraries and tools
required for building octave (http://www.octave.org) for a x86 and/or x64
windows platform.

MinGW/Msys installer
====================

To build the libraries a proper msys environment is required, along with
a win32/win64 targetted gcc compiler.
The script in msysinstaller/install.cmd acts as a mini-installer which fetches
the necessary msys binaries from the mingw SF project page at 
http://sourceforge.net/project/mingw and installs it to a location specified by
the caller.
Correspondingly, the script in mingwinstaller/install.cmd acts likewise as
mini-installer for the GNU gcc compiler suite from the MinGW project.

Usage
=====

The msys and mingw installer scripts requires that you have the following 
executables *prior* to installing msys/mingw available in your PATH:

  *) basic-bsdtar.exe available from the mingw project at
     http://downloads.sourceforge.net/mingw/basic-bsdtar-2.8.3-1-mingw32-bin.zip
     Download it, unzip, and place in your PATH (or the directory the installer 
     script resides)
     
  *) wget.exe available e.g. from 
     http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe

Call install.cmd and specify the directory you want MSYS installed to.
Preferably use an installation path without spaces.
The MinGW gcc compiler should be then installed into the mingw/ subdirectory
of your MSYS installation root (i.e. if you installed msys into c:\msys, then
you should install gcc into c:\msys\mingw).

== FIXME ==
add dependency build environment instructions

/**
 * DISCLAIMER
 * The files in this directory and subdirectories have no copyright assigned 
 * and are placed in the Public Domain.
 * These files are part of the octave-mingw64 toolchain.
 *
 * The files under this directory and any code is distributed in the hope 
 * that it will be useful but WITHOUT ANY WARRANTY.  ALL WARRANTIES, EXPRESSED 
 * OR IMPLIED ARE HEREBY DISCLAIMED.  This includes but is not limited to 
 * warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */
