@setlocal

@rem This script installs GCC Mingw32-TDM 4.3.0-2 DW2 suitable for building
@rem Octave using mingw32-GCC on win32
@rem
@rem Usage: INSTALL-MINGW32-4.3.0-2-dw2.CMD <target-path>
@rem
@rem The target (=installation) directory must exist!
@rem
@rem This script requires LIBARCHIVE available from gnuwin32.sourceforge.net
@rem 
@rem Download the following files PRIOR to executing this script into the directory MINGW32-ENV:
@rem    http://downloads.sourceforge.net/tdm-gcc/gcc-4.3.0-tdm-2-dw2-core.tar.gz
@rem    http://downloads.sourceforge.net/tdm-gcc/gcc-4.3.0-tdm-2-dw2-fortran.tar.gz
@rem    http://downloads.sourceforge.net/tdm-gcc/gcc-4.3.0-tdm-2-dw2-g++.tar.gz
@rem    http://downloads.sourceforge.net/mingw/binutils-2.19.1-mingw32-bin.tar.gz
@rem    http://downloads.sourceforge.net/mingw/mingw32-make-3.81-20080326-3.tar.gz
@rem    http://downloads.sourceforge.net/mingw/gdb-6.8-mingw-3.tar.bz2
@rem    http://downloads.sourceforge.net/mingw/w32api-3.13-mingw32-dev.tar.gz
@rem    http://downloads.sourceforge.net/mingw/mingwrt-3.15.2-mingw32-dev.tar.gz
@rem    http://downloads.sourceforge.net/mingw/mingw-utils-0.3.tar.gz


if %1/==/ (call :askuser) else SET DST=%~1

IF NOT EXIST "%DST%" goto notexist

SET BSDTAR=bsdtar
SET TAROPT=-x -C "%DST%" -f

SET SRC=mingw32-env

SET GCCVER=-4.3.0
SET GCCREL=-2
SET GCCVEND=-tdm
SET GCCSYS=-dw2

%BSDTAR% %TAROPT% %SRC%\gcc%GCCVER%%GCCVEND%%GCCREL%%GCCSYS%-core.tar.gz
%BSDTAR% %TAROPT% %SRC%\gcc%GCCVER%%GCCVEND%%GCCREL%%GCCSYS%-fortran.tar.gz
%BSDTAR% %TAROPT% %SRC%\gcc%GCCVER%%GCCVEND%%GCCREL%%GCCSYS%-g++.tar.gz

%BSDTAR% %TAROPT% %SRC%\binutils-2.19.1-mingw32-bin.tar.gz
%BSDTAR% %TAROPT% %SRC%\mingw32-make-3.81-20080326-3.tar.gz
%BSDTAR% %TAROPT% %SRC%\mingwrt-3.15.2-mingw32-dev.tar.gz
%BSDTAR% %TAROPT% %SRC%\mingw-utils-0.3.tar.gz
%BSDTAR% %TAROPT% %SRC%\w32api-3.13-mingw32-dev.tar.gz
%BSDTAR% %TAROPT% %SRC%\gdb-6.8-mingw-3.tar.bz2

copy "%DST%\bin\mingw32-g++%GCCSYS%.exe" "%DST%\bin\mingw32-g++%GCCVER%%GCCSYS%.exe"
copy "%DST%\bin\mingw32-gfortran%GCCSYS%.exe" "%DST%\bin\mingw32-gfortran%GCCVER%%GCCSYS%.exe"
copy "%DST%\bin\mingw32-c++%GCCSYS%.exe" "%DST%\bin\mingw32-c++%GCCVER%%GCCSYS%.exe"
copy "%DST%\bin\cpp%GCCSYS%.exe" "%DST%\bin\mingw32-cpp%GCCVER%%GCCSYS%.exe"

del /q "%DST%\bin\cpp%GCCSYS%.exe"
del /q "%DST%\bin\gcc%GCCSYS%.exe"
del /q "%DST%\bin\g++%GCCSYS%.exe"
del /q "%DST%\bin\c++%GCCSYS%.exe"
del /q "%DST%\bin\gfortran%GCCSYS%.exe"

del /q "%DST%\bin\mingw32-g++%GCCSYS%.exe"
del /q "%DST%\bin\mingw32-gfortran%GCCSYS%.exe"
del /q "%DST%\bin\mingw32-c++%GCCSYS%.exe"
del /q "%DST%\bin\mingw32-gcc%GCCSYS%.exe"

goto :end

:usage
@echo USAGE %0 ^<TARGET-DIRECTORY^>
@echo.
goto :end

:notexist
@echo ERROR Target Directory "%DST%" dows not exist!
@echo.
goto :END

:askuser
set /P DST="Directory to install MINGW32 to: "
if "%DST%/"=="/" goto emptydst
IF NOT EXIST "%DST%" mkdir "%DST%"
goto :EOF

:emptydst
@echo You did not specify an installation directory!
goto :END

:end

