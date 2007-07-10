#!/bin/sh

###################################################################################
#
# Requirements
#	- Visual Studio (tested with VC++ Express 2005)
#	- MSYS shell
#	- MSYS Development Toolkit (DTK)
#	- wget (GnuWin32)
#	- unzip (GnuWin32)
#	- octave-forge CVS tree (at least the admin/Windows/msvc/ directory)
#	- cygwin with gcc (to compile ATLAS)
#
###################################################################################

#################
# Configuration #
#################

INSTALL_DIR=/c/Temp/vclibs_tmp
CYGWIN_DIR=/c/Software/cygwin
DOWNLOAD_DIR=downloaded_packages
#WGET_FLAGS="-e http_proxy=http://webproxy:8123 -e ftp_proxy=http://webproxy:8123"
DOATLAS=false

verbose=false

###################################################################################

function download_file
{
  filename=$1
  location=$2
  if ! test -f "$DOWNLOAD_DIR/$filename"; then
    echo -n "downloading $filename... "
    mkdir -p "$DOWNLOAD_DIR"
    if $verbose; then
      echo "wget $WGET_FLAGS -o \"$DOWNLOAD_DIR/$filename\" \"$location\""
    fi
    wget $WGET_FLAGS -q -O "$DOWNLOAD_DIR/$filename" "$location"
    if ! test -f "$DOWNLOAD_DIR/$filename"; then
      echo "failed"
      exit -1
    else
      echo "done"
    fi
  fi
}

###################################################################################

# Check Visual Studio availability
echo -n "checking for Visual Studio... "
cl_path=`which cl.exe`
if test "x$cl_path" = "x"; then
  echo "no"
  echo "Visual Studio must be installed and in your PATH variable"
  exit -1
else
  echo "yes"
fi
echo -n "checking for Platform SDK... "
cat <<EOF > conftest.c
#include <windows.h>
int main(int argc, char **argv)
{ return 0; }
EOF
cl -nologo -c conftest.c > /dev/null 2>&1
if ! test -f conftest.obj; then
  echo "no"
  echo "unable to compile simple windows program, Platform SDK is probably not available"
  exit -1
else
  echo "yes"
fi
rm -f conftest.*

# Create target directory
echo -n "creating target directories... "
mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_DIR/bin
mkdir -p $INSTALL_DIR/lib
mkdir -p $INSTALL_DIR/include
echo "done"

tbindir=$INSTALL_DIR/bin
tlibdir=$INSTALL_DIR/lib
tincludedir=$INSTALL_DIR/include
PATH=$tbindir:$PATH
tdir_w32=`cd "$INSTALL_DIR" && pwd -W`
tdir_w32_1=`echo $tdir_w32 | sed -e 's,/,\\\\,g'`
tdir_w32=`echo $tdir_w32 | sed -e 's,/,\\\\\\\\,g'`

INCLUDE="$tdir_w32_1\\include;$INCLUDE"
LIB="$tdir_w32_1\\lib;$LIB"

# Check cc-msvc
echo -n "checking for cc-msvc.exe... "
if ! test -f "$tbindir/cc-msvc.exe"; then
  echo "compiling"
  cl -nologo -O2 -EHs cc-msvc.cc
  if ! test -f cc-msvc.exe; then
    echo "failed to compile cc-msvc.exe"
    exit -1
  fi
  mv -f cc-msvc.exe "$tbindir"
  rm -f cc-msvc.obj
else
  echo "installed"
fi

# Check ar-msvc, ranlib-msvc
echo -n "checking for ar-msvc... "
if ! test -f "$tbindir/ar-msvc"; then
  echo "copying"
  cp -f ar-msvc "$tbindir"
else
  echo "installed"
fi
echo -n "checking for ranlib-msvc... "
if ! test -f "$tbindir/ranlib-msvc"; then
  echo "copying"
  cp -f ranlib-msvc "$tbindir"
else
  echo "installed"
fi
echo -n "checking for build_atlas_dll... "
if test ! -f "$tbindir/build_atlas_dll"; then
  echo "copying"
  cp -f build_atlas_dll "$tbindir"
  cp -f atl_blas.def lapack.def "$tlibdir"
else
  echo "installed"
fi

#######
# f2c #
#######

