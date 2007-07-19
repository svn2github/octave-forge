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

machine_name=`uname -n`

if test "$machine_name" = "MACROCK"; then
  INSTALL_DIR=/c/Temp/vclibs_tmp
  CYGWIN_DIR=/c/Software/cygwin
  NSI_DIR=/c/Software/NSIS
else
  INSTALL_DIR=/d/Temp/vclibs_tmp
  CYGWIN_DIR=/d/Software/cygwin
  WGET_FLAGS="-e http_proxy=http://webproxy:8123 -e ftp_proxy=http://webproxy:8123"
  NSI_DIR=/d/Software/NSIS
fi
DOWNLOAD_DIR=downloaded_packages
DOATLAS=false

verbose=false
packages=
available_packages="f2c libf2c BLAS LAPACK ATLAS FFTW PCRE GLPK readline zlib SuiteSparse
HDF5 glob libpng ARPACK libjpeg libiconv gettext cairo glib pango freetype libgd libgsl
netcdf sed makeinfo units less CLN GiNaC wxWidgets gnuplot FLTK octave JOGL forge qhull
VC octplot"
octave_version=
of_version=
do_nsi=false
do_nsiclean=true
#download_root="http://downloads.sourceforge.net/octave/@@?download"
download_root="http://www.dbateman.org/octave/hidden/@@"

###################################################################################

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

todo_packages=

while test $# -gt 0; do
  case "$1" in
    -v | --verbose)
      verbose=true
      ;;
    -a | --atlas)
      DOATLAS=true
      ;;
    -f | --force)
	  todo_packages="$available_packages"
      ;;
    --release=*)
      octave_version=`echo $1 | sed -e 's/--release=//'`
      ;;
    --forge=*)
      of_version=`echo $1 | sed -e 's/--forge=//'`
      ;;
    --nsi | --nsi=*)
      do_nsi=true
      nsiarg=`echo $1 | sed -e 's/--nsi=//'`
      case $nsiarg in
        keep)
          do_nsiclean=false
          ;;
        clean)
          do_nsiclean=true
          ;;
      esac
      ;;
    -*)
      echo "unknown flag: $1"
      exit -1
      ;;
    *)
      if ! `echo $available_packages | grep -e $1 > /dev/null`; then
        echo "unknown package: $1"
        exit -1
      fi
      if test -z "$packages"; then
        packages="$1"
      else
        packages="$packages $1"
      fi
      ;;
  esac
  shift
done

if $verbose; then
  exec 5>&1
else
  WGET_FLAGS="$WGET_FLAGS -q"
  exec 5>/dev/null
fi

