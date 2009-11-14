@setlocal
@rem 
@rem  This script is a mini-installer for a MSYS-1.0.11 environment to build 
@rem  Ocatve on windows using msys/mingw.
@rem
@rem  It requires at least windows 2000 and cmd.exe with extensions enabled.
@rem
@rem  To work, this script requires that you downloaded all files listed in
@rem  msys/msys-url.txt into the directory msys/ (or whatever SRC is set to 
@rem  below). To download you can use wget.exe. Win32 binaries are available 
@rem  e.g. from http://users.ugent.be/~bpuype/wget/.
@rem  To download, chdir to msys/ and issue
@rem    wget -N -i msys-url.txt
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
@rem  to install the MSYS build environment, e.g.
@rem    c:\build\octave\msys-1.0.11
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
@rem   14-nov-2009  Benjamin Lindner <lindnerb@users.sourceforge.net>
@rem   
@rem     * add bin/libtool from libtool-2.2.7a-1-mingw32-bin.tar.lzma
@rem     * add an empriric patch to get libtool to build shared libraries
@rem       found on: http://lists.cairographics.org/archives/cairo/2009-July/017683.html
@rem
@rem   24-oct-2009  Benjamin Lindner <lindnerb@users.sourceforge.net>
@rem   
@rem     * add wget.exe and 7za.exe to /local/bin
@rem
@rem   15-oct-2009  Benjamin Lindner <lindnerb@users.sourceforge.net>
@rem   
@rem     * update documentation text above
@rem     * update MSYS core to 1.0.11 (release) and add additional components 
@rem     * reorganize and comment script code
@rem


@rem   == BEGIN CONFIGURATION SECTION ==

@rem
@rem  Directory where MSYS sources are located
@rem
SET SRCDIR=msys\

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
@rem  BSDTAR required to extract msysCORE
@rem
SET W32TAR=bsdtar
SET W32TAROPT=-x -C "%DST%" 

@rem  Msys' bsdtar
SET MSYSBSDTAR="%DST%\bin\bsdtar.exe"

@rem Msys' sed
SET MSYSSED="%DST%\bin\sed.exe"

@rem Msys' patch
SET MSYSPATCH="%DST%\bin\patch.exe"

@rem
@rem  Extract MSYScore. Requires win32 bsdtar version
@rem
%W32TAR% %W32TAROPT% -f %SRCDIR%msysCORE-1.0.11-bin.tar.gz

@rem
@rem  Extract MSYS BSDTAR
@rem
call :extracttarlzma "%SRCDIR%bsdtar-2.7.1-1-msys-1.0.11-bin.tar.lzma"
call :extracttarlzma "%SRCDIR%libarchive-2.7.1-1-msys-1.0.11-dll-2.tar.lzma"
call :extracttarlzma "%SRCDIR%libopenssl-0.9.8k-1-msys-1.0.11-dll-098.tar.lzma"
call :extracttargz "%SRCDIR%liblzma-4.999.9beta-1-msys-1.0.11-dll-1.tar.gz"
call :extracttargz "%SRCDIR%xz-4.999.9beta-1-msys-1.0.11-bin.tar.gz"
call :extracttargz "%SRCDIR%zlib-1.2.3-1-msys-1.0.11-dll.tar.gz"
call :extracttargz "%SRCDIR%libbz2-1.0.5-1-msys-1.0.11-dll-1.tar.gz"

@rem
@rem  Extract PERL
@rem
%MSYSBSDTAR% -x -C "%DST%" -f "%SRCDIR%perl-5.6.1_2-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% -x -C "%DST%" -f "%SRCDIR%libcrypt-1.1_1-2-msys-1.0.11-dll-0.tar.lzma"

@rem
@rem  AUTOCONF & AUTOMAKE
@rem  Use the MSYS versions, because the MINGW32 versions must be installed in to /mingw,
@rem  which makes it useless. Why would I want to install it there?
@rem
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%autoconf-2.63-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%automake-1.11-1-msys-1.0.11-bin.tar.lzma"

