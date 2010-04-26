@setlocal
@rem 
@rem  This script is a mini-installer for MinGW32 GCC 
@rem  to build Octave for windows using msys/mingw
@rem
@rem  It currently installs GCC version 4.5.0.
@rem
@rem  It requires at least windows 2000 and cmd.exe with extensions enabled.
@rem
@rem  To work, this script requires that you downloaded all files listed in
@rem  mingw32/mingw32-gcc-4.5.0-url.txt into the directory mingw32/ (or whatever 
@rem  SRC is set to below). To download you can use wget.exe. Win32 binaries 
@rem  of wget are available e.g. from http://users.ugent.be/~bpuype/wget/.
@rem  To download, chdir to minwg32/ and issue
@rem    wget -N -i mingw32-gcc-4.5.0-url.txt
@rem
@rem  Furthermore, it requires a native win32 version of bsdtar.exe (libarchive)
@rem  available in your PATH. The version of bsdtar must support lzma 
@rem  compression.
@rem  A suitable binary of bsdtar is available at
@rem   http://downloads.sourceforge.net/mingw/basic-bsdtar-2.8.3-1-mingw32-bin.zip
@rem  Unzip the executable basic-bsdtar.exe to a directory which is found in 
@rem  your PATH
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
@rem   26-apr-2010  Benjamin Lindner <lindnerb@users.sourceforge.net>
@rem   
@rem     * adapt from install-mingw32-4.4.0.cmd


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
SET W32TAR=basic-bsdtar
SET W32TAROPT=-x -C "%DST%" 


SET GCCVER=4.5.0


%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-core-%GCCVER%-1-mingw32-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-c++-%GCCVER%-1-mingw32-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gcc-fortran-%GCCVER%-1-mingw32-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libgcc-%GCCVER%-1-mingw32-dll-1.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libgfortran-%GCCVER%-1-mingw32-dll-3.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libstdc++-%GCCVER%-1-mingw32-dll-6.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libssp-%GCCVER%-1-mingw32-dll-0.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libgomp-%GCCVER%-1-mingw32-dll-1.tar.lzma"

%W32TAR% %W32TAROPT% -f "%SRCDIR%libpthread-2.8.0-3-mingw32-dll-2.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%pthreads-w32-2.8.0-3-mingw32-dev.tar.lzma"

%W32TAR% %W32TAROPT% -f "%SRCDIR%libgmp-5.0.1-1-mingw32-dll-10.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libgmpxx-5.0.1-1-mingw32-dll-4.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libmpc-0.8.1-1-mingw32-dll-2.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma"

%W32TAR% %W32TAROPT% -f "%SRCDIR%mingwrt-3.18-mingw32-dev.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%mingwrt-3.18-mingw32-dll.tar.gz"

%W32TAR% %W32TAROPT% -f "%SRCDIR%w32api-3.14-mingw32-dev.tar.gz"

%W32TAR% %W32TAROPT% -f "%SRCDIR%binutils-2.20.1-2-mingw32-bin.tar.gz"

%W32TAR% %W32TAROPT% -f "%SRCDIR%gdb-7.1-2-mingw32-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libexpat-2.0.1-1-mingw32-dll-1.tar.gz"


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