echo -n "checking for f2c... "
if ! test -f "$tbindir/f2c.exe"; then
  echo "no"
  download_file f2c.exe.gz http://www.netlib.org/f2c/mswin/f2c.exe.gz
  gzip -d -c "$DOWNLOAD_DIR/f2c.exe.gz" > "$tbindir/f2c.exe"
else
  echo "installed"
fi

##########
# libf2c #
##########

echo -n "checking for libf2c... "
if ! test -f "$tlibdir/f2c.lib"; then
  echo "no"
  download_file libf2c.zip http://www.netlib.org/f2c/libf2c.zip
  (cd "$DOWNLOAD_DIR" && unzip -q libf2c.zip)
  echo -n "compiling libf2c... "
  (cd "$DOWNLOAD_DIR/libf2c";
    sed -e 's/^CFLAGS = /CFLAGS = -MD -DIEEE_COMPLEX_DIVIDE /' makefile.vc > ttt &&
    mv ttt makefile.vc &&
    sed -e 's/^extern int isatty(int);$/\/*extern int isatty(in);*\//' fio.h > ttt &&
    mv ttt fio.h &&
    nmake -f makefile.vc &&
    cp -f f2c.h "$tincludedir" &&
    cp -f vcf2c.lib "$tlibdir/f2c.lib") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/libf2c"
  if ! test -f "$tlibdir/f2c.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

########
# BLAS #
########

echo -n "checking for BLAS... "
if ! test -f "$tbindir/blas.dll"; then
  echo "no"
  download_file blas.tgz http://www.netlib.org/blas/blas.tgz
  (cd "$DOWNLOAD_DIR" && tar xfz blas.tgz)
  echo -n "compiling BLAS... "
  cp libs/blas.makefile "$DOWNLOAD_DIR/BLAS"
  (cd "$DOWNLOAD_DIR/BLAS" &&
    make -f blas.makefile && 
    cp blas.dll "$tbindir" &&
    cp blas.lib "$tlibdir") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/BLAS"
  if ! test -f "$tbindir/blas.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

##########
# LAPACK #
##########

echo -n "checking for LAPACK... "
if ! test -f "$tbindir/lapack.dll"; then
  echo "no"
  download_file lapack-lite-3.1.0.tgz http://www.netlib.org/lapack/lapack-lite-3.1.0.tgz
  echo -n "decompressing LAPACK... "
  (cd "$DOWNLOAD_DIR" && tar xfz lapack-lite-3.1.0.tgz)
  echo "done"
  echo -n "compiling LAPACK... "
  cp libs/lapack.makefile "$DOWNLOAD_DIR/lapack-3.1.0/SRC"
  (cd "$DOWNLOAD_DIR/lapack-3.1.0/SRC" &&
    make -f lapack.makefile && 
    cp lapack.dll "$tbindir" &&
    cp lapack.lib liblapack_f77.lib "$tlibdir") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/lapack-3.1.0"
  if ! test -f "$tbindir/lapack.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

#########
# ATLAS #
#########

if $DOATLAS; then

echo -n "checking for ATLAS... "
atl_dlls=`find "$tbindir" -name "blas_atl_*.dll"`
if test -z "$atl_dlls"; then
  echo "no"
  download_file atlas-3.6.0.tar.gz 'http://downloads.sourceforge.net/math-atlas/atlas3.6.0.tar.gz?modtime=1072051200&big_mirror=0'
  echo -n "decompressing ATLAS... "
  (cd "$DOWNLOAD_DIR" && tar xfz atlas-3.6.0.tar.gz)
  cp libs/atlas-3.6.0.diff "$DOWNLOAD_DIR/ATLAS"
  echo "done"
  echo -n "compiling ATLAS... "
  (cd "$DOWNLOAD_DIR/ATLAS" &&
    patch -p1 < atlas-3.6.0.diff &&
    start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && make xconfig && echo -n '' | ./xconfig -c mvc" &&
	arch=`ls Make.*_* | sed -e 's/Make\.//'` &&
	start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && make install arch=$arch" &&
	start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && cd lib/$arch && build_atlas_dll" &&
	cp lib/$arch/blas.dll "$tbindir/blas_atl_$arch.dll" &&
	cp lib/$arch/lapack.dll "$tbindir/lapack_atl_$arch.dll") > /dev/null 2>&1
  #rm -rf "$DOWNLOAD_DIR/ATLAS"
  atl_dlls=`find "$tbindir" -name "blas_atl_*.dll"`
  if test -z "$atl_dlls"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

