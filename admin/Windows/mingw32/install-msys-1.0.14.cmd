@setlocal
@rem 
@rem  This script is a mini-installer for a MSYS-1.0.14 environment to build 
@rem  Ocatve on windows using msys/mingw.
@rem
@rem  It requires at least windows 2000 and cmd.exe with extensions enabled.
@rem
@rem  To work, this script requires that you downloaded all files listed in
@rem  msys/msys-1.0.14-url.txt into the directory msys/ (or whatever SRC is set 
@rem  to below). To download you can use wget.exe. Win32 binaries are available 
@rem  e.g. from http://users.ugent.be/~bpuype/wget/.
@rem  To download, chdir to msys/ and issue
@rem    wget -N -i msys-url.txt
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
@rem  to install the MSYS build environment, e.g.
@rem    c:\build\octave\msys-1.0.11
@rem  If the directory does not exist, it will be created.
@rem
@rem  This script also calls the corresponding MINGW32-GCC installer script
@rem  and it sets up a /build mount point for the directory you checked-out
@rem  the SVN build environment (and thus where this installer script resides)
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
@rem     * adapt from install-msys-1.0.11.cmd
@rem     * update to msys-core 1.0.14
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
SET W32TAR=basic-bsdtar
SET W32TAROPT=-x -C "%DST%" 

@rem Msys' sed
SET MSYSSED="%DST%\bin\sed.exe"

@rem Msys' patch
SET MSYSPATCH="%DST%\bin\patch.exe"

@rem
@rem  Extract MSYScore. Requires win32 bsdtar version
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%msysCORE-1.0.14-1-msys-1.0.14-bin.tar.lzma"

@rem
@rem  Extract MSYS base utilities
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%make-3.81-2-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%coreutils-5.97-2-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%coreutils-5.97-2-msys-1.0.11-ext.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%bash-3.1.17-2-msys-1.0.11-bin.tar.lzma"

@rem
@rem  Extract MSYS BSDTAR
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%tar-1.22-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gzip-1.3.12-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libopenssl-0.9.8k-1-msys-1.0.11-dll-098.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%liblzma-4.999.9beta_20091209-1-msys-1.0.12-dll-1.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%xz-4.999.9beta_20091209-1-msys-1.0.12-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%zlib-1.2.3-1-msys-1.0.11-dll.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libbz2-1.0.5-1-msys-1.0.11-dll-1.tar.gz"

@rem
@rem  Extract PERL
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%perl-5.6.1_2-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libcrypt-1.1_1-2-msys-1.0.11-dll-0.tar.lzma"

@rem
@rem  AUTOCONF & AUTOMAKE
@rem  Use the MSYS versions, because the MINGW32 versions must be installed in to /mingw,
@rem  which makes it useless. Why would I want to install it there?
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%autoconf-2.63-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%automake-1.11-1-msys-1.0.11-bin.tar.lzma"

@rem
@rem  extract updated MSYS tools
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%bzip2-1.0.5-1-msys-1.0.11-bin.tar.gz"
%W32TAR% %W32TAROPT% -f "%SRCDIR%cvs-1.12.13-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%diffutils-2.8.7.20071206cvs-2-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%findutils-4.4.2-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%gawk-3.1.7-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%grep-2.5.4-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%groff-1.20.1-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%less-436-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%m4-1.4.13-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%man-1.6f-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%patch-2.5.9-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%rxvt-2.7.10.20050409-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%sed-4.2.1-1-msys-1.0.11-bin.tar.lzma"

@rem 
@rem  Extract bison
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%bison-2.4.1-1-msys-1.0.11-bin.tar.lzma"

@rem 
@rem  Extract flex
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%flex-2.5.35-1-msys-1.0.11-bin.tar.lzma"
%W32TAR% %W32TAROPT% -f "%SRCDIR%libregex-1.20090805-1-msys-1.0.11-dll-1.tar.lzma"

@rem
@rem  Extract gperf
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%gperf-3.0.1-bin.zip" bin/*.exe

@rem
@rem  Add 7za and wget executables to /local/bin
@rem
mkdir "%DST%\local\bin"
%W32TAR% x -C "%DST%\local\bin" -f "%SRCDIR%7za913.zip" 7za.exe
copy "%SRCDIR%wget.exe" "%DST%\local\bin"

@rem
@rem  Extract and patch libtool 
@rem
%W32TAR% %W32TAROPT% -f "%SRCDIR%libtool-2.2.7a-1-mingw32-bin.tar.lzma"
%MSYSSED% ^
	-e "/^prefix/s+/mingw+/usr+" ^
	-e "/^datadir/s+/mingw+/usr+" ^
	-e "/^pkgdatadir/s+/mingw+/usr+" ^
	-e "/^pkgltdldir/s+/mingw+/usr+" ^
	-e "/^aclocaldir/s+/mingw+/usr+" ^
	"%DST%\bin\libtoolize" > "%DST%\bin\libtoolize.mod"
move /Y "%DST%\bin\libtoolize.mod" "%DST%\bin\libtoolize"
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
%MSYSSED% -e "s+Courier-12+\"Lucida Console-10\"+" "%DST%\msys.bat" > "%DST%\msys.bat.mod"
move /Y "%DST%\msys.bat.mod" "%DST%\msys.bat"

@rem
@rem  Remove windows' PATH from msys' PATH 
@rem  This avoids unintentional picking up of dlls from around your machine
@rem
%MSYSSED% -e "/PATH=/s/:$PATH//" "%DST%\etc\profile" > "%DST%\etc\profile.mod"
move /Y "%DST%\etc\profile.mod" "%DST%\etc\profile"

@rem
@rem  add a /build mount point to the root of the repository
@rem
FOR /F "usebackq" %%a in (`cd ^| %MSYSSED% -e ""s#\\\\#/#g""`) DO SET RR=%%a
echo %RR%	/build>>"%DST%\etc\fstab"

@rem
@rem  Call the default mingw32 installer
@rem
IF NOT EXIST "install-mingw32-4.5.0.cmd" goto :skipmingw32

mkdir "%DST%\mingw"
CALL install-mingw32-4.5.0.cmd "%DST%\mingw"


:skipmingw32
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

:end
pause
