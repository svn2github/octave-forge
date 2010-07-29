@echo off
rem
rem  INSTALL.CMD  -  minimal msys installer
rem
rem  This script acts as as mini-installer for a msys environment
rem
rem  Usage:
rem     INSTALL  [target-path]
rem
rem  If no target path is specified on the command line, the script will
rem  ask for it. If the target directory does not exist, it will be created
rem
rem  The installer will download all required/requested parts and store it
rem  to src/ (or wherever SRCDIR points to)
rem  Any already downloaded archive will no be re-downloaded
rem  
rem  Prerequisites:
rem  -------------
rem
rem  This script requires two executables: 
rem   1) a native win32 version of bsdtar, capable of decompressing lzma 
rem      archives. You can get such a version from the mingw project at
rem      http://downloads.sourceforge.net/mingw/basic-bsdtar-2.8.3-1-mingw32-bin.zip
rem      Download, and unpack basic-bsdtar.exe to a directory in your PATH
rem   2) a native win32 version of wget. Such is available e.g. from
rem      http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
rem      Again, download and put in a directory in your PATH
rem
rem  If you don't want to have these executable in your path, then
rem  simply update the paths in the W32TAR and WGET veariable in this 
rem  installer
rem
rem  === WARNING ===
rem  This installer is not foolproof, and not designed to do error checking
rem  So it's experts only. Use at your own risk! Hence:
rem
rem  This file is distributed in the hope that it will be useful but WITHOUT 
rem  ANY WARRANTY.  ALL WARRANTIES, EXPRESSED OR IMPLIED ARE HEREBY DISCLAIMED. 
rem  This includes but is not limited to warranties of MERCHANTABILITY or 
rem  FITNESS FOR A PARTICULAR PURPOSE.
rem
rem  June 2010   Benjamin Lindner <lindnerb@users.sourceforge.net>


rem 
rem  Target installation directory
rem
if "%1/"=="/" (
   call :askuser
) ELSE (
   SET "DST=%~1"
)

IF NOT EXIST "%DST%" mkdir %DST%
IF NOT EXIST "%DST%" goto :errormkdir

rem
rem  Utilities required
rem
SET W32TAR=basic-bsdtar.exe
SET WGET=wget.exe

rem
rem  Path to downloaded msys packages
rem
SET SRCDIR=bin\

rem
rem  Check for required unitilies
rem
call :checkforutil "%W32TAR%"
call :checkforutil "%WGET%

rem
rem  Download and install
rem
call :msysinstall msysCORE-1.0.15-1-msys-1.0.15-bin.tar.lzma
call :msysinstall msysCORE-1.0.15-1-msys-1.0.15-ext.tar.lzma
call :msysinstall libiconv-1.13.1-2-msys-1.0.13-dll-2.tar.lzma
call :msysinstall libcharset-1.13.1-2-msys-1.0.13-dll-1.tar.lzma
call :msysinstall libintl-0.17-2-msys-dll-8.tar.lzma
call :msysinstall libtermcap-0.20050421_1-2-msys-1.0.13-dll-0.tar.lzma
call :msysinstall libregex-1.20090805-2-msys-1.0.13-dll-1.tar.lzma
call :msysinstall coreutils-5.97-3-msys-1.0.13-bin.tar.lzma
call :msysinstall bash-3.1.17-3-msys-1.0.13-bin.tar.lzma
call :msysinstall make-3.81-3-msys-1.0.13-bin.tar.lzma

call :msysinstall zlib-1.2.3-2-msys-1.0.13-dll.tar.lzma
call :msysinstall libbz2-1.0.5-2-msys-1.0.13-dll-1.tar.lzma
call :msysinstall bzip2-1.0.5-2-msys-1.0.13-bin.tar.lzma
call :msysinstall gzip-1.3.12-2-msys-1.0.13-bin.tar.lzma
call :msysinstall tar-1.23-1-msys-1.0.13-bin.tar.lzma
call :msysinstall liblzma-4.999.9beta_20100401-1-msys-1.0.13-dll-1.tar.gz
call :msysinstall xz-4.999.9beta_20100401-1-msys-1.0.13-bin.tar.gz

call :msysinstall zip-3.0-1-msys-1.0.14-bin.tar.lzma
call :msysinstall unzip-6.0-1-msys-1.0.13-bin.tar.lzma

