@setlocal


@rem This script installs a MSYS-1.0.11 environment suitable for building
@rem Octave using mingw32-GCC on win32
@rem
@rem Usage: INSTALL.CMD <target-path>
@rem
@rem The target (=installation) directory must exist!
@rem
@rem This script requires LIBARCHIVE available from gnuwin32.sourceforge.net
@rem 
@rem Download the following files PRIOR to executing this script into the directory MSYS-ENV:
@rem   http://downloads.sourceforge.net/mingw/msysCORE-1.0.11-20080826.tar.gz
@rem   http://downloads.sourceforge.net/mingw/perl-5.6.1-MSYS-1.0.11-1.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/crypt-1.1-1-MSYS-1.0.11-1.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/autoconf2.1-2.13-3-bin.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/autoconf2.5-2.61-1-bin.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/autoconf-4-1-bin.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/automake1.10-1.10-1-bin.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/automake1.9-1.9.6-2-bin.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/automake-3-1-bin.tar.bz2
@rem
@rem   http://downloads.sourceforge.net/mingw/bison-2.3-MSYS-1.0.11-1.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/flex-2.5.33-MSYS-1.0.11-1.tar.bz2
@rem   http://downloads.sourceforge.net/mingw/regex-0.12-MSYS-1.0.11-1.tar.bz2
@rem   http://gnuwin32.sourceforge.net/downlinks/gperf-bin-zip.php

IF %1/==/ goto usage

SET DST=%~1

IF NOT EXIST "%DST%" goto notexist

SET TAR=bsdtar
SET TAROPT=-x -C "%DST%" 

SET SRC=msys-env

%TAR% %TAROPT% -f %SRC%\msysCORE-1.0.11-20080826.tar.gz

%TAR% %TAROPT% -f %SRC%\perl-5.6.1-MSYS-1.0.11-1.tar.bz2
%TAR% %TAROPT% -f %SRC%\crypt-1.1-1-MSYS-1.0.11-1.tar.bz2 bin/*.*
%TAR% %TAROPT% -f %SRC%\bison-2.3-MSYS-1.0.11-1.tar.bz2
%TAR% %TAROPT% -f %SRC%\flex-2.5.33-MSYS-1.0.11-1.tar.bz2
%TAR% %TAROPT% -f %SRC%\regex-0.12-MSYS-1.0.11-1.tar.bz2 bin/*.*
%TAR% %TAROPT% -f %SRC%\gperf-3.0.1-bin.zip bin/gperf.exe

move "%DST%\m.ico" "%DST%\the-m.ico"

mkdir tmp
mkdir "%DST%\local"
%TAR% -x -C tmp -f %SRC%\autoconf2.1-2.13-3-bin.tar.bz2
%TAR% -x -C tmp -f %SRC%\autoconf2.5-2.61-1-bin.tar.bz2
%TAR% -x -C tmp -f %SRC%\autoconf-4-1-bin.tar.bz2
%TAR% -x -C tmp -f %SRC%\automake1.10-1.10-1-bin.tar.bz2
%TAR% -x -C tmp -f %SRC%\automake1.9-1.9.6-2-bin.tar.bz2
%TAR% -x -C tmp -f %SRC%\automake-3-1-bin.tar.bz2
xcopy /E /Q tmp\usr\local "%DST%\local"
rmdir /s /q tmp

sed -i -e "s/Courier-12/\"Lucida Console-10\"/" "%DST%\msys.bat"

goto :EOF


:usage
@echo.
@echo  USAGE:  %0 TARGET-PATH
@echo.
@echo The target (=installation) directory must exist!
@echo.

goto :EOF


:notexist
@echo.
@echo ERROR: The target directory ^<%DST%^> does not exist!
@echo.

goto :EOF