fi

########
# FFTW #
########

echo -n "checking for FFTW... "
if ! test -f "$tbindir/libfftw3-3.dll"; then
  echo "no"
  download_file fftw-3.1.2-dll.zip ftp://ftp.fftw.org/pub/fftw/fftw-3.1.2-dll.zip
  echo -n "decompressing FFTW... "
  (cd "$DOWNLOAD_DIR" && mkdir fftw3 && cd fftw3 && unzip -q ../fftw-3.1.2-dll.zip)
  echo "done"
  echo -n "installing FFTW ..."
  (cd "$DOWNLOAD_DIR/fftw3" &&
    cp libfftw3-3.dll "$tbindir" && 
    cp fftw3.h "$tincludedir" &&
    lib -out:fftw3.lib -def:libfftw3-3.def &&
    cp fftw3.lib "$tlibdir") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/fftw3"
  if ! test -f "$tbindir/libfftw3-3.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

########
# PCRE #
########

echo -n "checking for PCRE... "
if ! test -f "$tbindir/pcre70.dll"; then
  echo "no"
  download_file pcre-7.0.tar.gz ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-7.0.tar.gz
  echo -n "decompressing PCRE... "
  (cd "$DOWNLOAD_DIR" && tar xfz pcre-7.0.tar.gz)
  echo "done"
  echo -n "compiling PCRE... "
  cp libs/pcre-7.0.diff "$DOWNLOAD_DIR/pcre-7.0"
  (cd "$DOWNLOAD_DIR/pcre-7.0" &&
    patch -p1 < pcre-7.0.diff &&
    nmake -f Makefile.vc &&
    cp pcre70.dll "$tbindir" &&
    cp pcre.lib "$tlibdir" &&
    cp pcre.h "$tincludedir") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/pcre-7.0"
  if ! test -f "$tbindir/pcre70.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

########
# GLPK #
########

echo -n "checking for GLPK... "
if ! test -f "$tbindir/glpk49.dll"; then
  echo "no"
  download_file glpk-4.9.tar.gz ftp://ftp.gnu.org/gnu/glpk/glpk-4.9.tar.gz
  echo -n "decompressing GLPK... "
  (cd "$DOWNLOAD_DIR" && tar xfz glpk-4.9.tar.gz)
  cp libs/glpk-4.9.diff "$DOWNLOAD_DIR/glpk-4.9"
  echo "done"
  echo -n "compiling GLPK... "
  (cd "$DOWNLOAD_DIR/glpk-4.9" &&
    patch -p1 < glpk-4.9.diff &&
    sed -e "s,^DESTDIR =.*$,DESTDIR = $tdir_w32," w32vc8d.mak > ttt &&
    mv ttt w32vc8d.mak &&
    nmake -f w32vc8d.mak &&
    nmake -f w32vc8d.mak installwin) > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/glpk-4.9"
  if ! test -f "$tbindir/glpk49.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

############
# readline #
############

echo -n "checking for readline... "
if ! test -f "$tbindir/readline.dll"; then
  echo "no"
  download_file readline-5.2.tar.gz ftp://ftp.gnu.org/gnu/readline/readline-5.2.tar.gz
  echo -n "decompressing readline... "
  (cd "$DOWNLOAD_DIR" && tar xfz readline-5.2.tar.gz)
  cp libs/readline-5.2.diff "$DOWNLOAD_DIR/readline-5.2"
  echo "done"
  echo "compiling readline... "
  (cd "$DOWNLOAD_DIR/readline-5.2" &&
    patch -p1 < readline-5.2.diff &&
    CC=cc-msvc CXX=cc-msvc ./configure --build=i686-pc-msdosmsvc --prefix=$INSTALLDIR &&
    make shared &&
    make install-shared DESTDIR=$INSTALL_DIR &&
    cp shlib/readline.lib "$tlibdir" &&
    cp shlib/history.lib "$tlibdir"&&
    mv "$tlibdir/readline.dll" "$tlibdir/history.dll" "$tbindir") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/readline-5.2"
  if ! test -f "$tbindir/readline.dll"; then
    echo "failed"
  else
    echo "done"
  fi
else
  echo "installed"
fi

########
# zlib #
########