function check_package
{
  pack=$1
  if ! `echo $available_packages | grep -e $pack > /dev/null`; then
    echo "check_package: unknown package: $pack"
    exit -1
  fi
  if test ! -z "$packages"; then
    found=`echo "$packages" | grep -e $pack`
    if test ! -z "$found"; then
      echo "processing $pack... "
      return 0
    fi
  fi
  echo "skipping $pack... "
  return -1
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
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/include"
mkdir -p "$INSTALL_DIR/license"
echo "done"

tbindir="$INSTALL_DIR/bin"
tlibdir="$INSTALL_DIR/lib"
tincludedir="$INSTALL_DIR/include"
tlicdir="$INSTALL_DIR/license"
# Add $tbindir to PATH, but re-add "/usr/bin" in front to be sure
# we're using the MSYS sed version; MSVC-compiled version does not
# accept single-quoted arguments.
PATH=/usr/bin:$tbindir:$PATH
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

function todo_check
{
  path=$1
  name=$2
  if ! `echo $available_packages | grep -e $name > /dev/null`; then
    echo "todo_check: unknown package: $name"
    exit -1
  fi
  echo -n "checking for $name... "
  if test ! -f "$path"; then
    echo "no";
    packages="$packages $name"
  else
    echo "installed"
  fi
}

if test -z "$todo_packages"; then
  if test -z "$packages"; then
    todo_check "$tbindir/Microsoft.VC80.CRT/Microsoft.VC80.CRT.manifest" VC
    todo_check "$tbindir/f2c.exe" f2c
    todo_check "$tlibdir/f2c.lib" libf2c
    todo_check "$tbindir/blas.dll" BLAS
    todo_check "$tbindir/lapack.dll" LAPACK
    if $DOATLAS; then
      echo -n "checking for ATLAS... "
      atl_dlls=`find "$tbindir" -name "blas_atl_*.dll"`
      if test -z "$atl_dlls"; then
        echo "no"
        packages="$packages ATLAS"
      else
        echo "installed"
      fi
    fi
    todo_check "$tbindir/libfftw3-3.dll" FFTW
    todo_check "$tbindir/pcre70.dll" PCRE
    todo_check "$tbindir/glpk_4_19.dll" GLPK
    todo_check "$tbindir/readline.dll" readline
    todo_check "$tbindir/zlib1.dll" zlib
    todo_check "$tlibdir/cxsparse.lib" SuiteSparse
    todo_check "$tbindir/hdf5.dll" HDF5
    todo_check "$tlibdir/glob.lib" glob
    todo_check "$tlibdir/png.lib" libpng
    todo_check "$tbindir/arpack.dll" ARPACK
    todo_check "$tbindir/jpeg6b.dll" libjpeg
    todo_check "$tbindir/iconv.dll" libiconv
    todo_check "$tbindir/intl.dll" gettext
    todo_check "$tbindir/libcairo-2.dll" cairo
    todo_check "$tbindir/libglib-2.0-0.dll" glib
    todo_check "$tbindir/libpango-1.0-0.dll" pango
    todo_check "$tbindir/freetype6.dll" freetype
    todo_check "$tbindir/bgd.dll" libgd
    todo_check "$tbindir/libgsl.dll" libgsl
    todo_check "$tbindir/netcdf.dll" netcdf
    todo_check "$tbindir/sed.exe" sed
    todo_check "$tbindir/makeinfo.exe" makeinfo
    todo_check "$tbindir/units.exe" units
    todo_check "$tbindir/less.exe" less
    todo_check "$tlibdir/cln.lib" CLN
    todo_check "$tlibdir/ginac.lib" GiNaC
    todo_check "$tlibdir/wxmsw28.lib" wxWidgets
    todo_check "$tbindir/pgnuplot.exe" gnuplot
    todo_check "$tbindir/fltkdll.dll" FLTK
    if test ! -z "$octave_version"; then
      todo_check "$INSTALL_DIR/local/octave-$octave_version/bin/octave.exe" octave
      todo_check "$INSTALL_DIR/local/octave-$octave_version/share/octplot/oct/octplot.exe" octplot
    fi
    if test ! -z "$of_version"; then
      packages="$packages forge"
    fi
    todo_check "$tbindir/jogl.jar" JOGL
    todo_check "$tlibdir/qhull.lib" qhull
  fi
else
  packages="$todo_packages"
fi

if test -z "$octave_version"; then
  packages=`echo $packages | sed -e 's/octave//'`
fi

if test -z "$of_version"; then
  packages=`echo $packages | sed -e 's/forge//'`
fi

if ! $do_nsi && test -z "$packages"; then
  echo "nothing to do"
  exit 0
else
  echo "***********************************"
  if test ! -z "$packages"; then
    echo "installing packages:"
    for pack in $packages; do
      echo "  $pack"
    done
  fi
  if $do_nsi; then
    echo "creating installer"
  fi
  echo "***********************************"
fi

######
# VC #
######

if check_package VC; then
  msvc=`ls /c/WINDOWS/WinSxS/*/msvcr80.dll 2> /dev/null`
  if test -z "$msvc"; then
    echo "cannot find VC++ runtime libraries"
    exit -1
  fi
  msvc_path=`echo $msvc | sed -e 's,/msvcr80.dll$,,'`
  mkdir -p "$tbindir/Microsoft.VC80.CRT"
  cp $msvc_path/*.dll "$tbindir/Microsoft.VC80.CRT"
  cat > "$tbindir/Microsoft.VC80.CRT/Microsoft.VC80.CRT.manifest" << EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!-- Copyright © 1981-2001 Microsoft Corporation -->
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
    <noInheritable/>
    <assemblyIdentity 
        type="win32" 
        name="Microsoft.VC80.CRT" 
        version="8.0.50608.0" 
        processorArchitecture="x86" 
        publicKeyToken="1fc8b3b9a1e18e3b"
    />
    <file name="msvcr80.dll"/>
    <file name="msvcp80.dll"/>
    <file name="msvcm80.dll"/>
</assembly>
EOF
  if test ! -f "$tbindir/Microsoft.VC80.CRT/Microsoft.VC80.CRT.manifest"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#######
# f2c #
#######

if check_package f2c; then
  download_file f2c.exe.gz http://www.netlib.org/f2c/mswin/f2c.exe.gz
  echo -n "decompressing f2c... "
  gzip -d -c "$DOWNLOAD_DIR/f2c.exe.gz" > "$tbindir/f2c.exe"
  echo "done"
fi

##########
# libf2c #
##########

if check_package libf2c; then
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
fi

########
# BLAS #
########

if check_package BLAS; then
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
fi

##########
# LAPACK #
##########

if check_package LAPACK; then
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
fi

#########
# ATLAS #
#########

if $DOATLAS && check_package ATLAS; then
  download_file atlas-3.6.0.tar.gz 'http://downloads.sourceforge.net/math-atlas/atlas3.6.0.tar.gz?modtime=1072051200&big_mirror=0'
  echo -n "decompressing ATLAS... "
  (cd "$DOWNLOAD_DIR" && tar xfz atlas-3.6.0.tar.gz)
  cp libs/atlas-3.6.0.diff "$DOWNLOAD_DIR/ATLAS"
  echo "done"
  echo -n "compiling ATLAS... "
  (cd "$DOWNLOAD_DIR/ATLAS" &&
    patch -p1 < atlas-3.6.0.diff &&
    start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login -i &&
	exit -1 &&
    start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && make xconfig && echo -n '' | ./xconfig -c mvc" &&
	arch=`ls Make.*_* | sed -e 's/Make\.//'` &&
	start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && make install arch=$arch" &&
	start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && cd lib/$arch && build_atlas_dll" &&
	cp lib/$arch/blas.dll "$tbindir/blas_atl_$arch.dll" &&
	cp lib/$arch/lapack.dll "$tbindir/lapack_atl_$arch.dll") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/ATLAS"
  atl_dlls=`find "$tbindir" -name "blas_atl_*.dll"`
  if test -z "$atl_dlls"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

########
# FFTW #
########

if check_package FFTW; then
  download_file fftw-3.1.2-dll.zip ftp://ftp.fftw.org/pub/fftw/fftw-3.1.2-dll.zip
  echo -n "decompressing FFTW... "
  (cd "$DOWNLOAD_DIR" && mkdir fftw3 && cd fftw3 && unzip -q ../fftw-3.1.2-dll.zip)
  echo "done"
  echo -n "installing FFTW ..."
  (cd "$DOWNLOAD_DIR/fftw3" &&
    cp fftw-wisdom.exe libfftw3-3.dll "$tbindir" && 
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
fi

########
# PCRE #
########

if check_package PCRE; then
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
fi

########
# GLPK #
########

if check_package GLPK; then
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
fi

############
# readline #
############

if check_package readline; then
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
fi

########
# zlib #
########

if check_package zlib; then
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
fi

###############
# SuiteSparse #
###############

if check_package SuiteSparse; then
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
fi

########
# HDF5 #
########

if check_package HDF5; then
  download_file hdf5-1.6.5.tar.gz ftp://ftp.hdfgroup.org/HDF5/current/src/hdf5-1.6.5.tar.gz
  echo -n "decompressing HDF5... "
  (cd "$DOWNLOAD_DIR" && tar xfz hdf5-1.6.5.tar.gz && mv hdf5-1.6.5 hdf5)
  (cd "$DOWNLOAD_DIR" && unzip -q hdf5/windows/all.zip)
  cp libs/hdf5.diff "$DOWNLOAD_DIR/hdf5"
  echo "done"
  echo -n "compiling HDF5... "
  (cd "$DOWNLOAD_DIR/hdf5" &&
    patch -p1 < hdf5.diff &&
    cd proj/hdf5dll &&
    vcbuild -u hdf5dll.vcproj "Release|Win32" &&
    cp Release/hdf5.lib "$tlibdir" &&
    cp Release/hdf5.dll "$tbindir" &&
    cp ../../COPYING "$tlicdir/COPYING.HDF5" &&
    cd ../../src &&
    cp H5public.h H5Apublic.h H5ACpublic.h H5Bpublic.h H5Cpublic.h           \
       H5Dpublic.h H5Epublic.h H5Fpublic.h H5FDpublic.h H5FDcore.h H5FDfamily.h \
       H5FDgass.h H5FDlog.h H5FDmpi.h H5FDmpio.h H5FDmpiposix.h              \
       H5FDmulti.h H5FDsec2.h H5FDsrb.h H5FDstdio.h H5FDstream.h             \
       H5Gpublic.h H5HGpublic.h H5HLpublic.h H5Ipublic.h                     \
       H5MMpublic.h H5Opublic.h H5Ppublic.h H5Rpublic.h H5Spublic.h          \
       H5Tpublic.h H5Zpublic.h H5pubconf.h hdf5.h H5api_adpt.h "$tincludedir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/hdf5"
  if test ! -f "$tbindir/hdf5.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

########
# glob #
########

if check_package glob; then
  if test ! -f "$DOWNLOAD_DIR/glob.tar.gz"; then
    echo "glob library is not downloadable and should already be present in $DOWNLOAD_DIR"
    exit -1
  fi
  echo -n "decompressing glob... "
  (cd "$DOWNLOAD_DIR" && tar xfz glob.tar.gz)
  echo "done"
  echo -n "compiling glob... "
  (cd "$DOWNLOAD_DIR/glob" &&
    autoconf && autoheader &&
    ./configure.vc &&
    make &&
    cp glob.lib "$tlibdir" &&
    cp fnmatch.h glob.h "$tincludedir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/glob"
  if test ! -f "$tlibdir/glob.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########
# libpng #
##########

if check_package libpng; then
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
fi

##########
# ARPACK #
##########

if check_package ARPACK; then
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
  wget $WGET_FLAGS -O "$tlicdir/COPYING.ARPACK.doc" http://www.caam.rice.edu/software/ARPACK/RiceBSD.doc
  if ! test -f "$tbindir/arpack.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# libjpeg #
###########

if check_package libjpeg; then
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
fi

############
# libiconv #
############

if check_package libiconv; then
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
fi

###########
# gettext #
###########

if check_package gettext; then
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
fi

#########
# cairo #
#########

if check_package cairo; then
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
fi

##############
# glib/pango #
##############

if check_package glib || check_package pango; then
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
  if check_package pango; then
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
    rm -rf "$DOWNLOAD_DIR/pango-1.14.9"
    if test ! -f "$tbindir/libpango-1.0-0.dll"; then
      echo "failed"
      exit -1
    else
      echo "done"
    fi
  fi
  rm -rf "$DOWNLOAD_DIR/glib-2.12.6"
fi

############
# freetype #
############

if check_package freetype; then
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
fi

#########
# libgd #
#########

if check_package libgd; then
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
    cp ../COPYING "$tlicdir/COPYING.LIBGD" &&
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
fi

##########
# libgsl #
##########

if check_package libgsl; then
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
fi

##########
# netcdf #
##########

if check_package netcdf; then
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
    cp ../../../COPYRIGHT "$tlicdir/COPYING.NETCDF" &&
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
fi

#######
# sed #
#######

if check_package sed; then
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
fi

############
# makeinfo #
############

if check_package makeinfo; then
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
fi

#########
# units #
#########

if check_package units; then
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
fi

########
# less #
########

if check_package less; then
  download_file less-394.zip http://www.greenwoodsoftware.com/less/less-394.zip
  echo -n "decompressing less... "
  (cd "$DOWNLOAD_DIR" && unzip -q less-394.zip)
  cp libs/less-394.diff "$DOWNLOAD_DIR/less-394"
  echo "done"
  echo -n "compiling less... "
  (cd "$DOWNLOAD_DIR/less-394" &&
    patch -p1 < less-394.diff && 
    nmake -f Makefile.wnm &&
    cp less.exe lesskey.exe "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/less-394"
  if test ! -f "$tbindir/less.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#######
# CLN #
#######

if check_package CLN; then
  download_file cln-1.1.13.tar.bz2 ftp://ftpthep.physik.uni-mainz.de/pub/gnu/cln-1.1.13.tar.bz2
  echo -n "decompressing CLN... "
  (cd "$DOWNLOAD_DIR" && tar xfj cln-1.1.13.tar.bz2)
  cp libs/cln-1.1.13.diff "$DOWNLOAD_DIR/cln-1.1.13"
  echo "done"
  echo -n "compiling CLN... "
  (cd "$DOWNLOAD_DIR/cln-1.1.13" &&
    patch -p1 < cln-1.1.13.diff &&
    CC=cc-msvc CFLAGS="-O2 -MD" CXX=cc-msvc CXXFLAGS="-O2 -EHs -MD" \
         CPPFLAGS="-DWIN32 -D_WIN32 -DASM_UNDERSCORE" AR=ar-msvc ./configure --prefix=$tdir_w32_forward &&
    make -C src &&
    make -C src install) >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/cln-1.1.13"
  if test ! -f "$tlibdir/cln.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#########
# GiNaC #
#########

if check_package GiNaC; then
  download_file ginac-1.3.6.tar.bz2 ftp://ftpthep.physik.uni-mainz.de/pub/GiNaC/ginac-1.3.6.tar.bz2
  echo -n "decompressing GiNaC... "
  (cd "$DOWNLOAD_DIR" && tar xfj ginac-1.3.6.tar.bz2)
  cp libs/ginac-1.3.6.diff "$DOWNLOAD_DIR/ginac-1.3.6"
  echo "done"
  echo -n "compiling GiNaC... "
  (cd "$DOWNLOAD_DIR/ginac-1.3.6" &&
    patch -p1 < ginac-1.3.6.diff &&
    CC=cc-msvc CFLAGS="-O2 -MD" CXX=cc-msvc CXXFLAGS="-O2 -EHs -MD" \
      CPPFLAGS="-DWIN32 -D_WIN32" AR=ar-msvc ./configure --disable-shared \
      --prefix=$tdir_w32_forward &&
    make -C ginac &&
    make -C ginsh &&
    make -C ginac install) >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/ginac-1.3.6"
  if test ! -f "$tlibdir/ginac.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#############
# wxWidgets #
#############

if check_package wxWidgets; then
  download_file wxMSW-2.8.4.tar.bz2 'http://downloads.sourceforge.net/wxwindows/wxMSW-2.8.4.tar.bz2?modtime=1179491919&big_mirror=0'
  echo -n "decompressing wxWidgets... "
  (cd "$DOWNLOAD_DIR" && tar xfj wxMSW-2.8.4.tar.bz2)
  cp libs/wxwidgets-2.8.0.diff "$DOWNLOAD_DIR/wxMSW-2.8.4"
  echo "done"
  echo -n "compiling wxWidgets... "
  (cd "$DOWNLOAD_DIR/wxMSW-2.8.4" &&
    patch -p1 < wxwidgets-2.8.0.diff &&
    cd build/msw &&
    nmake -f makefile.vc &&
    cd ../.. &&
    cp -r include/wx "$tincludedir" &&
    cp lib/vc_lib/*.lib "$tlibdir" &&
    cp lib/vc_lib/msw/wx/setup.h "$tincludedir/wx") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/wxMSW-2.8.4"
  if test ! -f "$tlibdir/wxmsw28.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# gnuplot #
###########

if check_package gnuplot; then
  download_file gnuplot-4.2.0.tar.gz 'http://downloads.sourceforge.net/gnuplot/gnuplot-4.2.0.tar.gz?modtime=1173003818&big_mirror=0'
  echo -n "decompressing gnuplot... "
  (cd "$DOWNLOAD_DIR" && tar xfz gnuplot-4.2.0.tar.gz)
  cp libs/gnuplot-4.2.0.diff "$DOWNLOAD_DIR/gnuplot-4.2.0"
  echo "done"
  echo -n "compiling gnuplot... "
  (cd "$DOWNLOAD_DIR/gnuplot-4.2.0" &&
    patch -p1 < gnuplot-4.2.0.diff &&
    sed -e "s,^DESTDIR =.*,DESTDIR = $tdir_w32," -e "s,^WXLOCATION =.*,WXLOCATION = $tdir_w32," \
      -e "s,^VCLIBS_ROOT =.*,VCLIBS_ROOT = $tdir_w32," config/makefile.nt > ttt &&
    mv ttt config/makefile.nt &&
    cd src &&
    nmake -f ../config/makefile.nt &&
    nmake -f ../config/makefile.nt install &&
    mkdir -p "$INSTALL_DIR/doc/gnuplot" &&
	cp "$INSTALL_DIR/Copyright" "$tlicdir/COPYING.GNUPLOT" &&
    mv "$INSTALL_DIR/BUGS" "$INSTALL_DIR/Copyright" "$INSTALL_DIR/FAQ" "$INSTALL_DIR/NEWS" "$INSTALL_DIR/README" \
      "$INSTALL_DIR/doc/gnuplot") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/gnuplot-4.2.0"
  download_file gp420win32.zip 'http://downloads.sourceforge.net/gnuplot/gp420win32.zip?modtime=1173777723&big_mirror=0'
  if test -f "$DOWNLOAD_DIR/gp420win32.zip"; then
    (cd "$DOWNLOAD_DIR" && unzip -o -q -j -d "$tbindir" gp420win32.zip gnuplot/bin/wgnuplot.hlp)
  else
    echo "WARNING: could not get wgnuplot.hlp"
  fi
  if test ! -f "$tbindir/pgnuplot.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

########
# FLTK #
########

if check_package FLTK; then
  download_file fltk-1.1.7-source.tar.gz 'ftp://ftp.rz.tu-bs.de/pub/mirror/ftp.easysw.com/ftp/pub/fltk/1.1.7/fltk-1.1.7-source.tar.gz'
  echo -n "decompressing FLTK... "
  (cd "$DOWNLOAD_DIR" && tar xfz fltk-1.1.7-source.tar.gz)
  cp libs/fltk-1.1.7.diff "$DOWNLOAD_DIR/fltk-1.1.7"
  echo "done"
  echo -n "compiling FLTK... "
  (cd "$DOWNLOAD_DIR/fltk-1.1.7" &&
    patch -p1 < fltk-1.1.7.diff &&
    cd vc2005 &&
    sed -e 's/@FL_MAJOR_VERSION@/1/' \
        -e 's/@FL_MINOR_VERSION@/1/' \
        -e 's/@FL_PATCH_VERSION@/7/' \
	-e "s,@prefix@,$tdir_w32_forward," \
	-e 's,@exec_prefix@,$prefix/bin,' \
	-e 's,@bindir@,$prefix/bin,' \
	-e 's,@includedir@,$prefix/include,' \
	-e 's,@libdir@,$prefix/lib,' \
	-e 's,@srcdir@,$prefix/src,' \
	-e 's/@CC@/cc-msvc/' \
	-e 's/@CXX@/cc-msvc/' \
	-e 's/@CFLAGS@/-MD -DWIN32 -DFL_DLL/' \
	-e 's/@CXXFLAGS@/-MD -DWIN32 -DFL_DLL/' \
	-e 's/@LDFLAGS@//' \
	-e 's/@LIBS@/-lws2_32/' \
	-e 's/@LIBNAME@//' \
	-e 's/@DSONAME@//' \
	-e 's/@DSOLINK@//' \
	-e 's/@SHAREDSUFFIX@/dll/' \
	-e 's/^ *LIBS=/#&/' \
	-e 's/-lfltk_gl\$SHAREDSUFFIX @GLLIB@/-lopengl32 -lglu32/' \
	-e 's/^ *LDSTATIC=/#&/' ../fltk-config.in > "$tbindir/fltk-config" &&
    vcbuild -u fltkdll.vcproj "Release|Win32" &&
    vcbuild -u fltk.lib.vcproj "Release|Win32" &&
    vcbuild -u fltkforms.vcproj "Release|Win32" &&
    vcbuild -u fltkimages.vcproj "Release|Win32" &&
    vcbuild -u fluid.vcproj "Release|Win32" &&
    cp ../COPYING "$tlicdir/COPYING.FLTK" &&
    cp ../test/fltkdll.lib "$tlibdir" &&
    cp ../fluid/fluid.exe "$tbindir" &&
    mkdir -p "$tincludedir/FL" &&
    cp ../FL/*.h ../FL/*.H "$tincludedir/FL" &&
    cp fltkdll.dll "$tbindir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/fltk-1.1.7"
  if test ! -f "$tbindir/fltkdll.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########
# octave #
##########

if check_package octave; then
  octave_prefix="$INSTALL_DIR/local/octave-$octave_version"
  download_file octave-$octave_version.tar.bz2 ftp://ftp.octave.org/pub/octave/octave-$octave_version.tar.bz2
  if test ! -d "$DOWNLOAD_DIR/octave-$octave_version"; then
    echo -n "decompressing octave... "
    (cd "$DOWNLOAD_DIR" && tar xfj octave-$octave_version.tar.bz2)
    if test -f libs/octave.diff; then
      cp libs/octave.diff octaverc.win "$DOWNLOAD_DIR/octave-$octave_version"
      (cd "$DOWNLOAD_DIR/octave-$octave_version" && patch -p1 < octave.diff)
    fi
    cp mkoctfile.cc.in octave-config.cc.in "$DOWNLOAD_DIR/octave-$octave_version"
    config_script="$DOWNLOAD_DIR/octave-$octave_version/configure"
    if grep 'extern "C" void exit (int);' "$config_script" 2>&1 > /dev/null; then
      echo "Pre-processing configure script..."
      sed -e "s/'extern \"C\" void exit (int);'/'extern \"C\" __declspec(noreturn dllimport) void exit (int);' 'extern \"C\" void exit (int);'/g" "$config_script" > configure.tmp
      mv configure.tmp "$config_script"
    fi
    echo "done"
  fi
  echo -n "compiling octave... "
  (cd "$DOWNLOAD_DIR/octave-$octave_version" &&
    sed -e 's/\(^.*SUBDIRS = .*\)doc examples$/\1 examples/' octMakefile.in > ttt &&
    mv ttt octMakefile.in &&
    if test ! -f "config.log"; then
      CC=cc-msvc CXX=cc-msvc CFLAGS=-O2 CXXFLAGS=-O2 NM="dumpbin -symbols" \
        ./configure --build=i686-pc-msdosmsvc --prefix="$octave_prefix" \
        --with-f2c --with-zlib=zlib
    fi &&
    if test ! -f "src/octave.exe"; then
      make
    fi &&
    make install &&
    mkdir -p "$octave_prefix/doc/PDF" &&
    for f in doc/faq/Octave-FAQ.pdf doc/interpreter/octave.pdf doc/interpreter/octave-a4.pdf \
      doc/liboctave/liboctave.pdf doc/refcard/refcard-a4.pdf doc/refcard/refcard-legal.pdf \
      doc/refcard/refcard-letter.pdf; do
      if test -f "$f"; then
        cp $f "$octave_prefix/doc/PDF"
      fi
    done &&
    for d in faq interpreter liboctave; do
      if test -d "doc/$d/HTML"; then
        mkdir -p "$octave_prefix/doc/HTML/$d"
        cp doc/$d/HTML/*.* "$octave_prefix/doc/HTML/$d"
      fi
    done &&
    cp COPYING "$tlicdir/COPYING.GPL" &&
    make -f octMakefile mkoctfile.exe octave-config.exe &&
    rm -f "$octave_prefix/bin/mkoctfile" "$octave_prefix/bin/mkoctfile-$octave_version" &&
    rm -f "$octave_prefix/bin/octave-config" "$octave_prefix/bin/octave-config-$octave_version" &&
    cp mkoctfile.exe "$octave_prefix/bin/mkoctfile.exe" &&
    cp mkoctfile.exe "$octave_prefix/bin/mkoctfile-$octave_version.exe" &&
    cp octave-config.exe "$octave_prefix/bin/octave-config.exe" &&
    cp octave-config.exe "$octave_prefix/bin/octave-config-$octave_version.exe" &&
    cp octaverc.win "$octave_prefix/share/octave/$octave_version/m/startup/octaverc"
    ) >&5 2>&1
  if test ! -f "$INSTALL_DIR/local/octave-$octave_version/bin/octave.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

########
# JOGL #
########

if check_package JOGL; then
  download_file jogl-1.1.0-windows-i586.zip 'http://download.java.net/media/jogl/builds/archive/jsr-231-1.1.0/jogl-1.1.0-windows-i586.zip'
  echo -n "decompressing JOGL... "
  (cd "$DOWNLOAD_DIR" && unzip -q jogl-1.1.0-windows-i586.zip)
  echo "done"
  echo -n "installing JOGL... "
  (cd "$DOWNLOAD_DIR/jogl-1.1.0-windows-i586" &&
    cp lib/*.dll lib/*.jar "$tbindir" &&
    cp COPYRIGHT.txt "$tlicdir/COPYING.JOGL" &&
    cat LICENSE-JOGL-1.1.0.txt >> "$tlicdir/COPYING.JOGL") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/jogl-1.1.0-windows-i586"
  if test ! -f "$tbindir/jogl.jar"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#########
# QHull #
#########

if check_package qhull; then
  download_file qhull-2003.1-src.tgz http://www.qhull.org/download/qhull-2003.1-src.tgz
  echo -n "decompressing qhull... "
  (cd "$DOWNLOAD_DIR" && tar xfz qhull-2003.1-src.tgz)
  cp libs/qhull-2003.1.diff "$DOWNLOAD_DIR/qhull-2003.1"
  echo "done"
  echo -n "compiling qhull... "
  (cd "$DOWNLOAD_DIR/qhull-2003.1" &&
    patch -p1 < qhull-2003.1.diff &&
    cd src &&
    make qhull.lib &&
    mkdir -p "$tincludedir/qhull" &&
    cp *.h "$tincludedir/qhull" &&
    cp qhull.lib "$tlibdir") >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/qhull-2003.1"
  if test ! -f "$tlibdir/qhull.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

################
# octave-forge #
################

function install_forge_packages
{
  pkgs="$1"
  dir=$2
  auto=$3
  for pack in $pkgs; do
    echo -n "checking for $pack... "
    found=`find "$oforge_prefix" -type d -a -name "$pack-*" -maxdepth 1`
    if test ! -z "$found"; then
      echo "installed"
    else
      echo "no"
      (cd "$DOWNLOAD_DIR/octave-forge-bundle-$of_version/$dir" &&
        packpack=`ls $pack-*` &&
        if test -z "$packpack"; then
          echo "no '$pack' package found"
          return -1
        else
          if test "$pack" = "java" -o "$pack" = "windows"; then
            auto_=-auto
          else
            auto_=$auto
          fi
          "$octave_prefix/bin/octave.exe" -q -f -H --eval "page_screen_output(0); pkg install $auto_ -verbose $packpack"
        fi)
      found=`find "$oforge_prefix" -type d -a -name "$pack-*" -maxdepth 1`
      if test ! -z "$found"; then
        echo "done"
      else
        echo "failed"
        return -1
      fi
    fi
  done
  return 0
}

extra_pkgs="fpl msh bim civil-engineering integration java jhandles mapping nan secs1d secs2d symband triangular tsa windows"
main_pkgs="signal audio combinatorics communications control econometrics fixed general geometry gsl ident image informationtheory io irsa linear-algebra miscellaneous nnet octcdf odebvp odepkg optim outliers physicalconstants plot polynomial specfun special-matrix splines statistics strings struct symbolic time"
lang_pkgs="pt_br"
nonfree_pkgs="arpack"

if check_package forge; then
  if test -z "$octave_version" || test ! -d "$INSTALL_DIR/local/octave-$octave_version"; then
    echo "no octave installed, cannot compile octave-forge"
    exit -1
  fi
  download_file octave-forge-bundle-$of_version.tar.gz "http://downloads.sourceforge.net/octave/octave-forge-bundle-$of_version.tar.gz?big_mirror=0"
  if test ! -d "$DOWNLOAD_DIR/octave-forge-bundle-$of_version"; then
    echo -n "decompressing octave-forge... "
    (cd "$DOWNLOAD_DIR" && tar xfz octave-forge-bundle-$of_version.tar.gz)
    echo "done"
  fi
  octave_prefix="$INSTALL_DIR/local/octave-$octave_version"
  oforge_prefix="$octave_prefix/share/octave/packages"
  if ! install_forge_packages "$main_pkgs" main -auto; then
    exit -1
  fi
  if ! install_forge_packages "$lang_pkgs" language -noauto; then
    exit -1
  fi
  if ! install_forge_packages "$nonfree_pkgs" nonfree -auto; then
    exit -1
  fi
  if ! install_forge_packages "$extra_pkgs" extra -noauto; then
    exit -1
  fi
fi

###########
# octplot #
###########

if check_package octplot; then
  if test -z "$octave_version" || test ! -d "$INSTALL_DIR/local/octave-$octave_version"; then
    echo "octave not installed, cannot process octplot"
    exit -1
  fi
  download_file octplot-0.4.0.tar.gz 'http://downloads.sourceforge.net/octplot/octplot-0.4.0.tar.gz?modtime=1179436297&big_mirror=0'
  echo -n "decompressing octplot... "
  (cd "$DOWNLOAD_DIR" && tar xfz octplot-0.4.0.tar.gz)
  cp libs/octplot-0.4.0.diff "$DOWNLOAD_DIR/octplot-0.4.0"
  echo "done"
  echo -n "compiling octplot... "
  octave_prefix="$INSTALL_DIR/local/octave-$octave_version"
  (cd "$DOWNLOAD_DIR/octplot-0.4.0" && 
    patch -p0 < octplot-0.4.0.diff &&
    PATH=$octave_prefix/bin:$PATH CC=cc-msvc CXX=cc-msvc CXXFLAGS="-O2 -EHs -D_CRT_SECURE_NO_DEPRECATE" \
      CFLAGS="-O2 -D_CRT_SECURE_NO_DEPRECATE" ./configure --build=i686-pc-msdosmsvc \
      --with-path=$octave_prefix \
      --with-opath=$octave_prefix/share/octplot/oct \
      --with-mpath=$octave_prefix/share/octplot/toggle \
      --with-octplotmpath=$octave_prefix/share/octplot/m \
      --with-fontpath=$octave_prefix/share/octplot/fonts &&
    PATH=$octave_prefix/bin:$PATH make &&
    make install) >&5 2>&1
  rm -rf "$DOWNLOAD_DIR/octplot-0.4.0"
  if test ! -f "$INSTALL_DIR/local/octave-$octave_version/share/octplot/oct/octplot.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########################
# NSI package generation #
##########################

isolated_packages="fpl msh bim civil-engineering integration mapping nan secs1d secs2d symband triangular tsa pt_br nnet"
isolated_sizes=

function get_nsi_additional_files()
{
  packname=$1
  case "$packname" in
    image)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\jpeg6b.dll\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libpng13.dll\""
      ;;
    octcdf)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\netcdf.dll\""
      echo "  SetOutPath \"\$INSTDIR\\license\""
      echo "  File \"\${VCLIBS_ROOT}\\license\\COPYING.NETCDF\""
      ;;
    gsl)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libgsl.dll\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libgslcblas.dll\""
      ;;
    arpack)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\arpack.dll\""
      echo "  SetOutPath \"\$INSTDIR\\license\""
      echo "  File \"\${VCLIBS_ROOT}\\license\\COPYING.ARPACK.doc\""
      ;;
    miscellaneous)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\units.exe\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\units.dat\""
      ;;
    msh)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${SOFTWARE_ROOT}\\Gmsh\\gmsh.exe\""
      echo "  SetOutPath \"\$INSTDIR\\license\""
      echo "  File /oname=COPYING.GMSH \"\${SOFTWARE_ROOT}\\Gmsh\\LICENSE.txt\""
      echo "  SetOutPath \"\$INSTDIR\\tools\\gmsh\""
      echo "  File /r /x gmsh.exe \"\${SOFTWARE_ROOT}\\Gmsh\\*.*\""
      ;;
  esac
}

function get_nsi_dependencies()
{
  packname=$1
  descfile="$2"
  sed -n -e 's/ *$//' \
         -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
         -e 's/^depends: *//p' "$descfile" | \
    awk -F ', ' '{c=split($0, s); for(n=1; n<=c; ++n) printf("%s\n", s[n]) }' | \
      sed -n -e 's/^octave.*$//' \
             -e 's/\([a-zA-Z0-9_]\+\) *\(( *\([<>]=\?\) *\([0-9]\+\.[0-9]\+\.[0-9]\+\) *) *\)\?/  !insertmacro CheckDependency "\1" "\4" "\3"/p'
}

