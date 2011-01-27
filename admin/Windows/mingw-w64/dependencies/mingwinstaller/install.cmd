@echo off
rem
rem  INSTALL.CMD  -  minimal mingw installer
rem
rem  This script acts as as mini-installer for a mingw32 gcc environment
rem  (currently version 4.5.0)
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
rem  Path to downloaded mingw packages
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
call :msysinstall gcc-core-4.5.0-1-mingw32-bin.tar.lzma
call :msysinstall gcc-c++-4.5.0-1-mingw32-bin.tar.lzma
call :msysinstall gcc-fortran-4.5.0-1-mingw32-bin.tar.lzma
call :msysinstall libgcc-4.5.0-1-mingw32-dll-1.tar.lzma
call :msysinstall libgfortran-4.5.0-1-mingw32-dll-3.tar.lzma
call :msysinstall libstdc++-4.5.0-1-mingw32-dll-6.tar.lzma
call :msysinstall libssp-4.5.0-1-mingw32-dll-0.tar.lzma
call :msysinstall libgomp-4.5.0-1-mingw32-dll-1.tar.lzma

call :msysinstall libpthread-2.8.0-3-mingw32-dll-2.tar.lzma
call :msysinstall pthreads-w32-2.8.0-3-mingw32-dev.tar.lzma

call :msysinstall libgmp-5.0.1-1-mingw32-dll-10.tar.lzma
call :msysinstall libgmpxx-5.0.1-1-mingw32-dll-4.tar.lzma
call :msysinstall libmpc-0.8.1-1-mingw32-dll-2.tar.lzma
call :msysinstall libmpfr-2.4.1-1-mingw32-dll-1.tar.lzma

call :msysinstall mingwrt-3.18-mingw32-dev.tar.gz
call :msysinstall mingwrt-3.18-mingw32-dll.tar.gz

call :msysinstall w32api-3.15-1-mingw32-dev.tar.lzma

call :msysinstall binutils-2.21-2-mingw32-bin.tar.lzma

call :msysinstall gdb-7.2-1-mingw32-bin.tar.lzma
call :msysinstall libexpat-2.0.1-1-mingw32-dll-1.tar.gz

call :msysinstall pexports-0.44-1-mingw32-bin.tar.lzma

pause
goto :EOF

:askuser
set /P "DST=Enter the directory MINGW32 GCC should be installed to: "
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
