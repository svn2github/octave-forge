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

INSTALL_DIR=/d/Temp/vclibs_tmp
CYGWIN_DIR=/d/Software/cygwin
DOWNLOAD_DIR=downloaded_packages
WGET_FLAGS="-e http_proxy=http://webproxy:8123 -e ftp_proxy=http://webproxy:8123"
DOATLAS=false

verbose=true

###################################################################################

if $verbose; then
  exec 5>&1
else
  WGET_FLAGS="$WGET_FLAGS -q"
  exec 5>/dev/null
fi

function download_file
{
  filename=$1
  location=$2
  if ! test -f "$DOWNLOAD_DIR/$filename"; then
    echo -n "downloading $filename... "
    mkdir -p "$DOWNLOAD_DIR"
    echo "wget $WGET_FLAGS -o \"$DOWNLOAD_DIR/$filename\" \"$location\"" >&5
    wget $WGET_FLAGS -O "$DOWNLOAD_DIR/$filename" "$location"
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
PATH=$PATH:$tbindir
tdir_w32=`cd "$INSTALL_DIR" && pwd -W`
tdir_w32_forward="$tdir_w32"
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

# Check unistd.h
echo -n "checking for unistd.h... "
if test ! -f "$tincludedir/unistd.h"; then
  echo "creating"
  echo "#include <process.h>" > "$tincludedir/unistd.h"
  echo "#include <io.h>" >> "$tincludedir/unistd.h"
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
    cp -f vcf2c.lib "$tlibdir/f2c.lib") >&5 2>&1
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
    cp blas.lib "$tlibdir") >&5 2>&1
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
    cp lapack.lib liblapack_f77.lib "$tlibdir") >&5 2>&1
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
	cp lib/$arch/lapack.dll "$tbindir/lapack_atl_$arch.dll") >&5 2>&1
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
    cp fftw3.lib "$tlibdir") >&5 2>&1
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
    cp pcre.h "$tincludedir") >&5 2>&1
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
if ! test -f "$tbindir/glpk_4_19.dll"; then
  echo "no"
  download_file glpk-4.19.tar.gz ftp://ftp.gnu.org/gnu/glpk/glpk-4.19.tar.gz
  echo -n "decompressing GLPK... "
  (cd "$DOWNLOAD_DIR" && tar xfz glpk-4.19.tar.gz)
  cp libs/glpk-4.19.diff "$DOWNLOAD_DIR/glpk-4.19"
  echo "done"
  echo -n "compiling GLPK... "
  (cd "$DOWNLOAD_DIR/glpk-4.19" &&
    patch -p1 < glpk-4.19.diff &&
	cd w32 &&
    nmake -f Makefile_VC6_MT_DLL &&
	cp glpk.lib "$tlibdir" &&
	cp ../include/glpk.h "$tincludedir" &&
	cp glpk_4_19.dll "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/glpk-4.19"
  if ! test -f "$tbindir/glpk_4_19.dll"; then
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
    mv "$tlibdir/readline.dll" "$tlibdir/history.dll" "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/readline-5.2"
  if ! test -f "$tbindir/readline.dll"; then
    echo "failed"
    exit -1
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
    cp zlib.h zconf.h "$tincludedir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/zlib"
  if ! test -f "$tbindir/zlib1.dll"; then
    echo "failed"
    exit -1
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
  (cd "$DOWNLOAD_DIR" && tar xfz SuiteSparse-3.0.0.tar)
  cp libs/suitesparse-3.0.0.diff "$DOWNLOAD_DIR/SuiteSparse"
  echo "done"
  echo "compiling SuiteSpase... "
  (cd "$DOWNLOAD_DIR/SuiteSparse" &&
    patch -p1 < suitesparse-3.0.0.diff &&
    make &&
    make install INSTDIR="$INSTALL_DIR") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/SuiteSparse"
  if test ! -f "$tlibdir/cxsparse.lib" -o ! -d "$tincludedir/suitesparse"; then
    echo "failed"
    exit -1
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
    cp ../../png.h ../../pngconf.h "$tincludedir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/lpng1216"
  if test ! -f "$tlibdir/png.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

##########
# ARPACK #
##########

echo -n "checking for ARPACK... "
if test ! -f "$tbindir/arpack.dll"; then
  echo "no"
  download_file arpack96.tar.gz http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz
  download_file patch.tar.gz http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz
  echo -n "decompressing ARPACK... "
  (cd "$DOWNLOAD_DIR" && tar xfz arpack96.tar.gz)
  (cd "$DOWNLOAD_DIR" && tar xfz patch.tar.gz)
  cp libs/arpack.makefile "$DOWNLOAD_DIR/ARPACK"
  echo "done"
  echo -n "compiling ARPACK... "
  (cd "$DOWNLOAD_DIR/ARPACK" &&
    make -f arpack.makefile && 
    cp arpack.dll "$tbindir" &&
    cp arpack.lib "$tlibdir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/ARPACK"
  if ! test -f "$tbindir/arpack.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

###########
# libjpeg #
###########

echo -n "checking for libjpeg... "
if test ! -f "$tbindir/jpeg6b.dll"; then
  echo "no"
  download_file jpeg-6b-4-src.zip 'http://downloads.sourceforge.net/gnuwin32/jpeg-6b-4-src.zip?modtime=1116176612&big_mirror=0'
  echo -n "decompressing libjpeg... "
  (cd "$DOWNLOAD_DIR" && mkdir jpeg && cd jpeg && unzip -q ../jpeg-6b-4-src.zip)
  cp libs/libjpeg-6b.diff "$DOWNLOAD_DIR/jpeg"
  echo "done"
  (cd "$DOWNLOAD_DIR/jpeg" &&
    patch -p1 < libjpeg-6b.diff &&
    cd src/jpeg/6b/jpeg-6b-src &&
    nmake -f makefile.vc nodebug=1 &&
    cp jpeg6b.dll "$tbindir" &&
    cp jpeg.lib "$tlibdir" &&
    cp jconfig.h jerror.h jmorecfg.h jpeglib.h "$tincludedir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/jpeg"
  if test ! -f "$tbindir/jpeg6b.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

############
# libiconv #
############

echo -n "checking for libiconv... "
if test ! -f "$tbindir/iconv.dll"; then
  echo "no"
  download_file libiconv-1.11.tar.gz ftp://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.11.tar.gz
  echo -n "decompressing libiconv... "
  (cd "$DOWNLOAD_DIR" && tar xfz libiconv-1.11.tar.gz)
  cp libs/libiconv-1.11.diff "$DOWNLOAD_DIR/libiconv-1.11"
  echo "done"
  echo -n "compiling libiconv... "
  (cd "$DOWNLOAD_DIR/libiconv-1.11" &&
    patch -p1 < libiconv-1.11.diff &&
    nmake -f Makefile.msvc NO_NLS=1 DLL=1 MFLAGS=-MD PREFIX=$tdir_w32 IIPREFIX=$tdir_w32_1 &&
	cp lib/iconv.dll "$tbindir" &&
	cp lib/iconv.lib "$tlibdir" &&
	cp include/iconv.h "$tincludedir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/libiconv-1.11"
  if test ! -f "$tbindir/iconv.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

###########
# gettext #
###########

echo -n "checking for gettext... "
if test ! -f "$tbindir/intl.dll"; then
  echo "no"
  download_file gettext-0.15.tar.gz ftp://ftp.belnet.be/mirror/ftp.gnu.org/gnu/gettext/gettext-0.15.tar.gz
  echo -n "decompressing gettext... "
  (cd "$DOWNLOAD_DIR" && tar xfz gettext-0.15.tar.gz)
  cp libs/gettext-0.15.diff "$DOWNLOAD_DIR/gettext-0.15"
  echo "done"
  echo -n "compiling gettext... "
  (cd "$DOWNLOAD_DIR/gettext-0.15" &&
    patch -p1 < gettext-0.15.diff &&
    nmake -f Makefile.msvc DLL=1 MFLAGS=-MD PREFIX=$tdir_w32 IIPREFIX=$tdir_w32_1 &&
    cp gettext-tools/lib/gettextlib.dll gettext-tools/src/gettextsrc.dll "$tbindir" &&
    cp gettext-tools/src/msgfmt.exe gettext-tools/src/xgettext.exe gettext-tools/src/msgmerge.exe "$tbindir" &&
    cp gettext-runtime/intl/intl.dll "$tbindir" &&
    cp gettext-runtime/intl/intl.lib "$tlibdir" &&
    cp gettext-runtime/intl/libintl.h "$tincludedir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/gettext-0.15"
  if test ! -f "$tbindir/intl.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

#########
# cairo #
#########

echo -n "checking for cairo... "
if test ! -f "$tbindir/libcairo-2.dll"; then
  echo "no"
  download_file cairo-1.2.6.tar.gz http://cairographics.org/releases/cairo-1.2.6.tar.gz
  echo -n "decompressing cairo... "
  (cd "$DOWNLOAD_DIR" && tar xfz cairo-1.2.6.tar.gz)
  cp libs/cairo-1.2.6.diff "$DOWNLOAD_DIR/cairo-1.2.6"
  echo "done"
  echo "compiling cairo... "
  (cd "$DOWNLOAD_DIR/cairo-1.2.6" &&
    patch -p1 < cairo-1.2.6.diff &&
    make -f Makefile.win32 &&
    cp src/libcairo-2.dll "$tbindir" &&
    cp src/cairo.lib "$tlibdir" &&
    mkdir "$tincludedir/cairo" &&
    cp src/cairo.h src/cairo-features.h src/cairo-pdf.h src/cairo-ps.h src/cairo-svg.h src/cairo-win32.h "$tincludedir/cairo") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/cairo-1.2.6"
  if test ! -f "$tbindir/libcairo-2.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

##############
# glib/pango #
##############

echo -n "checking for glib/pango... "
if ! test -f "$tbindir/libglib-2.0-0.dll" -a -f "$tbindir/libpango-1.0-0.dll"; then
  echo "no"
  download_file glib-2.12.6.tar.gz ftp://ftp.gtk.org/pub/glib/2.12/glib-2.12.6.tar.gz
  echo -n "decompressing glib... "
  (cd "$DOWNLOAD_DIR" && tar xfz glib-2.12.6.tar.gz)
  cp libs/glib-2.12.6.diff "$DOWNLOAD_DIR/glib-2.12.6"
  echo "done"
  echo "compiling glib... "
  (cd "$DOWNLOAD_DIR/glib-2.12.6" &&
    patch -p1 < glib-2.12.6.diff &&
    nmake -f makefile.msc &&
    sed -e "s/^VCLIBS_PREFIX = .*/VCLIBS_PREFIX = $tdir_w32/" build/win32/module.defs > ttt &&
    mv ttt build/win32/module.defs &&
    nmake -f makefile.msc install) >&5 2>&1
  if test ! -f "$tbindir/libglib-2.0-0.dll"; then
    echo "failed"
    rm -rf "$download_dir/glib-1.12.6"
    exit -1
  else
    echo "done"
  fi
  download_file pango-1.14.9.tar.gz ftp://ftp.gtk.org/pub/pango/1.14/pango-1.14.9.tar.gz
  echo -n "decompressing pango... "
  (cd "$DOWNLOAD_DIR" && tar xfz pango-1.14.9.tar.gz)
  cp libs/pango-1.14.9.diff "$DOWNLOAD_DIR/pango-1.14.9"
  echo "done"
  echo "compiling pango... "
  (cd "$DOWNLOAD_DIR/pango-1.14.9" &&
    patch -p1 < pango-1.14.9.diff &&
    rm -f pango/module-defs-fc.c pango/module-defs-win32.c &&
    cd pango &&
    nmake -f makefile.msc &&
    cp libpango*.dll "$tbindir" &&
    cp pango*.lib "$tlibdir" &&
    rm -f "$tlibdir/pango*s.lib" &&
    mkdir -p "$tincludedir/pango-1.0/pango" &&
    cp pango.h pango-attributes.h pango-break.h pangocairo.h pango-context.h pango-coverage.h \
       pango-engine.h pango-enum-types.h pangofc-font.h pangofc-fontmap.h pango-font.h pango-fontmap.h \
       pango-fontset.h pango-glyph.h pango-glyph-item.h pango-item.h pango-layout.h pango-modules.h \
       pango-renderer.h pango-script.h pango-tabs.h pango-types.h pango-utils.h pangowin32.h "$tincludedir/pango-1.0/pango") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/glib-2.12.6"
  rm -rf "$DOWNLOAD_DIR/pango-1.14.9"
  if test ! -f "$tbindir/libpango-1.0-0.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

############
# freetype #
############

echo -n "checking for freetype... "
if test ! -f "$tbindir/freetype6.dll"; then
  echo "no"
  download_file freetype-2.3.1.tar.gz http://download.savannah.gnu.org/releases/freetype/freetype-2.3.1.tar.gz
  echo -n "decompressing freetype... "
  (cd "$DOWNLOAD_DIR" && tar xfz freetype-2.3.1.tar.gz)
  cp libs/freetype-2.3.1.diff "$DOWNLOAD_DIR/freetype-2.3.1"
  cp libs/freetype-config "$DOWNLOAD_DIR/freetype-2.3.1"
  echo "done"
  echo -n "compiling freetype... "
  (cd "$DOWNLOAD_DIR/freetype-2.3.1" &&
    patch -p1 < freetype-2.3.1.diff &&
    cd builds/win32/visualc &&
    vcbuild -u freetype.sln "Release Multithreaded|Win32" &&
    cd ../../.. &&
    cp objs/release_mt/freetype6.dll "$tbindir" &&
    cp objs/release_mt/freetype.lib "$tlibdir" &&
    cp include/ft2build.h "$tincludedir" &&
    mkdir -p "$tincludedir/freetype2" &&
    cp -r include/freetype "$tincludedir/freetype2" &&
    rm -rf "$tincludedir/freetype2/freetype/internal" &&
    sed -e "s,^prefix=.*,prefix=$tdir_w32_forward," freetype-config > "$tbindir/freetype-config") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/freetype-2.3.1"
  if test ! -f "$tbindir/freetype6.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

#########
# libgd #
#########

echo -n "checking for libgd... "
if test ! -f "$tbindir/bgd.dll"; then
  echo "no"
  download_file gd-2.0.34.tar.gz http://www.libgd.org/releases/oldreleases/gd-2.0.34.tar.gz
  echo -n "decompressing libgd... "
  (cd "$DOWNLOAD_DIR" && tar xfz gd-2.0.34.tar.gz)
  cp libs/gd-2.0.34.diff "$DOWNLOAD_DIR/gd-2.0.34"
  echo "done"
  echo -n "compiling libgd... "
  (cd "$DOWNLOAD_DIR/gd-2.0.34" &&
    patch -p1 < gd-2.0.34.diff &&
    cd windows &&
    sed -e "s,^FREETYPE_INC =.*,FREETYPE_INC = $tdir_w32_forward/include/freetype2," Makefile > ttt &&
    mv ttt Makefile &&
    nmake &&
    cp bgd.dll "$tbindir" &&
    cp bgd.lib "$tlibdir" &&
    cp ../*.h "$tincludedir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/gd-2.0.34"
  if test ! -f "$tbindir/bgd.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

##########
# libgsl #
##########

echo -n "checking for libgsl... "
if test ! -f "$tbindir/libgsl.dll"; then
  echo "no"
  download_file gsl-1.8-src.zip 'http://downloads.sourceforge.net/gnuwin32/gsl-1.8-src.zip?modtime=1152659851&big_mirror=0'
  echo -n "decompressing libgsl... "
  (cd "$DOWNLOAD_DIR" && mkdir gsl && cd gsl && unzip -q ../gsl-1.8-src.zip)
  echo "done"
  echo -n "compiling libgsl... "
  (cd "$DOWNLOAD_DIR/gsl/src/gsl/1.8/gsl-1.8/VC8" &&
    sed -e 's,ImportLibrary=.*,ImportLibrary="$(TargetDir)gsl.lib",' -e 's,<Files>,<Files><File RelativePath="..\\..\\version.c"></File>,' \
      libgsl/libgsl.vcproj > ttt &&
    mv ttt libgsl/libgsl.vcproj &&
    sed -e 's,ImportLibrary=.*,ImportLibrary="$(TargetDir)gslcblas.lib",' libgslcblas/libgslcblas.vcproj > ttt &&
    mv ttt libgslcblas/libgslcblas.vcproj &&
    vcbuild -u libgsl.sln "Release-DLL|Win32" &&
    mkdir -p "$tincludedir/gsl" &&
    cp ../gsl/gsl_*.h "$tincludedir/gsl" &&
    cp libgsl/Release-DLL/gsl.lib libgslcblas/Release-DLL/gslcblas.lib "$tlibdir" &&
    cp libgsl/Release-DLL/libgsl.dll libgslcblas/Release-DLL/libgslcblas.dll "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/gsl"
  if test ! -f "$tbindir/libgsl.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

##########
# netcdf #
##########

echo -n "checking for netcdf... "
if test ! -f "$tbindir/netcdf.dll"; then
  echo "no"
  download_file netcdf-3.6.1.tar.gz ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-3.6.1.tar.gz
  echo -n "decompressing netcdf... "
  (cd "$DOWNLOAD_DIR" && tar xfz netcdf-3.6.1.tar.gz)
  echo "done"
  echo -n "compiling netcdf... "
  (cd "$DOWNLOAD_DIR/netcdf-3.6.1" &&
    cd src/win32/NET &&
    sed -e 's/RuntimeLibrary=.*/RuntimeLibrary="2"/' libsrc/netcdf.vcproj > ttt &&
    mv ttt libsrc/netcdf.vcproj &&
    cd libsrc &&
    vcbuild -u netcdf.vcproj "Release|Win32" &&
    cp Release/netcdf.lib "$tlibdir" &&
    cp ../../../libsrc/netcdf.h "$tincludedir" &&
    cp Release/netcdf.dll "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/netcdf-3.6.1"
  if test ! -f "$tbindir/netcdf.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

#######
# sed #
#######

echo -n "checking for sed... "
if test ! -f "$tbindir/sed.exe"; then
  echo "no"
  download_file sed-4.1.5.tar.gz ftp://ftp.gnu.org/gnu/sed/sed-4.1.5.tar.gz
  echo -n "decompressing sed... "
  (cd "$DOWNLOAD_DIR" && tar xfz sed-4.1.5.tar.gz)
  cp libs/sed-4.1.5.diff "$DOWNLOAD_DIR/sed-4.1.5"
  echo "done"
  echo -n "compiling sed... "
  (cd "$DOWNLOAD_DIR/sed-4.1.5" &&
    patch -p1 < sed-4.1.5.diff &&
    CC=cc-msvc CFLAGS="-O2 -MD -DWIN32 -D_WIN32 -DHAVE_FCNTL_H" ./configure --without-included-gettext &&
    make &&
    cp sed/sed.exe "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/sed-4.1.5"
  if test ! -f "$tbindir/sed.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

############
# makeinfo #
############

echo -n "checking for makeinfo... "
if test ! -f "$tbindir/makeinfo.exe"; then
  echo "no"
  download_file texinfo-4.8a.tar.gz ftp://ftp.gnu.org/gnu/texinfo/texinfo-4.8a.tar.gz
  echo -n "decompressing makeinfo... "
  (cd "$DOWNLOAD_DIR" && tar xfz texinfo-4.8a.tar.gz)
  cp libs/texinfo-4.8a.diff "$DOWNLOAD_DIR/texinfo-4.8"
  echo "done"
  echo -n "compiling makeinfo... "
  (cd "$DOWNLOAD_DIR/texinfo-4.8" &&
    patch -p1 < texinfo-4.8a.diff &&
    CC=cc-msvc CFLAGS="-O2 -MD -DWIN32 -D_WIN32" ./configure --without-included-gettext &&
    make -C lib &&
    make -C makeinfo &&
    cp makeinfo/makeinfo.exe "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/texinfo-4.8"
  if test ! -f "$tbindir/makeinfo.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi

#########
# units #
#########

echo -n "checking for units... "
if test ! -f "$tbindir/units.exe"; then
  echo "no"
  download_file units-1.86.tar.gz ftp://ftp.gnu.org/gnu/units/units-1.86.tar.gz
  echo -n "decompressing units... "
  (cd "$DOWNLOAD_DIR" && tar xfz units-1.86.tar.gz)
  cp libs/units-1.86.diff "$DOWNLOAD_DIR/units-1.86"
  echo "done"
  echo -n "compiling units... "
  (cd "$DOWNLOAD_DIR/units-1.86" &&
    patch -p1 < units-1.86.diff
    nmake -f Makefile.dos
    cp units.exe units.dat "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/units-1.86"
  if test ! -f "$tbindir/units.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
else
  echo "installed"
fi