echo -n "checking for zlib... "
if ! test -f "$tbindir/zlib1.dll"; then
  echo "no"
  download_file zlib123.zip http://www.zlib.net/zlib123.zip
  echo -n "decompressing zlib... "
  (cd "$DOWNLOAD_DIR" && mkdir zlib && cd zlib && unzip -q ../zlib123.zip)
  echo "done"
  echo -n "compiling zlib... "
  (cd "$DOWNLOAD_DIR/zlib" &&
    sed -e 's/^STATICLIB *=.*$/STATICLIB = zlib-static.lib/' -e 's/^IMPLIB *=.*$/IMPLIB = zlib.lib/' win32/Makefile.msc > ttt &&
    mv ttt win32/Makefile.msc &&
    sed -e 's/1,2,2,0/1,2,3,0/' win32/zlib1.rc > ttt &&
    mv ttt win32/zlib1.rc &&
    nmake -f win32\\Makefile.msc &&
    mt -outputresource:zlib1.dll -manifest zlib1.dll.manifest &&
    cp zlib1.dll "$tbindir" &&
    cp zlib.lib "$tlibdir" &&
    cp zlib.h zconf.h "$tincludedir") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/zlib"
  if ! test -f "$tbindir/zlib1.dll"; then
    echo "failed"
  else
    echo "done"
  fi
else
  echo "installed"
fi

###############
# SuiteSparse #
###############

echo -n "checking for SuiteSparse... "
if test ! -f "$tlibdir/cxsparse.lib" -o ! -d "$tincludedir/suitesparse"; then
  echo "no"
  download_file SuiteSparse-3.0.0.tar http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-3.0.0.tar.gz
  echo -n "decompressing SuiteSparse... "
  (cd "$DOWNLOAD_DIR" && tar xf SuiteSparse-3.0.0.tar)
  cp libs/suitesparse-3.0.0.diff "$DOWNLOAD_DIR/SuiteSparse"
  echo "done"
  echo "compiling SuiteSpase... "
  (cd "$DOWNLOAD_DIR/SuiteSparse" &&
    patch -p1 < suitesparse-3.0.0.diff &&
    make &&
    make install INSTDIR="$INSTALL_DIR") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/SuiteSparse"
  if test ! -f "$tlibdir/cxsparse.lib" -o ! -d "$tincludedir/suitesparse"; then
    echo "failed"
  else
    echo "done"
  fi
else
  echo "installed"
fi

##########
# libpng #
##########

echo -n "checking for libpng... "
if test ! -f "$tlibdir/png.lib"; then
  echo "no"
  download_file lpng1216.zip ftp://ftp.simplesystems.org/pub/libpng/png/src/history/lpng1216.zip
  echo -n "decompressing libpng... "
  (cd "$DOWNLOAD_DIR" && unzip -q lpng1216.zip)
  echo "done"
  echo -n "compiling libpng... "
  (cd "$DOWNLOAD_DIR/lpng1216/projects/visualc71" &&
    sed -e 's/{2D4F8105-7D21-454C-9932-B47CAB71A5C0} = {2D4F8105-7D21-454C-9932-B47CAB71A5C0}//' libpng.sln > ttt &&
    mv ttt libpng.sln &&
    sed -e "s/\([  ]*\)AdditionalIncludeDirectories=\".*\"$/\1AdditionalIncludeDirectories=\"..\\\\..;$tdir_w32\\\\include\"/" \
      -e "s/\([  ]*\)Name=\"VCLinkerTool\".*$/\1Name=\"VCLinkerTool\"\\
AdditionalDependencies=\"zlib.lib\"\\
ImportLibrary=\"\$(TargetDir)png.lib\"\\
AdditionalLibraryDirectories=\"$tdir_w32\\\\lib\"/" libpng.vcproj > ttt &&
    mv ttt libpng.vcproj &&
    vcbuild -u libpng.vcproj 'DLL Release|Win32' &&
    cp Win32_DLL_Release/libpng13.dll "$tbindir" &&
    cp Win32_DLL_Release/png.lib "$tlibdir" &&
    cp ../../png.h ../../pngconf.h "$tincludedir") > /dev/null 2>&1
  rm -rf "$DOWNLOAD_DIR/lpng1216"
  if test ! -f "$tlibdir/png.lib"; then
    echo "failed"
  else
    echo "done"
  fi
else
	echo "installed"
fi