call :msysinstall sed-4.2.1-2-msys-1.0.13-bin.tar.lzma
call :msysinstall less-436-2-msys-1.0.13-bin.tar.lzma
call :msysinstall findutils-4.4.2-2-msys-1.0.13-bin.tar.lzma
call :msysinstall patch-2.6.1-1-msys-1.0.13-bin.tar.lzma
call :msysinstall diffutils-2.8.7.20071206cvs-3-msys-1.0.13-bin.tar.lzma

call :msysinstall cvs-1.12.13-2-msys-1.0.13-bin.tar.lzma
call :msysinstall libcrypt-1.1_1-3-msys-1.0.13-dll-0.tar.lzma

call :msysinstall grep-2.5.4-2-msys-1.0.13-bin.tar.lzma
call :msysinstall gawk-3.1.7-2-msys-1.0.13-bin.tar.lzma
call :msysinstall m4-1.4.14-1-msys-1.0.13-bin.tar.lzma
call :msysinstall flex-2.5.35-2-msys-1.0.13-bin.tar.lzma
call :msysinstall bison-2.4.2-1-msys-1.0.13-bin.tar.lzma

call :msysinstall texinfo-4.13a-2-msys-1.0.13-bin.tar.lzma

mkdir "%DST%\mingw"
call :mingwinstall gcc-core-4.5.0-1-mingw32-bin.tar.lzma
call :mingwinstall gcc-c++-4.5.0-1-mingw32-bin.tar.lzma
call :mingwinstall libgcc-4.5.0-1-mingw32-dll-1.tar.lzma
call :mingwinstall libstdc++-4.5.0-1-mingw32-dll-6.tar.lzma
call :mingwinstall libgmp-5.0.1-1-mingw32-dll-10.tar.lzma
call :mingwinstall libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma
call :mingwinstall libmpc-0.8.1-1-mingw32-dll-2.tar.lzma
call :mingwinstall binutils-2.20.51-1-mingw32-bin.tar.lzma
call :mingwinstall mingwrt-3.18-mingw32-dll.tar.gz
call :mingwinstall mingwrt-3.18-mingw32-dev.tar.gz
call :mingwinstall w32api-3.14-mingw32-dev.tar.gz

mkdir "%DST%\local\bin"
call :install junction.zip  http://download.sysinternals.com/Files/junction.zip \local\bin

mkdir "%DST%\mingw"
call :install svn-win32-1.6.12.zip http://alagazam.net/svn-1.6.12/svn-win32-1.6.12.zip \mingw "--strip-components=1"

call :download wget.exe "http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe"
echo wget.exe...
COPY /Y %SRCDIR%\wget.exe "%DST%\local\bin" >NUL

pause
goto :EOF

:askuser
set /P "DST=Enter the directory MSYS should be installed to: "
goto :EOF

:errormkdir
echo The installation directory %DST% could not be created!
exit /B 1

:checkforutil
set "CHK=%~1"
shift
if "%~1/"=="/" (
   SET FLAG=--version
) ELSE (
   SET "FLAG=%~1"
)
"%CHK%" "%FLAG%" >NUL 2>&1
IF ERRORLEVEL 1 (
echo Required program %CHK% could not be found!
echo Please check the help text for download locations!
pause
exit 2
)
goto :EOF

:download
rem Download package %1 from url %2 if not yet existent in directory %SRCDIR%
SET "PKG=%~1"
SET "URL=%~2"

IF NOT EXIST "%SRCDIR%%PKG%" (
    start "" /WAIT "%WGET%" -P %SRCDIR% "%URL%"
)
IF NOT EXIST "%SRCDIR%%PKG%" (
   echo Error downloading %PKG% from %URL%!
   exit /B 3
)
goto :EOF


:install
rem Install package %1 to be downloaded from url %2 to %DST%%DSTSUB%
SET "PKG=%~1"
SET "URL=%~2"
SET "DSTSUB=%~3"

rem download
call :download "%PKG%" "%URL%"

rem unpack
echo %PKG%...
"%W32TAR%" -x -C "%DST%%DSTSUB%" -f "%SRCDIR%%PKG%" %~4
IF ERRORLEVEL 1 (
   echo Error unpacking %PKG%!
)
goto :EOF

:msysinstall
call :install "%~1" "http://downloads.sourceforge.net/mingw/%~1%"
goto :EOF

:mingwinstall
call :install "%~1" "http://downloads.sourceforge.net/mingw/%~1%" \mingw
goto :EOF