@rem
@rem  extract updated MSYS tools
@rem
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%bzip2-1.0.5-1-msys-1.0.11-bin.tar.gz"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%cvs-1.12.13-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%diffutils-2.8.7.20071206cvs-2-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%findutils-4.4.2-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%gawk-3.1.7-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%grep-2.5.4-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%groff-1.20.1-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%gzip-1.3.12-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%less-436-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%m4-1.4.13-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%man-1.6f-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%patch-2.5.9-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%rxvt-2.7.10.20050409-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%sed-4.2.1-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%tar-1.22-1-msys-1.0.11-bin.tar.lzma"

@rem 
@rem  Extract bison
@rem
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%bison-2.4.1-1-msys-1.0.11-bin.tar.lzma"

@rem 
@rem  Extract flex
@rem
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%flex-2.5.35-1-msys-1.0.11-bin.tar.lzma"
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%libregex-1.20090805-1-msys-1.0.11-dll-1.tar.lzma"

@rem
@rem  Extract gperf
@rem
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%gperf-3.0.1-bin.zip" bin/*.exe

@rem
@rem  Add 7za and wget executables to /local/bin
@rem
mkdir "%DST%\local\bin"
%W32TAR% x -C "%DST%\local\bin" -f "%SRCDIR%7za465.zip" 7za.exe
copy "%SRCDIR%wget.exe" "%DST%\local\bin"

@rem
@rem  Extract and patch libtool 
@rem
%MSYSBSDTAR% %W32TAROPT% -f "%SRCDIR%libtool-2.2.7a-1-mingw32-bin.tar.lzma"
%MSYSSED% -i ^
	-e "/^prefix/s+/mingw+/usr+" ^
	-e "/^datadir/s+/mingw+/usr+" ^
	-e "/^pkgdatadir/s+/mingw+/usr+" ^
	-e "/^pkgltdldir/s+/mingw+/usr+" ^
	-e "/^aclocaldir/s+/mingw+/usr+" ^
	"%DST%\bin\libtoolize"
type "%SRCDIR%libtool-2.2.7a-pass_all.patch" | %MSYSPATCH% -d /share/aclocal -u -p 2

@rem
@rem  Rename the msys icon. Windows gets confused if a .m file extension
@rem  is registered.
@rem
move "%DST%\m.ico" "%DST%\the-m.ico"

@rem
@rem  Switch from Courier-12 to Lucida Console-10 in rxvt
@rem  Change at your own gusto.
@rem
%MSYSSED% -i -e "s+Courier-12+\"Lucida Console-10\"+" "%DST%\msys.bat" 

@rem
@rem  Remove windows' PATH from msys' PATH 
@rem  This avoids unintentional picking up of dlls from around your machine
@rem
%MSYSSED% -i -e "/PATH=/s/:$PATH//" "%DST%\etc\profile" 

@rem  That's it!
goto :end

:usage
@echo.
@echo  USAGE:  %0 TARGET-PATH
@echo.
goto :EOF

:errorcreatingdst
@echo.
@echo ERROR: The target directory ^<%DST%^> could not be created!
@echo.
goto :end

:emptydst
@echo You did not specify an installation directory!
goto :EOF

:askuser
SET /P DST=Path to install MSYS to: 
if %DST%/==/ goto :emptydst
goto :eof

:extracttarlzma
@rem
@rem  call :extracttarlzma <FILE>
@rem
copy "%~1" "%DST%" >NUL
pushd "%DST%"
bin\lzma -d "%~nx1"
bin\tar -x -f "%~n1"
del "%~n1"
popd
goto :EOF

:extracttarbz2
@rem
@rem  call :extracttarbz2 <FILE>
@rem
copy "%~1" "%DST%" >NUL
pushd "%DST%"
bin\bzip2 -d "%~nx1"
bin\tar -x -f "%~n1"
del "%~n1"
popd
goto :EOF

:extracttargz
@rem
@rem  call :extracttarbz2 <FILE>
@rem
copy "%~1" "%DST%" >NUL
pushd "%DST%"
bin\gzip -d "%~nx1"
bin\tar -x -f "%~n1"
del "%~n1"
popd
goto :EOF

:end
pause
