@setlocal
@rem 
@rem  This script is a mini-installer for TDM's GCC port for mingw32 platform
@rem  to build Octave for windows using msys/mingw
@rem
@rem  It currently installs GCC version 4.3.0-2.
@rem
@rem  It requires at least windows 2000 and cmd.exe with extensions enabled.
@rem
@rem  To work, this script requires that you downloaded all files listed in
@rem  mingw32/mingw32-gcc-tdm-url.txt into the directory mingw32/ (or whatever 
@rem  SRC is set to below). To download you can use wget.exe. Win32 binaries 
@rem  of wget are available e.g. from http://users.ugent.be/~bpuype/wget/.
@rem  To download, chdir to minwg32/ and issue
@rem    wget -N -i mingw32-gcc-tdm-url.txt
@rem
@rem  Furthermore, it requires a native win32 version of bsdtar.exe (libarchive)
@rem  available in your PATH.
@rem  You can get it e.g. from the gnuwin32 project at
@rem  http://gnuwin32.sourceforge.net
@rem
@rem  For a minimal install, download
@rem    http://downloads.sourceforge.net/gnuwin32/libarchive-2.4.12-1-bin.zip
@rem    http://downloads.sourceforge.net/gnuwin32/libarchive-2.4.12-1-dep.zip
@rem  and extract the files 
@rem    bzip2.dll
@rem    zilb.dll
@rem  from libarchive-2.4.12-1-dep.zip, and
@rem    bsdtar.exe
@rem    libarchive2.dll
@rem  from libarchive-2.4.12-1-bin.zip to a location available in PATH.
@rem
@rem  Then simply execute this script, and specify the target location where
@rem  to install GCC, e.g.
@rem    c:\build\octave\mingw32
@rem  If the directory does not exist, it will be created.
@rem
@rem  This script is not foolproof, and not designed to do error-checking.
@rem  Thus it is wise to check the output and look of errors are reported.
@rem
@rem  15-Oct-2009 Benjamin Lindner <lindnerb@users.sourceforge.net>
@rem
@rem  CHANGELOG:
@rem  =========
@rem
@rem   15-oct-2009  Benjamin Lindner <lindnerb@users.sourceforge.net>
@rem   
@rem     * update documentation text above
@rem     * update mingwrt and mingw32-make 
@rem     * reorganize and comment script code
@rem


@rem   == BEGIN CONFIGURATION SECTION ==

@rem
@rem  Directory where MINGW32 GCC archives are located
@rem
SET SRCDIR=mingw32\

@rem  == END CONFIGURAION SECTION ==

@rem 
@rem If the user did not specify installation directory, ask user
@rem
if "%1/"=="/" (
   call :askuser 
) else (
   SET DST=%~1
)

@rem
@rem  If directory does not exist, try to create it
@rem
IF NOT EXIST "%DST%" MKDIR "%DST%"

@rem
@rem  If creation failed, then issue error and exit
@rem
IF NOT EXIST "%DST%" goto :errorcreatingdst

@rem
@rem  BSDTAR required to extract GCC
@rem
SET W32TAR=bsdtar
SET W32TAROPT=-x -C "%DST%" 


SET GCCVER=4.3.0
SET GCCREL=2
SET GCCVEND=tdm
SET GCCSYS=dw2

@rem extract GCC
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-%GCCVER%-%GCCVEND%-%GCCREL%-%GCCSYS%-core.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-%GCCVER%-%GCCVEND%-%GCCREL%-%GCCSYS%-fortran.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-%GCCVER%-%GCCVEND%-%GCCREL%-%GCCSYS%-g++.tar.gz"

@rem extract mingw utils required
%W32TAR% %W32TAROPT% -f "%SRCDIR%binutils-2.19.1-mingw32-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%make-3.81-20090911-mingw32-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%mingwrt-3.16-mingw32-dll.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%mingwrt-3.16-mingw32-dev.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%mingw-utils-0.3.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%w32api-3.13-mingw32-dev.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gdb-6.8-mingw-3.tar.bz2"

@rem
@rem make sure gcc executables follow the naming convention
@rem   mingw32-gcc-VER-SYS.exe
@rem
copy "%DST%\bin\mingw32-g++-%GCCSYS%.exe"      "%DST%\bin\mingw32-g++-%GCCVER%-%GCCSYS%.exe"
copy "%DST%\bin\mingw32-gfortran-%GCCSYS%.exe" "%DST%\bin\mingw32-gfortran-%GCCVER%-%GCCSYS%.exe"
copy "%DST%\bin\mingw32-c++-%GCCSYS%.exe"      "%DST%\bin\mingw32-c++-%GCCVER%-%GCCSYS%.exe"
copy "%DST%\bin\cpp-%GCCSYS%.exe"              "%DST%\bin\mingw32-cpp-%GCCVER%-%GCCSYS%.exe"

@rem  remove duplicate executables with short names
del /q "%DST%\bin\cpp-%GCCSYS%.exe"
del /q "%DST%\bin\gcc-%GCCSYS%.exe"
del /q "%DST%\bin\g++-%GCCSYS%.exe"
del /q "%DST%\bin\c++-%GCCSYS%.exe"
del /q "%DST%\bin\gfortran-%GCCSYS%.exe"

del /q "%DST%\bin\mingw32-g++-%GCCSYS%.exe"
del /q "%DST%\bin\mingw32-gfortran-%GCCSYS%.exe"
del /q "%DST%\bin\mingw32-c++-%GCCSYS%.exe"
del /q "%DST%\bin\mingw32-gcc-%GCCSYS%.exe"

del /q "%DST%\._.DS_store"
del /q "%DST%\.DS_store"

@rem 
@rem remove debugging symbols from binutils executables
@rem and GCC runtime libraries
@rem just a matter of size...

set STRIP=%DST%\bin\strip.exe
set STRIP_FLAGS=--strip-unneeded

"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libgcc_tdm_%GCCSYS%_1.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libstdc++_tdm_%GCCSYS%_1.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\pthreadGC2.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\pthreadGCE2_%GCCSYS%.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\exchndl.dll"

for %%a in ("%DST%\bin\*.exe") DO "%STRIP%" %STRIP_FLAGS% "%%a"

goto :end

:usage
@echo USAGE %0 ^<TARGET-DIRECTORY^>
@echo.
goto :end

:errorcreatingdst
@echo.
@echo ERROR: The target directory ^<%DST%^> could not be created!
@echo.
goto :end

:emptydst
@echo You did not specify an installation directory!
goto :EOF

:askuser
SET /P DST=Path to install MINGW32 GCC to: 
if %DST%/==/ goto :emptydst
goto :eof

:end

