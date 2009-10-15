@setlocal
@rem 
@rem  This script is a mini-installer for MinGW32 GCC 
@rem  to build Octave for windows using msys/mingw
@rem
@rem  It currently installs GCC version 4.4.0.
@rem
@rem  It requires at least windows 2000 and cmd.exe with extensions enabled.
@rem
@rem  To work, this script requires that you downloaded all files listed in
@rem  mingw32/mingw32-gcc-url.txt into the directory mingw32/ (or whatever 
@rem  SRC is set to below). To download you can use wget.exe. Win32 binaries 
@rem  of wget are available e.g. from http://users.ugent.be/~bpuype/wget/.
@rem  To download, chdir to minwg32/ and issue
@rem    wget -N -i mingw32-gcc-url.txt
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
@rem  Additionally it requires a win32 version of SED available in your path
@rem  SED binaries are also evailable e.g. from the gnuwin32 project.
@rem  The version of SED must support inplace-editing (via -i).
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
@rem     * creation
@rem     * add bugfix with libstdc++.la file
@rem       http://sourceforge.net/mailarchive/forum.php?thread_name=4A97B057.2040803%40gmail.com&forum_name=mingw-users
@rem     * add a bugfix in libstd++ headers
@rem       SF#2836185 mingw bug tracker
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


SET GCCVER=4.4.0
SET GCCREL=
SET GCCVEND=mingw32
SET GCCSYS=dw2

@rem extract GCC
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-core-%GCCVER%-%GCCVEND%-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-core-%GCCVER%-%GCCVEND%-dll.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-c++-%GCCVER%-%GCCVEND%-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-c++-%GCCVER%-%GCCVEND%-dll.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-fortran-%GCCVER%-%GCCVEND%-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-fortran-%GCCVER%-%GCCVEND%-dll.tar.gz"

@rem extract support libraries
%W32TAR% %W32TAROPT% -f "%SRCDIR%gmp-4.2.4-mingw32-dll.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libiconv-1.13-mingw32-dll-2.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%mpfr-2.4.1-mingw32-dll.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%pthreads-w32-2.8.0-mingw32-dll.tar.gz"

@rem api, migwrt and debugger
%W32TAR% %W32TAROPT% -f "%SRCDIR%w32api-3.13-mingw32-dev.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%mingwrt-3.16-mingw32-dll.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%mingwrt-3.16-mingw32-dev.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gdb-6.8-mingw-3.tar.bz2"

@rem binutils and make
%W32TAR% %W32TAROPT% -f "%SRCDIR%binutils-2.19.1-mingw32-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%make-3.81-20090911-mingw32-bin.tar.gz"

@rem mingw tools
%W32TAR% %W32TAROPT% -f "%SRCDIR%mingw-utils-0.3.tar.gz"

@rem
@rem make sure gcc executables follow the naming convention
@rem   mingw32-gcc-VER-SYS.exe
@rem
copy "%DST%\bin\mingw32-gcc-%GCCVER%.exe"  "%DST%\bin\mingw32-gcc-%GCCVER%-%GCCSYS%.exe"
copy "%DST%\bin\mingw32-g++.exe"           "%DST%\bin\mingw32-g++-%GCCVER%-%GCCSYS%.exe"
copy "%DST%\bin\mingw32-gfortran.exe"      "%DST%\bin\mingw32-gfortran-%GCCVER%-%GCCSYS%.exe"
copy "%DST%\bin\cpp.exe"                   "%DST%\bin\mingw32-cpp-%GCCVER%-%GCCSYS%.exe"

@rem  mingw-c++.exe is a forward wrapper for mingw-g++.exe
copy "%DST%\bin\mingw32-g++-%GCCSYS%.exe"  "%DST%\bin\mingw32-c++-%GCCVER%-%GCCSYS%.exe"

@rem  remove duplicate executables with short names
del /q "%DST%\bin\cpp.exe"
del /q "%DST%\bin\gcc.exe"
del /q "%DST%\bin\g++.exe"
del /q "%DST%\bin\c++.exe"
del /q "%DST%\bin\gfortran.exe"

del /q "%DST%\bin\mingw32-gcc-%GCCVER%.exe"
del /q "%DST%\bin\mingw32-g++.exe"
del /q "%DST%\bin\mingw32-gfortran.exe"
del /q "%DST%\bin\mingw32-c++.exe"
del /q "%DST%\bin\mingw32-gcc.exe"

del /q "%DST%\._.DS_store"
del /q "%DST%\.DS_store"

@rem 
@rem remove debugging symbols from binutils executables
@rem and GCC runtime libraries
@rem just a matter of size...
@rem 

set STRIP=%DST%\bin\strip.exe
set STRIP_FLAGS=--strip-unneeded

"%STRIP%" %STRIP_FLAGS% "%DST%\bin\exchndl.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libcharset-1.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libgmp-3.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libgmpxx-4.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libgomp-1.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libiconv-2.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libmpfr-1.dll"
"%STRIP%" %STRIP_FLAGS% "%DST%\bin\libssp-0.dll"

for %%a in (%DST%\bin\*.exe) DO "%STRIP%" %STRIP_FLAGS% "%%a"

@rem 
@rem  Fix  bug in libstd++ headers
@rem  See  SF # 2836185
@rem  "https://sourceforge.net/tracker/?func=detail&aid=2836185&group_id=2435&atid=102435"
@rem
sed -i -e "s@class _GLIBCXX_IMPORT@class @g" "%DST%\lib\gcc\mingw32\%GCCVER%\include\c++\exception"
sed -i -e "s@class _GLIBCXX_IMPORT@class @g" "%DST%\lib\gcc\mingw32\%GCCVER%\include\c++\new"
sed -i -e "s@class _GLIBCXX_IMPORT@class @g" "%DST%\lib\gcc\mingw32\%GCCVER%\include\c++\typeinfo"

@rem
@rem  fix bug with libtool messing up shared libstd++ builds (again, sigh)
@rem  move the libstdc++.la file out of the way 
@rem  See the following links:
@rem    http://sourceforge.net/mailarchive/forum.php?thread_name=4A97B057.2040803%40gmail.com&forum_name=mingw-users
@rem    http://thread.gmane.org/gmane.comp.gnu.mingw.user/30206/focus=30243
@rem
pushd %DST%\lib\gcc\mingw32\%GCCVER%"
ren "libstdc++.la" "libstdc++.la.bak"
popd

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
pause