function is_isolated
{
  pack=$1
  for ipack in $isolated_packages; do
    if test "$pack" = "$ipack"; then
      return 0
    fi
  done
  return -1
}

function create_nsi_entries()
{
  pkgs=`for d in $1; do echo $d; done | sort - | sed -e ':a;N;$!ba;s/\n/\ /g'`
  flag=$2
  op=$3
  for packname in $pkgs; do
    if test "$packname" = "jhandles"; then
      continue
    fi
    if is_isolated $packname; then
      isolated=true
    else
      isolated=false
    fi
    found=`find "$octave_prefix/share/octave/packages" -type d -a -name "$packname-*" -maxdepth 1`
    if test ! -z "$found"; then
      case $op in
        0)
          packdesc=`grep -e '^Name:' "$found/packinfo/DESCRIPTION" | sed -e 's/^Name *: *//'`
          packdesc_low=`echo $packdesc | sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
          packver=`grep -e '^Version:' "$found/packinfo/DESCRIPTION" | sed -e 's/^Version *: *//'`
          packinstdir=$packdesc_low-$packver
	  if $isolated; then
            flag_="/o"
          elif test "$packdesc_low" = "windows" -o "$packdesc_low" = "java" -o "$packdesc_low" = "arpack"; then
            flag_=
          else
            flag_=$flag
          fi
          if $isolated; then
            packfile="octave-$octave_version-$packname-$packver-setup.exe"
            packsize=`echo "$isolated_sizes" | sed -n -e "s/.*\\$$packname:\\([0-9]\\+\\)\\$.*/\\1/p"`
            echo "Section $flag_ \"$packdesc *\" SEC_$packname"
            echo "  AddSize $packsize"
            echo "  ClearErrors"
            echo "  IfFileExists \"\$EXEDIR\\$packfile\" local inet"
            echo "local:"
            echo "  ExecWait '\"\$EXEDIR\\$packfile\" /S /D=\$INSTDIR'"
            echo "  Goto done"
            echo "inet:"
            echo "  InitPluginsDir"
            echo "  InetLoad::load \"`echo $download_root | sed -e "s/@@/$packfile/"`\" \$PLUGINSDIR\\$packfile"
            echo "  Pop \$0"
            echo "  StrCmp \$0 \"OK\" +3 0"
            echo "  SetErrors"
            echo "  Goto done"
            echo "  ExecWait '\"\$PLUGINSDIR\\$packfile\" /S /D=\$INSTDIR'"
            echo "done:"
            echo "  IfErrors 0 +2"
            echo "  MessageBox MB_ICONSTOP|MB_OK \"Installation of package $packdesc failed\""
          else
            echo "Section $flag_ \"$packdesc\" SEC_$packname"
            echo "  SetOverwrite try"
            get_nsi_additional_files $packname
            echo "  SetOutPath \"\$INSTDIR\\share\\octave\\packages\\$packinstdir\""
            echo "  File /r \"\${OCTAVE_ROOT}\\share\\octave\\packages\\$packinstdir\\*\""
          fi
          echo "SectionEnd"
          ;;
        1)
          packinfo=`sed -e '/^ /{H;$!d;}' -e 'x;/^Description: /!d;' "$found/packinfo/DESCRIPTION" | \
            sed -e ':a;N;$!ba;s/\n */\ /g' | sed -e 's/^Description: //'`
          echo "  !insertmacro MUI_DESCRIPTION_TEXT \${SEC_$packname} \"$packinfo\""
          ;;
        2)
          sed -n -e 's/ *$//' \
                 -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' \
                 -e 's/^depends: *//p' \
              "$found/packinfo/DESCRIPTION" | \
            awk -F ', ' '{c=split($0, s); for(n=1; n<=c; ++n) printf("%s\n", s[n]) }' | \
            sed -n -e 's/^octave.*$//' \
                   -e "s/\([a-zA-Z0-9_]\+\) *\(( *\([<>]=\?\) *\([0-9]\+\.[0-9]\+\.[0-9]\+\) *) *\)\?/  !insertmacro CheckDependency \${SEC_$packname} \${SEC_\1}/p"
          ;;
      esac
    fi
  done
}

function create_nsi_package_file()
{
  packname=$1
  found=`find "$octave_prefix/share/octave/packages" -type d -a -name "$packname-*" -maxdepth 1`
  if test ! -z "$found"; then
    packdesc=`grep -e '^Name:' "$found/packinfo/DESCRIPTION" | sed -e 's/^Name *: *//'`
    packdesc_low=`echo $packdesc | sed -e 'y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/'`
    packver=`grep -e '^Version:' "$found/packinfo/DESCRIPTION" | sed -e 's/^Version *: *//'`
    if test -f "release-$octave_version/octave-$octave_version-$packname-$packver-setup.exe"; then
      return 0
    fi
    echo -n "creating installer for $packname... "
    mkdir -p "release-$octave_version"
    packinstdir=$packdesc_low-$packver
    packinfo=`sed -e '/^ /{H;$!d;}' -e 'x;/^Description: /!d;' "$found/packinfo/DESCRIPTION" | sed -e ':a;N;$!ba;s/\n */\ /g' | sed -e 's/^Description: //'`
    packfiles=`get_nsi_additional_files $packname`
    if test ! -z "$packfiles"; then
      echo "$packfiles" > octave_pkg_${packname}_files.nsi
      packfiles="!include \\\"octave_pkg_${packname}_files.nsi\\\""
    fi
    packdeps=`get_nsi_dependencies $packname "$found/packinfo/DESCRIPTION"`
    if test ! -z "$packdeps"; then
      echo "$packdeps" > octave_pkg_${packname}_deps.nsi
      packdeps="!include \\\"octave_pkg_${packname}_deps.nsi\\\""
    fi
	if test -f "$found/packinfo/.autoload"; then
      packautoload=1
    else
      packautoload=0
    fi
    sed -e "s/@PACKAGE_NAME@/$packname/" \
        -e "s/@PACKAGE_LONG_NAME@/$packdesc/" \
        -e "s/@PACKAGE_VERSION@/$packver/" \
        -e "s/@PACKAGE_INFO@/$packinfo/" \
        -e "s/@OCTAVE_VERSION@/$octave_version/" \
        -e "s/@VCLIBS_ROOT@/$tdir_w32/" \
        -e "s/@PACKAGE_FILES@/$packfiles/" \
        -e "s/@PACKAGE_DEPENDENCY@/$packdeps/" \
        -e "s/@PACKAGE_AUTOLOAD@/$packautoload/" \
        -e "s/@SOFTWARE_ROOT@/$software_root/" octave_package.nsi.in > octave_pkg_$packname.nsi
    $NSI_DIR/makensis.exe octave_pkg_$packname.nsi | tee nsi.tmp >&5 2>&1
	packsize=`sed -n -e 's,^Install data: *[0-9]\+ / \([0-9]\+\) bytes$,\1,p' nsi.tmp`
	let "packsize = packsize / 1024"
	rm -f nsi.tmp
    if $do_nsiclean; then
      rm -f octave_pkg_$packname*.nsi
    fi
    if test ! -f "octave-$octave_version-$packname-$packver-setup.exe"; then
      echo "failed"
      return -1
    else
      mv -f "octave-$octave_version-$packname-$packver-setup.exe" "release-$octave_version"
	  if test -z "$isolated_sizes"; then
        isolated_sizes="\$$packname:$packsize\$"
      else
        isolated_sizes="$isolated_sizes$packname:$packsize\$"
      fi
      echo "done"
      return 0
    fi
  fi
}

if $do_nsi; then
  if test -z "$octave_version" || test ! -d "$INSTALL_DIR/local/octave-$octave_version"; then
    echo "no octave or octave-forge installed, cannot create installer"
    exit -1
  fi
  if test ! -f "/c/WINDOWS/MSYS.INI"; then
    echo "MSYS not found"
    exit -1
  else
    msys_root=`sed -n -e '/^InstallPath=/ {s/InstallPath=//;s/\\\\/\\\\\\\\/g;p;}' /c/WINDOWS/MSYS.INI`
    if test ! -d "$msys_root"; then
      echo "MSYS not found"
      exit -1
    fi
  fi
  jhandles_version=`find "$INSTALL_DIR/local/octave-$octave_version/share/octave/packages" -type d -a -name "jhandles-*" -maxdepth 1`
  if test -d "$jhandles_version"; then
    jhandles_version=`echo "$jhandles_version" | sed -e 's/.*-\([0-9]\+\.[0-9]\+\.[0-9]\+\)$/\1/'`
  else
    echo "JHandles not found"
    exit -1
  fi
  software_root=
  for drive in c d; do
    if test -d "/$drive/Software"; then
      software_root="$drive:\\\\Software"
    fi
  done
  if test ! -d "$software_root"; then
    echo "Software directory not found"
    exit -1
  fi
  release_dir="release-$octave_version"
  mkdir -p "$release_dir"
  for pack in $isolated_packages; do
    if ! create_nsi_package_file $pack; then
      exit -1
    fi
  done
  if test ! -f "$release_dir/octave-$octave_version-setup.exe"; then
    if test ! -f "octave_main.nsi"; then
      echo -n "creating octave_main.nsi... "
      sed -e "s/@OCTAVE_VERSION@/$octave_version/" -e "s/@VCLIBS_ROOT@/$tdir_w32/" \
        -e "s/@MSYS_ROOT@/$msys_root/" -e "s/@JHANDLES_VERSION@/$jhandles_version/" \
        -e "s/@SOFTWARE_ROOT@/$software_root/" octave.nsi.in > octave_main.nsi
      echo "done"
    fi
    if test ! -f "octave_forge.nsi"; then
      echo -n "creating octave_forge.nsi... "
      echo "SectionGroup \"Main\" GRP_forge_main" > octave_forge.nsi
      create_nsi_entries "$main_pkgs" "" 0 >> octave_forge.nsi
      echo "SectionGroupEnd" >> octave_forge.nsi
      echo "SectionGroup \"Extra\" GRP_forge_extra" >> octave_forge.nsi
      create_nsi_entries "$extra_pkgs" "/o" 0 >> octave_forge.nsi
      echo "SectionGroupEnd" >> octave_forge.nsi
      echo "SectionGroup \"Language\" GRP_forge_lang" >> octave_forge.nsi
      create_nsi_entries "$lang_pkgs" "/o" 0 >> octave_forge.nsi
      echo "SectionGroupEnd" >> octave_forge.nsi
      echo "SectionGroup \"Others\" GRP_forge_others" >> octave_forge.nsi
      create_nsi_entries "$nonfree_pkgs" "" 0 >> octave_forge.nsi
      echo "SectionGroupEnd" >> octave_forge.nsi
      echo "done"
    fi
    if test ! -f "octave_forge_deps.nsi"; then
      echo -n "creating octave_forge_deps.nsi... "
      echo "# Dependency checking" > octave_forge_deps.nsi
      create_nsi_entries "$main_pkgs" "" 2 >> octave_forge_deps.nsi
      create_nsi_entries "$extra_pkgs" "" 2 >> octave_forge_deps.nsi
      create_nsi_entries "$lang_pkgs" "" 2 >> octave_forge_deps.nsi
      create_nsi_entries "$nonfree_pkgs" "" 2 >> octave_forge_deps.nsi
      echo "done"
    fi
    if test ! -f "octave_forge_desc.nsi"; then
      echo -n "creating octave_forge_desc.nsi... "
      echo "  !insertmacro MUI_DESCRIPTION_TEXT \${GRP_forge_main} \"\"" > octave_forge_desc.nsi
      echo "  !insertmacro MUI_DESCRIPTION_TEXT \${GRP_forge_extra} \"\"" >> octave_forge_desc.nsi
      echo "  !insertmacro MUI_DESCRIPTION_TEXT \${GRP_forge_lang} \"\"" >> octave_forge_desc.nsi
      echo "  !insertmacro MUI_DESCRIPTION_TEXT \${GRP_forge_others} \"\"" >> octave_forge_desc.nsi
      create_nsi_entries "$main_pkgs" "" 1 >> octave_forge_desc.nsi
      create_nsi_entries "$extra_pkgs" "" 1 >> octave_forge_desc.nsi
      create_nsi_entries "$lang_pkgs" "" 1 >> octave_forge_desc.nsi
      create_nsi_entries "$nonfree_pkgs" "" 1 >> octave_forge_desc.nsi
      echo "done"
    fi
    if test ! -f "$release_dir/octave-$octave_version-setup.exe"; then
      echo -n "creating installer for octave... "
      $NSI_DIR/makensis.exe octave_main.nsi
      if test ! -f "octave-$octave_version-setup.exe"; then
        echo "failed"
        exit -1
      else
        mv -f "octave-$octave_version-setup.exe" "$release_dir"
        echo "done"
      fi
    fi
    if $do_nsiclean; then
      rm -f octave_main.nsi octave_forge*.nsi
    fi
  fi
fi
