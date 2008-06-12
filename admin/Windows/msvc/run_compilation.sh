#!/bin/sh

###################################################################################
#
# Requirements
#	- Visual Studio (tested with VC++ Express 2005)
#	- MSYS shell
#	- MSYS Development Toolkit (DTK)
#	- MinGW
#	- wget (GnuWin32)
#	- unzip (GnuWin32)
#	- octave-forge CVS tree (at least the admin/Windows/msvc/ directory)
#	- cygwin with gcc (to compile ATLAS)
#   - CMake (to compile some specific packages)
#
###################################################################################

#################
# Configuration #
#################

machine_name=`uname -n`

if test "$machine_name" = "MACROCK"; then
  INSTALL_DIR=/c/Temp/vclibs_tmp
  #INSTALL_DIR=/c/Software/VCLibs
  CYGWIN_DIR=/c/Software/cygwin
  NSI_DIR=/c/Software/NSIS
else
  INSTALL_DIR=/d/Temp/vclibs_tmp
  CYGWIN_DIR=/d/Software/cygwin
  WGET_FLAGS="-e http_proxy=http://webproxy:8123 -e ftp_proxy=http://webproxy:8123"
  NSI_DIR=/d/Software/NSIS
fi
DOWNLOAD_DIR=downloaded_packages
OCTAVEDE_DIR=../../../../octavede-svn
DOATLAS=false

verbose=false
packages=
available_packages="f2c libf2c fort77 BLAS LAPACK ATLAS FFTW fftwf PCRE GLPK readline zlib SuiteSparse
HDF5 glob libpng ARPACK libjpeg libiconv gettext cairo glib pango freetype libgd libgsl
netcdf sed makeinfo units less CLN GiNaC wxWidgets gnuplot FLTK octave JOGL forge qhull
VC octplot ncurses pkg-config fc-msvc libcurl libxml2 fontconfig GraphicsMagick bzip2
ImageMagick libtiff libwmf jasper GTK ATK Glibmm Cairomm Gtkmm libsigc++ libglade
gtksourceview gdl VTE GtkGlArea PortAudio playrec OctaveDE Gtksourceview1 FTPlib
SQLite3 FFMpeg FTGL"
octave_version=
of_version=
do_nsi=false
do_nsiclean=true
do_octplot=false
do_gui=false
do_debug=false
download_root="http://downloads.sourceforge.net/octave/@@?download"
#download_root="http://www.dbateman.org/octave/hidden/@@"

# Package versions (the build instructions for those
# packages are version-independent)
lapackver=3.1.1
pcrever=7.4
curlver=7.16.4
libpngver=1.2.29
glpkver=4.23
gslver=1.10
netcdfver=3.6.2
cairover=1.4.10
glibver=2.14.3
pangover=1.19.0
ftver=2.3.5
libxml2ver=2.6.30
fontconfigver=2.5.0
gdver=2.0.35
hdf5ver=1.6.6
libiconvver=1.12
gettextver=0.17
gmagickver=1.1.10
bzip2ver=1.0.4
imagickver=6.3.8
tiffver=3.8.2
wmfver=0.2.8.4
jasperver=1.900.1
gtkver=2.12.9
atkver=1.22.0
glibmmver=2.14.2
cairommver=1.4.8
gtkmmver=2.12.5
libsigcver=2.0.18
libgladever=2.6.2
gtksourceviewver=2.2.0
gtksourceview1ver=1.8.5
gdlver=0.7.11
vtever=0.16.13
gtkglareaver=1.99.0
sqlite3ver=3.5.8
atlver=3.8.1
ftglver=2.1.2

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

function unpack_file
{
  filename=$1
  tarflag=
  case $filename in
    *.tar.gz | *.tgz)
      tarflag=z
      ;;
    *.tar.bz2)
      tarflag=j
      ;;
  esac
  (cd "$DOWNLOAD_DIR" &&
    tar xf$tarflag $filename)
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
    --atlas=*)
      DOATLAS=true
      atlver=`echo $1 | sed -e 's/--atlas=//'`
      ;;
    -f | --force)
      todo_packages="$available_packages"
      ;;
    -g)
      do_debug=true;
      ;;
    --release=*)
      octave_version=`echo $1 | sed -e 's/--release=//'`
      if test "$octave_version" = devel; then
        octave_version="vc8-debug"
      fi
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
    --octplot)
      do_octplot=true
      ;;
    --gui)
      do_gui=true
      ;;
    --prefix=*)
      INSTALL_DIR=`echo $1 | sed -e 's/--prefix=//'`
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

atlnum=`echo $atlver | sed -e 's/\.//g'`
build_flag=false

if $verbose; then
  exec 5>&1
else
  WGET_FLAGS="$WGET_FLAGS -q"
  exec 5>/dev/null
fi

W_CFLAGS="-O2 -MD"
W_CXXFLAGS="-O2 -MD -EHsc"
W_FCFLAGS="-O2 -MD"
W_FFLAGS="-O2 -MD"
W_LDFLAGS=
W_CPPFLAGS="-DWIN32 -D_WIN32 -D__WIN32__"
if $do_debug; then
  W_CFLAGS="-g -MD"
  W_CXXFLAGS="-g -MD -EHsc"
  W_FCFLAGS="-g -MD"
  W_FFLAGS="-g -MD"
  W_LDFLAGS="-Wl,-debug"
fi

function remove_package
{
  packdir="$1"
  if $build_flag; then
    if ! $do_debug; then
      rm -rf "$packdir"
    fi
  fi
}

function configure_package
{
  CC=cc-msvc CFLAGS="$W_CFLAGS" CXX=cc-msvc CXXFLAGS="$W_CXXFLAGS" FC=fc-msvc FCFLAGS="$W_FCFLAGS" \
    F77=fc-msvc FFLAGS="$W_FFLAGS" CPPFLAGS="$W_CPPFLAGS" AR=ar-msvc RANLIB=ranlib-msvc \
    LDFLAGS="$W_LDFLAGS" ./configure --prefix="$tdir_w32_forward" $*
}

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
      build_flag=false
      return 0
    fi
  fi
  echo "skipping $pack... "
  return -1
}

function end_package
{
  build_flag=true
}

function failed_package
{
  ! $build_flag
}

function check_cmake
{
  cmake=`which cmake.exe`
  if test -z "$cmake"; then
    echo "CMake not found in PATH"
    return -1
  fi
}

function create_module_rc
{
  module_name=$1
  module_version=$2
  module_filename=$3
  module_company="$4"
  module_desc="$5"
  module_copyright="$6"
  module_major=`echo $module_version | sed -e "s/\..*//"`
  module_minor=`echo $module_version | sed -e "s/^[^.]*\.//" -e "s/\..*//"`
  module_patch=`echo $module_version | sed -n -e "s/[0-9]\+\.[0-9]\+\.\([^.]*\).*/\1/p"`
  module_build=`echo $module_version | sed -n -e "s/[0-9]\+\.[0-9]\+\.[0-9]\+\.\([^.]*\).*/\1/p"`
  if test -z "$module_patch"; then
    module_patch=0
  fi
  if test -z "$module_build"; then
    module_build=0
  fi
  cat <<EOF
#define WINDOWS_LEAN_AND_MEAN
#include <windows.h>

VS_VERSION_INFO VERSIONINFO
FILEVERSION		$module_major, $module_minor, $module_patch, $module_build
PRODUCTVERSION	$module_major, $module_minor, $module_patch, $module_build
FILEFLAGSMASK	0x3fL
FILEFLAGS 0
FILEOS VOS_NT_WINDOWS32
FILETYPE VFT_APP
FILESUBTYPE VFT2_UNKNOWN
BEGIN
	BLOCK	"VarFileInfo"
	BEGIN
		VALUE	"Translation",	0x409,	1200
	END
	BLOCK	"StringFileInfo"
	BEGIN
		BLOCK "040904b0"
		BEGIN
			VALUE	"CompanyName",	"$module_company\\0"
			VALUE	"FileDescription",	"$module_desc\\0"
			VALUE	"FileVersion",	"$module_version\\0"
			VALUE	"InternalName",	"$module_name\\0"
			VALUE	"LegalCopyright",	"$module_copyright\\0"
			VALUE	"OriginalFilename",	"$module_filename\\0"
			VALUE	"ProductName",	"$module_name\\0"
			VALUE	"ProductVersion",	"$module_version\\0"
		END
	END
END
EOF
}

function post_process_libtool
{
  if test -z "$1"; then
    ltfile=libtool
  else
    ltfile="$1"
  fi
  sed -e '/#.*BEGIN LIBTOOL TAG CONFIG: CXX/,/#.*END LIBTOOL TAG CONFIG: CXX/ {/^archive_cmds=.*/,/^postinstall_cmds=.*/ {/^postinstall_cmds=.*/!d;};}' \
      -e 's,/OUT:,-OUT:,g' \
      -e 's/\$EGREP -e "\$export_symbols_regex"/$EGREP -e EXPORTS -e "$export_symbols_regex"/' \
      -e 's/egrep -e "\$export_symbols_regex"/egrep -e EXPORTS -e "$export_symbols_regex"/' \
      -e 's/^export_symbols_cmds="\(.*\) > \\\$export_symbols"/export_symbols_cmds="(echo EXPORTS; \1) > \\$export_symbols"/' \
      -e 's,^\([^=]*\)=.*cygpath.*$,\1="",g' \
      -e 's,-link -dll,-shared,g' \
      -e 's/^wl=.*$/wl="-Wl,"/' \
      -e 's/^deplibs_check_method=.*$/deplibs_check_method="pass_all"/' \
      -e 's,^archive_expsym_cmds=.*$,,' \
      -e 's,^archive_cmds=.*$,\0,p' \
      -e 's,^archive_cmds=\(.*\)$,archive_expsym_cmds=\1,' \
      -e '/^archive_expsym_cmds=/ {s,-shared,-shared ${wl}-def:\\$export_symbols,;}' \
      -e '/^library_names_spec=/ {s, \\$libname\.lib,,;}' \
      -e 's/S_IXUSR/S_IEXEC/g' \
      -e 's/^reload_flag=.*$/reload_flag=""/' \
      -e 's/^reload_cmds=.*$/reload_cmds="lib -OUT:\\$output\\$reload_objs"/' \
      -e 's/^old_archive_from_new_cmds=.*$/old_archive_from_new_cmds=""/' \
      -e '/testbindir=.*/ {a\
case $host in\
    *-*-mingw*)\
    	dir=`cd "$dir" && pwd`\
	;;\
esac
;}' \
-e "s,^postinstall_cmds=.*$,postinstall_cmds='if echo \"\$destdir\" | grep -e \\\\\"/lib/\\\\\\\\?\$\\\\\" >\& /dev/null; then name=\`echo \\\\\$file | sed -e \"s/.*\\\\///\" -e \"s/^lib//\" -e \"s/\\\\.la\$//\"\`; implibname=\`echo \\\\\$dlname | sed -e \"s/\\\\.dll/.lib/\"\`; \$install_prog \$dir/\\\\\$implibname \$destdir/\\\\\$name.lib; test -d \$destdir/../bin || mkdir -p \$destdir/../bin; mv -f \$destdir/\$dlname \$destdir/../bin; fi'," "$ltfile" > ttt &&
      mv ttt "$ltfile"
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
echo -n "checking for Visual Studio version... "
clver=`cl -? 2>&1 | sed -n -e 's/.*Compiler Version \([0-9]\+\).*/\1/p'`
crtver=
msvcver=
case $clver in
  14)
    crtver=80
    msvcver=2005
    echo "2005"
    ;;
  15)
    crtver=90
    msvcver=2008
    echo "2008"
    echo -n "registering vcprojectengine.dll... "
    regsvr32 -s "`which vcprojectengine.dll`"
    echo "done"
    ;;
  *)
    echo "unknown"
    echo "ERROR: unsupported Visual C++ compiler version: $clver"
    exit -1
    ;;
esac
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
tlibdir_quoted="${tlibdir// /\\ }"

INCLUDE="$tdir_w32_1\\include;$INCLUDE"
LIB="$tdir_w32_1\\lib;$LIB"

# Looking for java
echo -n "checking for Java Development Kit... "
jdkver=`reg query "HKLM\\\\Software\\\\JavaSoft\\\\Java Development Kit" //v CurrentVersion | sed -n -e 's/^.*REG_SZ[^0-9]*//p'`
if test -n "$jdkver"; then
  jdkhome=`reg query "HKLM\\\\Software\\\\JavaSoft\\\\Java Development Kit\\\\$jdkver" //v JavaHome | sed -n -e 's/^.*REG_SZ[^A-Za-z]*//p'`
  if test -n "$jdkhome" -a -d "$jdkhome"; then
    echo "$jdkver"
	jdkhome_msys=`cd "$jdkhome" && pwd`
	PATH="$jdkhome_msys/bin:$PATH"
	INCLUDE="$jdkhome\\include;$jdkhome\\include\\win32;$INCLUDE"
  else
    jdkhome=
  fi
fi
if test -z "$jdkhome"; then
  echo "none"
fi

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
  cat >> "$tincludedir/unistd.h" <<\EOF
#include <direct.h>
#include <process.h>
#include <io.h>
EOF
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
    todo_check "$tbindir/Microsoft.VC$crtver.CRT/Microsoft.VC$crtver.CRT.manifest" VC
    todo_check "$tbindir/f2c.exe" f2c
    todo_check "$tlibdir/f2c.lib" libf2c
    #todo_check "$tbindir/fort77" fort77
    todo_check "$tlibdir/blas.lib" BLAS
    todo_check "$tlibdir/lapack.lib" LAPACK
    if $DOATLAS; then
      echo -n "checking for ATLAS... "
      atl_dlls=`find "$tbindir" -name "libblas_atl${atlnum}_*.dll"`
      if test -z "$atl_dlls"; then
        echo "no"
        packages="$packages ATLAS"
      else
        echo "installed"
      fi
    fi
    todo_check "$tbindir/libfftw3-3.dll" FFTW
    todo_check "$tbindir/libfftw3f-3.dll" fftwf
    todo_check "$tlibdir/pcre.lib" PCRE
    todo_check "$tlibdir/glpk.lib" GLPK
    todo_check "$tlibdir/ncurses.lib" ncurses
    todo_check "$tlibdir/readline.lib" readline
    todo_check "$tbindir/zlib1.dll" zlib
    todo_check "$tlibdir/cxsparse.lib" SuiteSparse
    todo_check "$tlibdir/hdf5.lib" HDF5
    todo_check "$tlibdir/glob.lib" glob
    todo_check "$tlibdir/png.lib" libpng
    todo_check "$tlibdir/arpack.lib" ARPACK
    todo_check "$tlibdir/jpeg.lib" libjpeg
    todo_check "$tlibdir/iconv.lib" libiconv
    todo_check "$tlibdir/intl.lib" gettext
    todo_check "$tbindir/libcairo-2.dll" cairo
    todo_check "$tbindir/libglib-2.0-0.dll" glib
    todo_check "$tbindir/libpango-1.0-0.dll" pango
    todo_check "$tlibdir/xml2.lib" libxml2
    todo_check "$tlibdir/fontconfig.lib" fontconfig
    todo_check "$tlibdir/freetype.lib" freetype
    todo_check "$tlibdir/gd.lib" libgd
    todo_check "$tlibdir/gsl.lib" libgsl
    todo_check "$tlibdir/netcdf.lib" netcdf
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
      todo_check "$INSTALL_DIR/local/octave-$octave_version/libexec/octave/$octave_version/oct/i686-pc-msdosmsvc/playrec.mex" playrec
      if $do_octplot; then
        todo_check "$INSTALL_DIR/local/octave-$octave_version/share/octplot/oct/octplot.exe" octplot
      fi
      if $do_gui; then
        todo_check "$INSTALL_DIR/local/octave-$octave_version/bin/octavede.exe" OctaveDE
      fi
    fi
    if test ! -z "$of_version"; then
      packages="$packages forge"
    fi
    todo_check "$tbindir/jogl.jar" JOGL
    todo_check "$tlibdir/qhull.lib" qhull
    todo_check "$tbindir/pkg-config.exe" pkg-config
    todo_check "$tbindir/fc-msvc.exe" fc-msvc
    todo_check "$tbindir/libcurl.dll" libcurl
    todo_check "$tlibdir/bz2.lib" bzip2
    #todo_check "$tlibdir/GraphicsMagick.lib" GraphicsMagick
    todo_check "$tlibdir/Magick.lib" ImageMagick
    todo_check "$tlibdir/tiff.lib" libtiff
    todo_check "$tlibdir/wmf.lib" libwmf
    todo_check "$tlibdir/jasper.lib" jasper
    todo_check "$tbindir/libatk-1.0-0.dll" ATK
    todo_check "$tbindir/libgtk-win32-2.0-0.dll" GTK
    todo_check "$tlibdir/glibmm-2.4.lib" Glibmm
    todo_check "$tlibdir/cairomm-1.0.lib" Cairomm
    todo_check "$tlibdir/gtkmm-2.4.lib" Gtkmm
    todo_check "$tlibdir/sigc-2.0.lib" libsigc++
    todo_check "$tlibdir/glade-2.0.lib" libglade
    todo_check "$tlibdir/gtksourceview-2.0.lib" gtksourceview
    todo_check "$tlibdir/gdl-1.lib" gdl
    todo_check "$tlibdir/vte.lib" VTE
    todo_check "$tlibdir/gtkgl-2.0.lib" GtkGlArea
    todo_check "$tlibdir/ftp.lib" FTPlib
    todo_check "$tlibdir/sqlite3.lib" SQLite3
    todo_check "$tlibdir/avcodec.lib" FFMpeg
    todo_check "$tlibdir/ftgl.lib" FTGL
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
  msvc=`ls /c/WINDOWS/WinSxS/*/msvcr$crtver.dll 2> /dev/null | tail -n 1`
  if test -z "$msvc"; then
    echo "cannot find VC++ runtime libraries"
    exit -1
  fi
  msvc_path=`echo $msvc | sed -e "s,/msvcr$crtver.dll$,,"`
  msvc_name=`echo $msvc_path | sed -e 's,.*/,,'`
  mkdir -p "$tbindir/Microsoft.VC$crtver.CRT"
  cp $msvc_path/*.dll "$tbindir/Microsoft.VC$crtver.CRT"
  if true; then
    cp "/c/WINDOWS/WinSxS/Manifests/$msvc_name.manifest" "$tbindir/Microsoft.VC$crtver.CRT/Microsoft.VC$crtver.CRT.manifest"
  elif "$crtver" == "80"; then
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
  else
    echo "ERROR: don't have built-in manifest for CRT version $crtver"
    exit -1
  fi
  if test ! -f "$tbindir/Microsoft.VC$crtver.CRT/Microsoft.VC$crtver.CRT.manifest"; then
    echo "failed"
    exit -1
  else
    msvc_ver=`grep "version=" "$tbindir/Microsoft.VC$crtver.CRT/Microsoft.VC$crtver.CRT.manifest" | tail -n 1 | sed -e "s/.*version=\"\([^ ]*\)\".*/\1/"`
    echo "done (using version $msvc_ver)"
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
    cp -f vcf2c.lib "$tlibdir/f2c.lib") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/libf2c"
  if failed_package || test ! -f "$tlibdir/f2c.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########
# fort77 #
##########

if check_package fort77; then
  download_file fort77-1.18.tar.gz ftp://sunsite.unc.edu/pub/Linux/devel/lang/fortran/fort77-1.18.tar.gz
  echo -n "decompressing fort77... "
  (cd "$DOWNLOAD_DIR" && tar xfz fort77-1.18.tar.gz)
  echo "done"
  echo -n "installing fort77... "
  (cd "$DOWNLOAD_DIR/fort77-1.18" &&
    sed -e "s/, *\"-lm\" *//" -e "s/\/lib\/cpp/\$cc -E/" -e "s/\$verbose > 1/1/" \
      -e "s/|| 'cc'/|| 'cc-msvc'/" fort77 > ttt &&
    mv ttt fort77 &&
    cp fort77 "$tbindir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/fort77-1.18"
  if failed_package || test ! -f "$tbindir/fort77"; then
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
  download_file blas.tgz ftp://ftp.netlib.org/blas/blas.tgz
  unpack_file blas.tgz
  (cd "$DOWNLOAD_DIR" && tar xfz blas.tgz)
  echo -n "compiling BLAS... "
  cp libs/blas.makefile "$DOWNLOAD_DIR/BLAS"
  (cd "$DOWNLOAD_DIR/BLAS" &&
    sed -e "s/^OBJECTS =/OBJECTS = blas.res/" blas.makefile > ttt &&
    mv ttt blas.makefile &&
    echo "blas.res: blas.rc" >> blas.makefile &&
    echo "	rc -fo \$@ \$<" >> blas.makefile &&
    create_module_rc BLAS 1.0 blas.dll "Netlib (http://www.netlib.org)" \
      "BLAS F77 Reference Implementation" "Public Domain" > blas.rc &&
    make -f blas.makefile && 
    cp libblas.dll "$tbindir" &&
    cp blas.lib "$tlibdir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/BLAS"
  if failed_package || test ! -f "$tlibdir/blas.lib"; then
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
  download_file lapack-lite-$lapackver.tgz ftp://ftp.netlib.org/lapack/lapack-lite-$lapackver.tgz
  echo -n "decompressing LAPACK... "
  unpack_file lapack-lite-$lapackver.tgz
  echo "done"
  echo -n "compiling LAPACK... "
  cp libs/lapack.makefile "$DOWNLOAD_DIR/lapack-lite-$lapackver/SRC"
  (cd "$DOWNLOAD_DIR/lapack-lite-$lapackver/SRC" &&
    lapack_copyright=`grep -e '^Copyright' ../COPYING | head -n 1`
    create_module_rc LAPACK $lapackver lapack.dll "Netlib (http://www.netlib.org)" \
      "Lapack F77 Reference Implementation" "$lapack_copyright" > lapack.rc &&
    rc -fo lapack.res lapack.rc &&
    make -f lapack.makefile &&
    cp liblapack.dll "$tbindir" &&
    cp lapack.lib liblapack_f77.lib "$tlibdir" &&
    cp ../COPYING "$tlicdir/COPYING.LAPACK") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/lapack-lite-$lapackver"
  if failed_package || test ! -f "$tlibdir/lapack.lib"; then
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
  if test $atlnum -ge 380; then
    download_file atlas$atlver.tar.bz2 "http://downloads.sourceforge.net/math-atlas/atlas$atlver.tar.bz2?big_mirror=0"
    echo -n "decompressing ATLAS... "
    unpack_file atlas$atlver.tar.bz2
    cp check_cpu_flag.c "$DOWNLOAD_DIR/ATLAS"
    echo "done"
    echo "compiling ATLAS... (version $atlver)"
    (cd "$DOWNLOAD_DIR/ATLAS" &&
      cc-msvc -O2 -MT check_cpu_flag.c -luser32 -lshell32 &&
      SSE1=16 && SSE2=24 && SSE3=28 &&
      for arch in SSE1 SSE2 SSE3; do
        if check_cpu_flag $arch; then
          echo "compiling ATLAS for $arch..."
          (mkdir -p build_$arch && cd build_$arch &&
            start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login \
              -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && ../configure -V ${!arch} -Si nocygwin 1" &&
            atlarch=`sed -n -e 's/ *ARCH = \(.*\)$/\1/p' Make.inc` &&
            start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login \
              -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && make build" &&
            cd lib &&
            cc-msvc -shared -o libblas.dll -Wl,-def:$tdir_w32_forward/lib/atl_blas.def \
              -Wl,-implib:blas.lib libatlas.a libcblas.a libf77blas.a -lf2c &&
            cc-msvc -shared -o liblapack.dll -Wl,-def:$tdir_w32_forward/lib/lapack.def \
              -Wl,-implib:lapack.lib liblapack.a -lliblapack_f77 -L. -lblas -lf2c &&
            cp libblas.dll "$tbindir/libblas_atl${atlnum}_$atlarch.dll" &&
            cp liblapack.dll "$tbindir/liblapack_atl${atlnum}_$atlarch.dll") || break
        fi
      done) >&5 2>&1
  else
    download_file atlas-3.6.0.tar.gz 'http://downloads.sourceforge.net/math-atlas/atlas3.6.0.tar.gz?modtime=1072051200&big_mirror=0'
    echo -n "decompressing ATLAS... "
    (cd "$DOWNLOAD_DIR" && tar xfz atlas-3.6.0.tar.gz)
    cp libs/atlas-3.6.0.diff "$DOWNLOAD_DIR/ATLAS"
    echo "done"
    echo -n "compiling ATLAS... "
    (cd "$DOWNLOAD_DIR/ATLAS" &&
      patch -p1 < atlas-3.6.0.diff &&
      start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login \
        -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && make xconfig && echo -n '' | ./xconfig -c mvc" &&
    	arch=`ls Make.*_* | sed -e 's/Make\.//'` &&
    	start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login \
        -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && make install arch=$arch" &&
    	start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login \
        -c "cd `pwd -W | sed -e 's,/,\\\\\\\\\\\\\\\\,g'` && cd lib/$arch && build_atlas_dll" &&
    	cp lib/$arch/libblas.dll "$tbindir/libblas_atl${atlnum}_$arch.dll" &&
    	cp lib/$arch/liblapack.dll "$tbindir/liblapack_atl${atlnum}_$arch.dll") >&5 2>&1 && end_package
    fi
  remove_package "$DOWNLOAD_DIR/ATLAS"
  atl_dlls=`find "$tbindir" -name "libblas_atl${atlnum}_*.dll"`
  if failed_package || test -z "$atl_dlls"; then
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
  download_file pcre-$pcrever.tar.bz2 ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$pcrever.tar.bz2
  echo -n "decompressing PCRE... "
  unpack_file pcre-$pcrever.tar.bz2
  echo "done"
  echo -n "compiling PCRE... "
  pcre_desc="Perl Compatible Regular Expression Library"
  pcre_company="Philip Hazel <ph10@cam.ac.uk>"
  pcre_copyright=`grep -e '^Copyright' "$DOWNLOAD_DIR/pcre-$pcrever/LICENCE" | head -n 1`
  (cd "$DOWNLOAD_DIR/pcre-$pcrever" &&
    create_module_rc PCRE $pcrever pcre.dll "$pcre_company" "$pcre_desc" "$pcre_copyright" > pcre.rc &&
    if false && check_cmake; then
      sed -e "s/SET(PCRE_SOURCES/SET(PCRE_SOURCES pcre.rc/" CMakeLists.txt > ttt &&
        mv ttt CMakeLists.txt &&
      cmake -G "NMake Makefiles" -D BUILD_SHARED_LIBS:BOOL=ON \
            -D PCRE_NEWLINE:STRING=ANYCRLF \
            -D PCRE_SUPPORT_UNICODE_PROPERTIES:BOOL=ON \
            -D PCRE_BUILD_PCRECPP:BOOL=OFF \
            -D CMAKE_BUILD_TYPE:STRING=Release \
            -D "CMAKE_INSTALL_PREFIX:STRING=$tdir_w32_forward" . &&
      nmake &&
      nmake install
    else
      configure_package --enable-shared --disable-static \
        --disable-cpp --enable-unicode-properties --enable-newline-is-anycrlf &&
      post_process_libtool &&
      sed -e 's/^return !isdirectory(filename) *$/\0;/' pcregrep.c > ttt &&
        mv ttt pcregrep.c &&
      sed -e 's/libpcre_la_LDFLAGS =/libpcre_la_LDFLAGS = -Wl,pcre.res/' \
          -e 's/libpcre_la_OBJECTS =/libpcre_la_OBJECTS = pcre.res/' Makefile > ttt &&
        mv ttt Makefile &&
      echo "pcre.res: pcre.rc"  >> Makefile &&
      echo "	rc -fo \$@ \$<" >> Makefile &&
      make &&
      make install &&
	    rm -f $tlibdir_quoted/libpcre*.la
    fi) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/pcre-$pcrever"
  if failed_package || test ! -f "$tlibdir/pcre.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# fc-msvc #
###########

if check_package fc-msvc; then
  echo -n "compiling fc-msvc... "
  cl -nologo -MD -O2 -EHs fc-msvc.cc pcre.lib
  mt -outputresource:fc-msvc.exe -manifest fc-msvc.exe.manifest
  if ! test -f fc-msvc.exe; then
    echo "failed to compile fc-msvc.exe"
    exit -1
  fi
  mv -f fc-msvc.exe "$tbindir"
  rm -f fc-msvc.obj fc-msvc.exe.manifest
  echo "done"
fi

########
# FFTW #
########

if check_package FFTW; then
  download_file fftw-3.1.2.tar.gz ftp://ftp.fftw.org/pub/fftw/fftw-3.1.2.tar.gz
  echo -n "decompressing FFTW... "
  unpack_file fftw-3.1.2.tar.gz
  echo "done"
  echo -n "compiling FFTW ..."
  (cd "$DOWNLOAD_DIR/fftw-3.1.2" &&
    create_module_rc FFTW 3.1.2 libfftw3-3.dll "FFTW (www.fftw.org)" \
      "FFTW - Discrete Fourier Transform Computation Library" \
      "Copyright (c) 2003, 2006 Massachusetts Institute of Technology" > fftw.rc &&
    CC=cc-msvc CFLAGS="-O2 -MD" CXX=cc-msvc CXXFLAGS="-O2 -MD" FC=fc-msvc FCFLAGS="-O2 -MD" \
      F77=fc-msvc FFLAGS="-O2 -MD" CPPFLAGS="-DWIN32 -D_WIN32" AR=ar-msvc RANLIB=ranlib-msvc \
      ./configure --prefix="$tdir_w32_forward" --enable-shared --disable-static \
      --enable-sse2 &&
    post_process_libtool &&
    sed -e 's/^libfftw3_la_LDFLAGS =/libfftw3_la_LDFLAGS = -Wl,fftw.res -Wl,-def:fftw.def/' \
        -e 's/^libfftw3\.la:/libfftw3.la: fftw.res fftw.def/' Makefile > ttt &&
      mv ttt Makefile &&
    (cat >> Makefile <<\EOF
fftw.res: fftw.rc
	rc -fo $@ $<
fftw.def: $(libfftw3_la_OBJECTS) $(libfftw3_la_LIBADD)
	@echo "Generating $@..."
	@echo "EXPORTS" > $@
	@sublibs=; for lib in $(libfftw3_la_LIBADD); do \
	    sublibs="$$sublibs `dirname $$lib`/.libs/`sed -n -e "s/old_library='\(.*\)'/\1/p" $$lib`"; \
	  done;\
	nm $(addprefix .libs/, $(libfftw3_la_OBJECTS:.lo=.o)) $$sublibs | \
          grep -v -e ' R __real@[0-9a-fA-F]\+' | \
	  sed -n -e 's/^[0-9a-fA-F]\+ T _\([^         ]*\).*$$/\1/p' \
	         -e 's/^[0-9a-fA-F]\+ [BDGSR] _\([^         ]*\).*$$/\1 DATA/p' >> $@
EOF
      ) &&
    sed -e 's/^LDFLAGS =/LDFLAGS = -Wl,-subsystem:console/' tools/Makefile > ttt &&
      mv ttt tools/Makefile &&
    sed -e 's/^LDFLAGS =/LDFLAGS = -Wl,-subsystem:console/' \
        -e 's/^DEFS =/DEFS = -DFFTW_DLL/' tests/Makefile > ttt &&
      mv ttt tests/Makefile &&
    sed -e 's/^AR =.*$/AR = ar/' libbench2/Makefile > ttt &&
      mv ttt libbench2/Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libfftw3.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/fftw-3.1.2"
  if failed_package|| test ! -f "$tbindir/libfftw3-3.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

if check_package fftwf; then
  download_file fftw-3.1.2.tar.gz ftp://ftp.fftw.org/pub/fftw/fftw-3.1.2.tar.gz
  echo -n "decompressing FFTW... "
  unpack_file fftw-3.1.2.tar.gz
  echo "done"
  echo -n "compiling FFTW (float)..."
  (cd "$DOWNLOAD_DIR/fftw-3.1.2" &&
    create_module_rc FFTW 3.1.2 libfftw3f-3.dll "FFTW (www.fftw.org)" \
      "FFTW - Discrete Fourier Transform Computation Library (float precision)" \
      "Copyright (c) 2003, 2006 Massachusetts Institute of Technology" > fftwf.rc &&
    CC=cc-msvc CFLAGS="-O2 -MD" CXX=cc-msvc CXXFLAGS="-O2 -MD" FC=fc-msvc FCFLAGS="-O2 -MD" \
      F77=fc-msvc FFLAGS="-O2 -MD" CPPFLAGS="-DWIN32 -D_WIN32" AR=ar-msvc RANLIB=ranlib-msvc \
      ./configure --prefix="$tdir_w32_forward" --enable-shared --disable-static \
      --enable-sse --enable-float &&
    post_process_libtool &&
    sed -e 's/^libfftw3f_la_LDFLAGS =/libfftw3f_la_LDFLAGS = -Wl,fftwf.res -Wl,-def:fftwf.def/' \
        -e 's/^libfftw3f\.la:/libfftw3f.la: fftwf.res fftwf.def/' Makefile > ttt &&
      mv ttt Makefile &&
    (cat >> Makefile <<\EOF
fftwf.res: fftwf.rc
	rc -fo $@ $<
fftwf.def: $(libfftw3f_la_OBJECTS) $(libfftw3f_la_LIBADD)
	@echo "Generating $@..."
	@echo "EXPORTS" > $@
	@sublibs=; for lib in $(libfftw3f_la_LIBADD); do \
	    sublibs="$$sublibs `dirname $$lib`/.libs/`sed -n -e "s/old_library='\(.*\)'/\1/p" $$lib`"; \
	  done;\
	nm $(addprefix .libs/, $(libfftw3f_la_OBJECTS:.lo=.o)) $$sublibs | \
          grep -v -e ' R __real@[0-9a-fA-F]\+' | \
	  sed -n -e 's/^[0-9a-fA-F]\+ T _\([^         ]*\).*$$/\1/p' \
	         -e 's/^[0-9a-fA-F]\+ [BDGSR] _\([^         ]*\).*$$/\1 DATA/p' >> $@
EOF
      ) &&
    sed -e 's/^LDFLAGS =/LDFLAGS = -Wl,-subsystem:console/' tools/Makefile > ttt &&
      mv ttt tools/Makefile &&
    sed -e 's/^LDFLAGS =/LDFLAGS = -Wl,-subsystem:console/' \
        -e 's/^DEFS =/DEFS = -DFFTW_DLL/' tests/Makefile > ttt &&
      mv ttt tests/Makefile &&
    sed -e 's/^AR =.*$/AR = ar/' libbench2/Makefile > ttt &&
      mv ttt libbench2/Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libfftw3f.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/fftw-3.1.2"
  if failed_package|| test ! -f "$tbindir/libfftw3f-3.dll"; then
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
  download_file glpk-$glpkver.tar.gz ftp://ftp.gnu.org/gnu/glpk/glpk-$glpkver.tar.gz
  echo -n "decompressing GLPK... "
  unpack_file glpk-$glpkver.tar.gz
  echo "done"
  echo -n "compiling GLPK... "
  (cd "$DOWNLOAD_DIR/glpk-$glpkver" &&
    glpk_company="GNU <www.gnu.org>" &&
    glpk_desc=`grep -e '^DESCRIPTION' w32/glpk_*.def | sed -e 's/^DESCRIPTION \+//' -e 's/"//g'` &&
    glpk_copyright=`grep -e '^Copyright' README | head -n 1 | sed -e 's/,$//'` &&
    create_module_rc GLPK $glpkver glpk.dll "$glpk_company" "$glpk_desc" "$glpk_copyright" > src/glpk.rc &&
    CC=cc-msvc CFLAGS="-O2 -MD" CXX=cc-msvc CXXFLAGS="-O2 -MD" FC=fc-msvc FCFLAGS="-O2 -MD" \
      F77=fc-msvc FFLAGS="-O2 -MD" CPPFLAGS="-DWIN32 -D_WIN32 -D__STDC__" AR=ar-msvc RANLIB=ranlib-msvc \
      ./configure --prefix="$tdir_w32_forward" --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e 's/^libglpk_la_LDFLAGS =/libglpk_la_LDFLAGS = -Wl,glpk.res -Wl,-def:glpk.def -no-undefined/' \
        -e 's/^libglpk\.la:/libglpk.la: glpk.res glpk.def/' src/Makefile > ttt &&
      mv ttt src/Makefile &&
    (cat >> src/Makefile <<\EOF
glpk.res: glpk.rc
	rc -fo $@ $<
glpk.def: $(libglpk_la_OBJECTS)
	@echo "Generating $@..."
	@echo "EXPORTS" > $@
	@nm $(addprefix .libs/, $(libglpk_la_OBJECTS:.lo=.o)) | \
	  sed -n -e 's/^[0-9a-fA-F]\+ T _\([^         ]*\).*$$/\1/p' \
	         -e 's/^[0-9a-fA-F]\+ [BDGS] _\([^         ]*\).*$$/\1 DATA/p' >> $@
EOF
      ) &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libglpk.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/glpk-$glpkver"
  if failed_package || test ! -f "$tlibdir/glpk.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# ncurses #
###########

if check_package ncurses; then
  download_file ncurses-5.6.tar.gz ftp://ftp.gnu.org/gnu/ncurses/ncurses-5.6.tar.gz
  echo -n "decompressing ncurses... "
  unpack_file ncurses-5.6.tar.gz
  cp libs/ncurses-5.6.diff "$DOWNLOAD_DIR/ncurses-5.6"
  echo "done"
  echo "compiling ncurses... "
  (cd "$DOWNLOAD_DIR/ncurses-5.6" &&
    patch -p1 < ncurses-5.6.diff &&
    ncurses_copyright=`grep -e '^-- Copyright' README | head -n 1 | sed -e "s/-- //" -e "s/ *--$//"` &&
    create_module_rc Ncurses 5.6 ncurses.dll "Free Software Foundation (http://www.fsf.org)" \
      "GNU New Curses Library" "$ncurses_copyright" > ncurses/ncurses.rc &&
    CC=cc-msvc CXX=cc-msvc AR=ar-msvc RANLIB=ranlib-msvc CFLAGS="-O2 -MD" \
      CXXFLAGS="-O2 -MD -EHs" CPPFLAGS="-DWIN32 -D_WIN32" \
      ./configure --build=i686-pc-msdosmsvc --prefix=$INSTALL_DIR --without-cxx-binding \
      --without-libtool --with-shared --without-normal --without-debug &&
    sed -e "s/^SHARED_OBJS =/SHARED_OBJS = ncurses.res/" ncurses/Makefile > ttt &&
    mv ttt ncurses/Makefile &&
    echo "ncurses.res: ncurses.rc" >> ncurses/Makefile &&
    echo "	rc -fo \$@ \$<" >> ncurses/Makefile &&
    make -C include && make -C ncurses && make -C progs && make -C tack && make -C misc &&
    make -C include install && make -C ncurses install && make -C progs install &&
    make -C tack install && make -C misc install) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/ncurses-5.6"
  if failed_package || test ! -f "$tlibdir/ncurses.lib"; then
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
    rl_copyright=`grep -e '^/\* \+Copyright' readline.c | sed -e "s,/\* \+,,"` &&
    create_module_rc Readline 5.2 readline.dll "Free Software Foundation (http://www.fsf.org)" \
      "GNU Readline Library" "$rl_copyright" > readline.rc &&
    sed -e "s/^SHARED_OBJ =/SHARED_OBJ = readline.res/" shlib/Makefile.in > ttt &&
    mv ttt shlib/Makefile.in &&
    echo "readline.res: readline.rc" >> shlib/Makefile.in &&
    echo "	rc -fo \$@ \$<" >> shlib/Makefile.in &&
    configure_package --build=i686-pc-msdosmsvc &&
    make shared &&
    make install-shared &&
    cp shlib/*readline*.lib "$tlibdir/readline.lib" &&
    cp shlib/*history*.lib "$tlibdir/history.lib"&&
    mv $tlibdir_quoted/*readline*.dll $tlibdir_quoted/*history*.dll "$tbindir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/readline-5.2"
  if failed_package || test ! -f "$tlibdir/readline.lib"; then
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
    cp zlib.lib "$tlibdir/z.lib" &&
    cp zlib.h zconf.h "$tincludedir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/zlib"
  if failed_package || test ! -f "$tbindir/zlib1.dll"; then
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
  download_file SuiteSparse-3.0.0.tar.gz http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-3.0.0.tar.gz
  echo -n "decompressing SuiteSparse... "
  unpack_file SuiteSparse-3.0.0.tar.gz
  cp libs/suitesparse-3.0.0.diff "$DOWNLOAD_DIR/SuiteSparse"
  echo "done"
  echo "compiling SuiteSpase... "
  (cd "$DOWNLOAD_DIR/SuiteSparse" &&
    patch -p1 < suitesparse-3.0.0.diff &&
    make &&
    make install INSTDIR="$INSTALL_DIR") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/SuiteSparse"
  if failed_package || test ! -f "$tlibdir/cxsparse.lib" -o ! -d "$tincludedir/suitesparse"; then
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
  download_file hdf5-$hdf5ver.tar.gz ftp://ftp.hdfgroup.org/HDF5/current/src/hdf5-$hdf5ver.tar.gz
  echo -n "decompressing HDF5... "
  unpack_file hdf5-$hdf5ver.tar.gz
  echo "done"
  echo -n "compiling HDF5... "
  (cd "$DOWNLOAD_DIR/hdf5-$hdf5ver" &&
    if false; then
      patch -p1 < hdf5.diff &&
      cd proj/hdf5dll &&
      vcbuild -upgrade hdf5dll.vcproj &&
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
         H5Tpublic.h H5Zpublic.h H5pubconf.h hdf5.h H5api_adpt.h "$tincludedir"
    else
      create_module_rc HDF5 $hdf5ver libhdf5-0.dll "University of Illinois" \
        "NCSA Hierarchical Data Format (HDF) Library" \
        "Copyright by the Board of Trustees of the University of Illinois." > src/hdf5.rc &&
      W_CPPFLAGS="$W_CPPFLAGS -D_HDF5DLL_" \
        configure_package --enable-shared --disable-static &&
      post_process_libtool &&
      #sed -e '/^postinstall_cmds=/ {s/\$name/\\$name/; s/\$implibname/\\$implibname/;}' libtool > ttt
      #  mv ttt libtool &&
      sed -e 's/\$(LIB)/$(HLIB)/g' \
          -e 's/^LIB=/HLIB=/g' \
          -e 's/^LIBS=.*$/& -lws2_32/' \
          -e 's,\$(libdir)/\.,$(libdir),' \
          -e 's/^LDFLAGS=/LDFLAGS= -no-undefined -Wl,hdf5.res/' src/Makefile > ttt &&
        mv ttt src/Makefile &&
      sed -e '/^#ifdef \+H5_HAVE_STREAM.*$/ {p; c\
#define EWOULDBLOCK WSAEWOULDBLOCK
;}' src/H5FDstream.c > ttt &&
        mv ttt src/H5FDstream.c &&
      echo "#define HDsetvbuf(A,B,C,D) (((D)>1)?setvbuf(A,B,C,D):setvbuf(A,B,C,2))" >> src/H5pubconf.h &&
      echo "#define ssize_t long" >> src/H5pubconf.h &&
      cd src
      rc -fo hdf5.res hdf5.rc &&
      make &&
      make install &&
      cp ../COPYING "$tlicdir/COPYING.HDF5" &&
      rm -f $tlibdir_quoted/libhdf5.la
    fi) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/hdf5-$hdf5ver"
  if failed_package || test ! -f "$tlibdir/hdf5.lib"; then
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
    cp fnmatch.h glob.h "$tincludedir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/glob"
  if failed_package || test ! -f "$tlibdir/glob.lib"; then
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
  if false; then
    pngver=`echo $libpngver | sed -e "s/\.//g"`
    download_file lpng$pngver.zip ftp://ftp.simplesystems.org/pub/libpng/png/src/lpng$pngver.zip
    echo -n "decompressing libpng... "
    (cd "$DOWNLOAD_DIR" && unzip -q lpng$pngver.zip)
    echo "done"
    echo -n "compiling libpng... "
    (cd "$DOWNLOAD_DIR/lpng$pngver/projects/visualc71" &&
      sed -e 's/{2D4F8105-7D21-454C-9932-B47CAB71A5C0} = {2D4F8105-7D21-454C-9932-B47CAB71A5C0}//' libpng.sln > ttt &&
      mv ttt libpng.sln &&
      sed -e "s/\([  ]*\)AdditionalIncludeDirectories=\".*\"$/\1AdditionalIncludeDirectories=\"..\\\\..;$tdir_w32\\\\include\"/" \
        -e "s/\([  ]*\)Name=\"VCLinkerTool\".*$/\1Name=\"VCLinkerTool\"\\
AdditionalDependencies=\"zlib.lib\"\\
ImportLibrary=\"\$(TargetDir)png.lib\"\\
AdditionalLibraryDirectories=\"$tdir_w32\\\\lib\"/" libpng.vcproj > ttt &&
      mv ttt libpng.vcproj &&
      sed -e "s/^ *; *png_get_libpng_ver/  png_get_libpng_ver/" ../../scripts/pngw32.def > ttt &&
        mv ttt ../../scripts/pngw32.def &&
      vcbuild -upgrade libpng.vcproj &&
      vcbuild -u libpng.vcproj 'DLL Release|Win32' &&
  	sed -e "s,^prefix=.*$,prefix=$tdir_w32_forward," \
          -e "s,@exec_prefix@,\${prefix}," \
          -e "s,@libdir@,\${exec_prefix}/lib," \
          -e "s,^includedir=.*$,includedir=\${prefix}/include," \
          -e "s,-lpng[0-9]\+,-lpng," ../../scripts/libpng.pc.in > libpng.pc &&
      cp Win32_DLL_Release/libpng*.dll "$tbindir" &&
      cp Win32_DLL_Release/png.lib "$tlibdir" &&
      cp ../../png.h ../../pngconf.h "$tincludedir" &&
      mkdir -p "$tlibdir/pkgconfig" &&
      cp libpng.pc "$tlibdir/pkgconfig" &&
      cp libpng.pc "$tlibdir/pkgconfig/libpng12.pc") >&5 2>&1 && end_package
    remove_package "$DOWNLOAD_DIR/lpng$pngver"
  else
    download_file libpng-$libpngver.tar.bz2 ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-$libpngver.tar.bz2
    echo -n "decompressing libpng... "
    unpack_file libpng-$libpngver.tar.bz2
    echo "done"
    echo -n "compiling libpng... "
    (cd "$DOWNLOAD_DIR/libpng-$libpngver" &&
      ac_cv_func_memset=yes ac_cv_func_pow=yes \
        configure_package --disable-static --enable-shared --without-libpng-compat &&
      post_process_libtool &&
      sed -e 's/^libpng12_la_LDFLAGS =/& -export-symbols-regex "^png_.*" -Wl,scripts\/pngw32.res/' Makefile > ttt &&
        mv ttt Makefile &&
      (cd scripts && rc -fo pngw32.res pngw32.rc) &&
      make &&
      make install &&
      rm -rf $tlibdir_quoted/libpng*.la &&
      cp "$tlibdir/png12.lib" "$tlibdir/png.lib") >&5 2>&1 && end_package
    remove_package "$DOWNLOAD_DIR/libpng-$libpngver"
  fi
  if failed_package || test ! -f "$tlibdir/png.lib"; then
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
  unpack_file arpack96.tar.gz
  unpack_file patch.tar.gz
  cp libs/arpack.makefile "$DOWNLOAD_DIR/ARPACK"
  echo "done"
  echo -n "compiling ARPACK... "
  (cd "$DOWNLOAD_DIR/ARPACK" &&
    sed -e "s/^OBJECTS =/OBJECTS = arpack.res/" arpack.makefile > ttt &&
    mv ttt arpack.makefile &&
    echo "arpack.res: arpack.rc" >> arpack.makefile &&
    echo "	rc -fo \$@ \$<" >> arpack.makefile &&
    create_module_rc ARPACK 96.0 arpack.dll "Rice University (http://www.caam.rice.edu)" \
      "ARPACK Library for Large-Scale Eigenvalues Problems" "Copyright (©) 2001, Rice University" > arpack.rc &&
    make -f arpack.makefile && 
    cp libarpack.dll "$tbindir" &&
    cp arpack.lib "$tlibdir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/ARPACK"
  wget $WGET_FLAGS -O "$tlicdir/COPYING.ARPACK.doc" http://www.caam.rice.edu/software/ARPACK/RiceBSD.doc
  if failed_package || test ! -f "$tlibdir/arpack.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# libjpeg #
###########

#if check_package libjpeg; then
#  download_file jpeg-6b-4-src.zip 'http://downloads.sourceforge.net/gnuwin32/jpeg-6b-4-src.zip?modtime=1116176612&big_mirror=0'
#  echo -n "decompressing libjpeg... "
#  (cd "$DOWNLOAD_DIR" && mkdir jpeg && cd jpeg && unzip -q ../jpeg-6b-4-src.zip)
#  cp libs/libjpeg-6b.diff "$DOWNLOAD_DIR/jpeg"
#  echo "done"
#  (cd "$DOWNLOAD_DIR/jpeg" &&
#    patch -p1 < libjpeg-6b.diff &&
#    cd src/jpeg/6b/jpeg-6b-src &&
#    nmake -f makefile.vc nodebug=1 &&
#    cp jpeg6b.dll "$tbindir" &&
#    cp jpeg.lib "$tlibdir" &&
#    cp jconfig.h jerror.h jmorecfg.h jpeglib.h "$tincludedir") >&5 2>&1
#  rm -rf "$DOWNLOAD_DIR/jpeg"
#  if test ! -f "$tbindir/jpeg6b.dll"; then
#    echo "failed"
#    exit -1
#  else
#    echo "done"
#  fi
#fi

if check_package libjpeg; then
  download_file jpegsrc.v6b.tar.gz ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6b.tar.gz
  echo -n "decompressing libjpeg... "
  unpack_file jpegsrc.v6b.tar.gz
  echo "done"
  (cd "$DOWNLOAD_DIR/jpeg-6b" &&
    create_module_rc Libjpeg 6.2 libjpeg-62.dll "Independent JPEG Group <www.ijg.org>" \
      "Libjpeg - Library and Tools for JPEG Images" "© `date +%Y` Independent JPEG Group <www.ijg.org>" > jpeg.rc &&
    CPP="/mingw/bin/cpp" \
      ./configure_package --enable-shared --disable-static &&
    sed -e 's/libjpeg\.la:.*$/& jpeg.def jpeg.res/' Makefile > ttt &&
      mv ttt Makefile &&
    (cat >> Makefile <<\EOF
jpeg.res: jpeg.rc
	rc -fo $@ $<
jpeg.def: $(LIBOBJECTS)
	echo "EXPORTS" > $@
	nm $(LIBOBJECTS) | sed -n -e 's/^.* T _\(.*\)$$/\1/p' >> $@
EOF
) &&
    sed -e 's/^build_libtool_libs=.*$/build_libtool_libs=yes/' \
        -e 's/^build_old_libs=.*$/build_old_libs=no/' \
        -e 's/^version_type=.*$/version_type=windows/' \
        -e 's/^library_names_spec=.*$/library_names_spec="lib\\$name-\\$versuffix.dll"/' \
		-e '/^[	 ]*case "\$version_type" in.*$/ {p;i\
windows)\
  major=`expr $current - $age`\
  versuffix="$major"\
  ;;
;d;}' \
        -e 's/^hardcode_libdir_flag_spec=.*$/hardcode_libdir_flag_spec=""/' \
        -e 's/^archive_cmds=.*$/archive_cmds="\\$CC -shared -o \\$lib\\$libobjs -Wl,-def:jpeg.def -Wl,jpeg.res"/' \
        libtool > ttt &&
      mv ttt libtool &&
  (cat >> jconfig.h <<\EOF

#include <windows.h>

#ifndef __RPCNDR_H__
typedef unsigned char boolean;
#endif
#define HAVE_BOOLEAN
EOF
) &&
    sed -e 's/^#ifndef \+XMD_H/#if !defined(XMD_H) \&\& !defined(_WIN32)/' jmorecfg.h > ttt &&
      mv ttt jmorecfg.h &&
    make libjpeg.la &&
    cp jconfig.h jpeglib.h jmorecfg.h jerror.h "$tincludedir" &&
    cp .libs/libjpeg*.dll "$tbindir" &&
    cp .libs/libjpeg*.lib "$tlibdir/jpeg.lib") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/jpeg-6b"
  if failed_package || test ! -f "$tlibdir/jpeg.lib"; then
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
  download_file libiconv-$libiconvver.tar.gz ftp://ftp.gnu.org/pub/gnu/libiconv/libiconv-$libiconvver.tar.gz
  echo -n "decompressing libiconv... "
  unpack_file libiconv-$libiconvver.tar.gz
  echo "done"
  echo -n "compiling libiconv... "
  (cd "$DOWNLOAD_DIR/libiconv-$libiconvver" &&
    configure_package --enable-shared --disable-static  --disable-nls &&
    post_process_libtool &&
    post_process_libtool libcharset/libtool &&
    sed -e '/^#define LIBCHARSET_DLL_EXPORTED *$/ {c\
\#ifdef BUILDING_LIBCHARSET\
\#define LIBCHARSET_DLL_EXPORTED __declspec(dllexport)\
\#else\
\#define LIBCHARSET_DLL_EXPORTED __declspec(dllimport)\
\#endif
;}' libcharset/include/localcharset.h > ttt &&
      mv ttt libcharset/include/localcharset.h &&
    sed -e 's/__declspec *(dllimport)//' \
        -e '/^#define LIBICONV_DLL_EXPORTED *$/ {c\
\#ifdef BUILDING_LIBICONV\
\#define LIBICONV_DLL_EXPORTED __declspec(dllexport)\
\#else\
\#define LIBICONV_DLL_EXPORTED __declspec(dllimport)\
\#endif
;}' include/iconv.h > ttt
      mv ttt include/iconv.h &&
    sed -e 's/q}/q;}/' \
        -e '/-DPACKAGE_VERSION_SUBMINOR/ {s/\${version}/${version}.0/;}' windows/windres-options > ttt &&
      mv ttt windows/windres-options &&
    sed -e 's/^OBJECTS_EXP_yes =/#OBJECTS_EXP_yes/' \
        -e 's/^LDFLAGS =/LDFLAGS = -Wl,libiconv.res/' lib/Makefile > ttt &&
      mv ttt lib/Makefile &&
    sed -e '/^BUILT_SOURCES =.*\\$/N' \
        -e '/^BUILT_SOURCES =/ {s/string\.h//;s/unistd\.h//;s/stdlib\.h//;}' srclib/Makefile > ttt &&
      mv ttt srclib/Makefile &&
    sed -e 's/hpux/mingw32/' src/Makefile > ttt &&
      mv ttt src/Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libiconv.la $tlibdir_quoted/libcharset.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/libiconv-$libiconvver"
  if failed_package || test ! -f "$tlibdir/iconv.lib"; then
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
  download_file gettext-$gettextver.tar.gz ftp://ftp.belnet.be/mirror/ftp.gnu.org/gnu/gettext/gettext-$gettextver.tar.gz
  echo -n "decompressing gettext... "
  unpack_file gettext-$gettextver.tar.gz
  cp libs/gettext-$gettextver.diff "$DOWNLOAD_DIR/gettext-$gettextver"
  echo "done"
  echo -n "compiling gettext... "
  (cd "$DOWNLOAD_DIR/gettext-$gettextver" &&
    patch -p1 < gettext-$gettextver.diff &&
    use_glib_libxml=no &&
    if test -f "`which pkg-config`"; then
      if pkg-config --exists glib-2.0 libxml-2.0; then
        use_glib_libxml=yes
      fi
    fi &&
    echo "using GLib and libxml support: $use_glib_libxml" &&
    if test "x$use_glib_libxml" = "xyes"; then
      W_CPPFLAGS="$W_CPPFLAGS `pkg-config --cflags glib-2.0 libxml-2.0`" ac_cv_func_memset=yes \
        configure_package --enable-shared --disable-static  --disable-nls \
        --disable-java --disable-native-java --enable-relocatable --with-included-gettext
    else
      ac_cv_func_memset=yes \
        configure_package --enable-shared --disable-static  --disable-nls \
        --disable-java --disable-native-java --enable-relocatable --with-included-gettext
    fi &&
    for lt in `find . -name libtool`; do
      post_process_libtool $lt
    done &&
    #read -p "WARNING: gettext-runtime/libasprintf/libtool and gettext-tools/libtool needs manual post-processing; press <ENTER> when done " &&
    for cs in gettext-runtime/config.status gettext-tools/config.status; do
      sed -e '/@USE_INCLUDED_LIBINTL@/ {s/no/yes/;}' "$cs" > ttt &&
        mv ttt "$cs" &&
      (cd `dirname "$cs"` && ./config.status)
    done &&
    if test "$crtver" = "90"; then
      sed -e 's/^[ 	]*case SUBLANG_SINDHI_AFGHANISTAN:.*$//' gettext-runtime/intl/localename.c > ttt &&
        mv ttt gettext-runtime/intl/localename.c
      sed -e 's/^[ 	]*case SUBLANG_SINDHI_AFGHANISTAN:.*$//' gettext-tools/gnulib-lib/localename.c > ttt &&
        mv ttt gettext-tools/gnulib-lib/localename.c
    fi &&
    (cd gettext-tools/src && make gettext.res && cp gettext.res ../gnulib-lib/gettext.res) &&
    make &&
    make install &&
    rm $tlibdir_quoted/lib*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gettext-$gettextver"
  if failed_package || test ! -f "$tlibdir/intl.lib"; then
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
  download_file cairo-$cairover.tar.gz http://cairographics.org/releases/cairo-$cairover.tar.gz
  echo -n "decompressing cairo... "
  (cd "$DOWNLOAD_DIR" && if ! tar xfz cairo-$cairover.tar.gz; then tar xf cairo-$cairover.tar.gz; fi)
  echo "done"
  echo "compiling cairo... "
  (cd "$DOWNLOAD_DIR/cairo-$cairover" &&
    ax_cv_c_float_words_bigendian=no configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "s|^libcairo_la_LDFLAGS =|libcairo_la_LDFLAGS = -Wl,cairo.res|" \
        -e "s|^libcairo_la_OBJECTS =|libcairo_la_OBJECTS = cairo.res|" \
        -e "s|-lgdi32|-luser32 -lgdi32|" src/Makefile > ttt &&
      mv ttt src/Makefile &&
    echo "cairo.res: cairo.rc" >> src/Makefile &&
    echo "	rc -fo \$@ \$<"    >> src/Makefile &&
    create_module_rc Cairo $cairover libcairo-2.dll "Freedesktop.org <www.freedesktop.org>" \
      "`grep -e '^Cairo -' README | head -n 1`" "Copyright © `date +%Y` Freedesktop.org" > src/cairo.rc &&
    make &&
    make install &&
  	rm -f $tlibdir_quoted/libcairo*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/cairo-$cairover"
  if failed_package || test ! -f "$tbindir/libcairo-2.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

########
# glib #
########

if check_package glib; then
  if test ! -f "`which pkg-config`"; then
    echo ""
    echo "need to compile pkg-config first, restarting..."
    if $do_debug; then
      $0 -v --prefix="$INSTALL_DIR" pkg-config || exit -1
    else
      $0 --prefix="$INSTALL_DIR" pkg-config || exit -1
    fi
  fi
  glibroot=`echo $glibver | sed -e 's/\.[0-9]\+$//'`
  download_file glib-$glibver.tar.gz ftp://ftp.gtk.org/pub/glib/$glibroot/glib-$glibver.tar.gz
  echo -n "decompressing glib... "
  unpack_file glib-$glibver.tar.gz
  echo "done"
  echo "compiling glib... "
  (cd "$DOWNLOAD_DIR/glib-$glibver" &&
    sed -e 's/extern int _nl_msg_cat_cntr/extern __declspec(dllimport) int _nl_msg_cat_cntr/' configure > ttt &&
      mv ttt configure &&
    configure_package --enable-shared --disable-static --with-threads=win32 --with-pcre=system &&
    post_process_libtool &&
    echo "#define HAVE_DIRENT_H 1" >> config.h &&
    sed -e "s/-lws2_32/-luser32 -ladvapi32 -lshell32 -L. -ldirent -lws2_32/" glib/Makefile > ttt &&
      mv ttt glib/Makefile &&
    sed -e "s/G_THREAD_LIBS_EXTRA =/G_THREAD_LIBS_EXTRA = -luser32/" gthread/Makefile > ttt &&
      mv ttt gthread/Makefile &&
    (cd build/win32/dirent &&
      cl -O2 -MD -I. -c *.c &&
      lib -out:dirent.lib *.obj &&
      cp dirent.h dirent.lib ../../../glib) &&
    make glibconfig.h &&
    sed -e "s/^.*G_ATOMIC_OP_MEMORY_BARRIER_NEEDED.*$//" glibconfig.h > ttt &&
      mv ttt glibconfig.h &&
      sed -e "/SUBDIR =/ {s/tests//;s/docs//;}" Makefile > ttt &&
      mv ttt Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libglib*.la $tlibdir_quoted/libgmodule*.la \
          $tlibdir_quoted/libgthread*.la $tlibdir_quoted/libgobject*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/glib-$glibver"
  if failed_package || test ! -f "$tbindir/libglib-2.0-0.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# libxml2 #
###########

if check_package libxml2; then
  download_file libxml2-$libxml2ver.tar.gz ftp://xmlsoft.org/libxml2/libxml2-$libxml2ver.tar.gz
  echo -n "decompressing libxml2... "
  unpack_file libxml2-$libxml2ver.tar.gz
  echo "done"
  echo "compiling libxml2... "
  (cd "$DOWNLOAD_DIR/libxml2-$libxml2ver" &&
    create_module_rc libxml2 $libxml2ver "libxml2-2.dll" "XmlSoft (www.xmlsoft.org)" \
      "XML Parser and Toolkit Library" "`grep -e '^ *Copyright' Copyright | head -n 1 | sed -e 's/^ *//'`" > xml2.rc &&
    sed -e '/#undef vsnprintf/ {i \
#ifndef HAVE_VSNPRINTF\
#undef vsnprintf\
#endif
;d;}' \
        config.h.in > ttt &&
      mv ttt config.h.in &&
    configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "s/^libxml2_la_LDFLAGS =/libxml2_la_LDFLAGS = -Wl,-export:trio_snprintf -Wl,xml2.res/" Makefile > ttt &&
      mv ttt Makefile &&
    sed -e 's/\(^.*defined *(__MINGW32__).*$\)/\1 || defined(_MSC_VER)/' nanoftp.c > ttt &&
      mv ttt nanoftp.c &&
    sed -e 's/\(^.*defined *(__MINGW32__).*$\)/\1 || defined(_MSC_VER)/' nanohttp.c > ttt &&
      mv ttt nanohttp.c &&
    rc -fo xml2.res xml2.rc &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libxml2.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/libxml2-$libxml2ver"
  if failed_package || test ! -f "$tlibdir/xml2.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

############
# freetype #
############

if check_package freetype; then
  download_file freetype-$ftver.tar.bz2 http://download.savannah.gnu.org/releases/freetype/freetype-$ftver.tar.bz2
  echo -n "decompressing freetype... "
  unpack_file freetype-$ftver.tar.bz2
  echo "done"
  echo -n "compiling freetype... "
  (cd "$DOWNLOAD_DIR/freetype-$ftver" &&
    create_module_rc FreeType $ftver libfreetype-6.dll "Freetype.org <www.freetype.org>" \
      "FreeType 2 Font Engine Library" "`grep -A 2 -e '^Copyright' README | tr \\\\n ' '`" > freetype.rc &&
    configure_package --enable-shared --disable-static &&
  	post_process_libtool builds/unix/libtool &&
    sed -e "/^TOP_DIR/ {s/pwd/pwd -W/;}" builds/unix/unix-def.mk > ttt &&
      mv ttt builds/unix/unix-def.mk &&
  	sed -e 's/^LDFLAGS \+:=/LDFLAGS := -Wl,freetype.res/' builds/unix/unix-cc.mk > ttt &&
      mv ttt builds/unix/unix-cc.mk &&
    sed -e '/define \+FT_EXPORT/ {p; c\
\#ifdef FT2_BUILD_LIBRARY\
\# define FT_EXPORT(x)     __declspec(dllexport) x\
\# define FT_EXPORT_VAR(x) __declspec(dllexport) x\
\#else\
\# define FT_EXPORT(x)     __declspec(dllimport) x\
\# define FT_EXPORT_VAR(x) __declspec(dllimport) x\
\#endif
;}' include/freetype/config/ftoption.h > ttt &&
      mv ttt include/freetype/config/ftoption.h &&
    rc -fo freetype.res freetype.rc &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libfreetype*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/freetype-$ftver"
  if failed_package || test ! -f "$tlibdir/freetype.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

########
# FTGL #
########

if check_package FTGL; then
  download_file ftgl-$ftglver.tar.bz2 "http://downloads.sourceforge.net/ftgl/ftgl-$ftglver.tar.bz2?big_mirror=0"
  echo -n "decompressing FTGL... "
  unpack_file ftgl-$ftglver.tar.bz2
  echo "done"
  echo -n "compiling FTGL... "
  (cd "$DOWNLOAD_DIR/FTGL/unix" &&
    create_module_rc FTGL $ftglver libftgl-0.dll "FTGL <http://ftgl.wiki.sourceforge.net>" \
      "Font Library for OpenGL" "Copyright (C) 2001-`date +%Y` Henry Maddocks" > src/ftgl.rc &&
    sed -e '/^ac_includes_default=.*$/ {p; c\
#include <windows.h>
;}' \
        -e '/^char glBegin ();$/ {c\
#include <windows.h>\
#include <GL/gl.h>
;}' \
        -e 's/^glBegin ();/glBegin (0);/' \
        -e 's/-lGLU/-lglu32/g' \
        -e '/^char gluNewTess ();$/ {c\
#include <windows.h>\
#include <GL/glu.h>
;}' \
        -e '/#include <GL\/glu\.h>/ {c\
#include <windows.h>\
#include <GL/glu.h>
;}' \
        configure > ttt &&
      mv ttt configure &&
    W_CPPFLAGS="$W_CPPFLAGS -DFTGL_LIBRARY -DFTGL_DLL_EXPORTS" \
      configure_package --enable-shared --disable-static --with-gl-lib=-lopengl32 &&
    post_process_libtool libtool &&
    (cd docs && tar xvfz ../../docs/html.tar.gz) &&
    sed -e '/^LIBS +=.*$/ {p; c\
LDFLAGS += -no-undefined -Wl,ftgl.res
;}' \
        -e 's/^libftgl\.la:/& ftgl.res/' \
        src/Makefile > ttt &&
      mv ttt src/Makefile &&
    (cat >> src/Makefile <<\EOF

ftgl.res: ftgl.rc
	rc -fo $@ $<
EOF
) &&
    sed -e 's/^#ifdef WIN32$/#if defined (WIN32) || defined (_MSC_VER)/' include/FTGL.h > ttt &&
      mv ttt include/FTGL.h &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libftgl*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/FTGL"
  if failed_package || test ! -f "$tlibdir/ftgl.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##############
# fontconfig #
##############

if check_package fontconfig; then
  download_file fontconfig-$fontconfigver.tar.gz http://fontconfig.org/release/fontconfig-$fontconfigver.tar.gz
  echo -n "decompressing fontconfig... "
  unpack_file fontconfig-$fontconfigver.tar.gz
  cp libs/fontconfig-$fontconfigver.diff "$DOWNLOAD_DIR/fontconfig-$fontconfigver"
  echo "done"
  echo "compiling fontconfig... "
  (cd "$DOWNLOAD_DIR/fontconfig-$fontconfigver" &&
    patch -p1 < fontconfig-$fontconfigver.diff &&
    create_module_rc FontConfig $fontconfigver "libfontconfig-1.dll" "Freedesktop (www.freedesktop.org)" \
      "Font Configuration Library" "`grep -e '^ *Copyright' COPYING | head -n 1 | sed -e 's/^ *//'`" > src/fontconfig.rc &&
    configure_package --enable-shared --disable-static --disable-docs --enable-xml2 &&
    post_process_libtool &&
    sed -e "s/^libfontconfig_la_LDFLAGS =/libfontconfig_la_LDFLAGS = -Wl,fontconfig.res/" src/Makefile > ttt &&
      mv ttt src/Makefile &&
    (cd src && rc -fo fontconfig.res fontconfig.rc) &&
    make &&
    make install &&
    rm -f "$tlibdir/libfontconfig.la") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/fontconfig-$fontconfigver"
  if failed_package || test ! -f "$tlibdir/fontconfig.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#########
# pango #
#########

if check_package pango; then
  pangoroot=`echo $pangover | sed -e 's/\.[0-9]\+$//'`
  download_file pango-$pangover.tar.bz2 ftp://ftp.gtk.org/pub/pango/$pangoroot/pango-$pangover.tar.bz2
  echo -n "decompressing pango... "
  unpack_file pango-$pangover.tar.bz2
  echo "done"
  echo "compiling pango... "
  (cd "$DOWNLOAD_DIR/pango-$pangover" &&
    configure_package --enable-shared --disable-static --with-included-modules=basic-win32 \
      --with-dynamic-modules=no --enable-explicit-deps=no &&
    post_process_libtool &&
    sed -e 's/-lgdi32/-luser32 -lgdi32/' \
        -e 's/^\(libpangocairo.*_la_LDFLAGS =\)/\1 -Wl,pangocairo-win32-res.o/' \
	-e '/^install-data-local:/ {s/install-ms-lib//;s/install-def-files//;}' pango/Makefile > ttt &&
      mv ttt pango/Makefile &&
    sed -e 's,/pango/pango-querymodules\$(EXEEXT),/pango/pango-querymodules,' modules/Makefile > ttt &&
      mv ttt modules/Makefile &&
    sed -e 's/PangoFT2/PangoCairo/g' \
        -e 's/pangoft2/pangocairo/g' pango/pangoft2.rc > pango/pangocairo.rc &&
    rc -fo pango/pangocairo-win32-res.o pango/pangocairo.rc &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libpango*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/pango-$pangover"
  if failed_package || test ! -f "$tbindir/libpango-1.0-0.dll"; then
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
  download_file gd-$gdver.tar.bz2 http://www.libgd.org/releases/gd-$gdver.tar.bz2
  echo -n "decompressing libgd... "
  unpack_file gd-$gdver.tar.bz2
  echo "done"
  echo -n "compiling libgd... "
  (cd "$DOWNLOAD_DIR/gd-$gdver" &&
    gd_company="`sed -n -e 's/^ *VALUE \+"CompanyName" *, *"\([^"\\]*\)\\\\0".*$/\1/p' windows/libgd.rc`" &&
    gd_copyright="`sed -n -e 's/^ *VALUE \+"LegalCopyright" *, *"\([^"\\]*\)\\\\0".*$/\1/p' windows/libgd.rc`" &&
    create_module_rc LIBGD $gdver libgd-2.dll "$gd_company" \
      "GD - Graphics Creation Library" "$gd_copyright" > libgd.rc &&
    W_CPPFLAGS="$W_CPPFLAGS -D__STDC__ -DMSWIN32 -DBGDWIN32" \
      configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e 's/^libgd_la_LDFLAGS =/libgd_la_LDFLAGS = -Wl,libgd.res -no-undefined/' \
        -e 's/^libgd\.la:/libgd.la: libgd.res/' Makefile > ttt &&
      mv ttt Makefile &&
    (cat >> Makefile << \EOF
libgd.res: libgd.rc
	rc -fo $@ $<
EOF
      ) &&
    touch -r aclocal.m4 configure.ac &&
    make &&
    make install &&
    cp COPYING "$tlicdir/COPYING.LIBGD") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gd-$gdver"
  if failed_package || test ! -f "$tlibdir/gd.lib"; then
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
  download_file gsl-$gslver.tar.gz ftp://ftp.gnu.org/gnu/gsl/gsl-$gslver.tar.gz
  echo -n "decompressing libgsl... "
  unpack_file gsl-$gslver.tar.gz
  echo "done"
  echo -n "compiling libgsl... "
  (cd "$DOWNLOAD_DIR/gsl-$gslver" &&
    create_module_rc GSL $gslver libgsl-0.dll "Free Software Foundation (http://www.fsf.org)" \
      "GNU Scientific Library" "Copyright (C) 2000, 2007 Free Software Foundation" > gsl.rc
    create_module_rc GSLCBLAS $gslver libgslcblas-0.dll "Free Software Foundation (http://www.fsf.org)" \
      "GSL CBLAS Implementation" "Copyright (C) 2000, 2007 Free Software Foundation" > cblas/gslcblas.rc
    W_CPPFLAGS="$W_CPPFLAGS -DGSL_DLL -D__STDC__" configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e 's/^libgsl_la_LDFLAGS =/libgsl_la_LDFLAGS = -Wl,gsl.res -Wl,-def:gsl.def/' \
        -e 's/^libgsl\.la:/libgsl.la: gsl.res gsl.def/' Makefile > ttt &&
      mv ttt Makefile &&
    (cat >> Makefile <<\EOF
gsl.res: gsl.rc
	rc -fo $@ $<
gsl.def: $(libgsl_la_OBJECTS) $(SUBLIBS)
	@echo "Generating $@..."
	@echo "EXPORTS" > $@
	@sublibs=; for lib in $(SUBLIBS); do \
	    sublibs="$$sublibs `dirname $$lib`/.libs/`sed -n -e "s/old_library='\(.*\)'/\1/p" $$lib`"; \
	  done;\
	nm $(addprefix .libs/, $(libgsl_la_OBJECTS:.lo=.o)) $$sublibs | \
	  sed -n -e 's/^[0-9a-fA-F]\+ T _\([^         ]*\).*$$/\1/p' \
	         -e 's/^[0-9a-fA-F]\+ [BDGS] _\([^         ]*\).*$$/\1 DATA/p' >> $@
EOF
      ) &&
    sed -e 's/^libgslcblas_la_LDFLAGS =/libgslcblas_la_LDFLAGS = -Wl,gslcblas.res -Wl,-def:gslcblas.def/' \
        -e 's/^libgslcblas\.la:/libgslcblas.la: gslcblas.res gslcblas.def/' cblas/Makefile > ttt &&
      mv ttt cblas/Makefile &&
    (cat >> cblas/Makefile <<\EOF
gslcblas.res: gslcblas.rc
	rc -fo $@ $<
gslcblas.def: $(libgslcblas_la_OBJECTS)
	@echo "Generating $@..."
	@echo "EXPORTS" > $@
	  @nm $(addprefix .libs/, $(libgslcblas_la_OBJECTS:.lo=.o)) | \
	    sed -n -e 's/^[0-9a-fA-F]\+ T _\([^   ]*\).*$$/\1/p' >> $@
EOF
      ) &&
    sed -e 's/[^ ]*memcpy[^ ]*//' utils/Makefile > ttt &&
      mv ttt utils/Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libgsl*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gsl-$gslver"
  if failed_package || test ! -f "$tlibdir/gsl.lib"; then
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
  download_file netcdf-$netcdfver.tar.gz ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-$netcdfver.tar.gz
  echo -n "decompressing netcdf... "
  unpack_file netcdf-$netcdfver.tar.gz
  echo "done"
  echo -n "compiling netcdf... "
  (cd "$DOWNLOAD_DIR/netcdf-$netcdfver" &&
    if test -d "src/win32/NET"; then
      cd src/win32/NET &&
      sed -e 's/RuntimeLibrary=.*/RuntimeLibrary="2"/' libsrc/netcdf.vcproj > ttt &&
      mv ttt libsrc/netcdf.vcproj &&
      cd libsrc &&
      vcbuild -upgrade netcdf.vcproj &&
      vcbuild -u netcdf.vcproj "Release|Win32" &&
      cp ../../../COPYRIGHT "$tlicdir/COPYING.NETCDF" &&
      cp Release/netcdf.lib "$tlibdir" &&
      cp ../../../libsrc/netcdf.h "$tincludedir" &&
      cp Release/netcdf.dll "$tbindir"
    else
      configure_package --enable-c-only --enable-dll --enable-shared --disable-static &&
      post_process_libtool &&
      sed -e 's/-Wl,--output-def,.*$//' \
          -e 's/^libnetcdf_la_LDFLAGS =/libnetcdf_la_LDFLAGS = -Wl,netcdf.res/' \
          -e 's/^libnetcdf_la_OBJECTS =/libnetcdf_la_OBJECTS = netcdf.res/' libsrc/Makefile > ttt &&
      mv ttt libsrc/Makefile &&
      echo "netcdf.res: netcdf.rc" >> libsrc/Makefile &&
      echo "	rc -fo \$@ \$<"    >> libsrc/Makefile &&
      netcdf_copyright=`grep -e '^Copyright' COPYRIGHT | head -n 1` &&
      create_module_rc NetCDF $netcdfver libnetcdf-4.dll "University Corporation for Atmospheric Research/Unidata" \
        "Unidata network Common Data Form Library" "$netcdf_copyright" > libsrc/netcdf.rc &&
      echo "#define ssize_t int" >> config.h &&
      echo "#include <malloc.h>" >> config.h &&
      cd libsrc &&
      make &&
      make install &&
      cp ../COPYRIGHT "$tlicdir/COPYING.NETCDF" &&
      rm -f $tlibdir_quoted/libnetcdf*.la
    fi) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/netcdf-$netcdfver"
  if failed_package || test ! -f "$tlibdir/netcdf.lib"; then
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
    cp sed/sed.exe "$tbindir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/sed-4.1.5"
  if failed_package || test ! -f "$tbindir/sed.exe"; then
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
    cp makeinfo/makeinfo.exe "$tbindir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/texinfo-4.8"
  if failed_package || test ! -f "$tbindir/makeinfo.exe"; then
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
    cp units.exe units.dat "$tbindir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/units-1.86"
  if failed_package || test ! -f "$tbindir/units.exe"; then
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
    cp less.exe lesskey.exe "$tbindir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/less-394"
  if failed_package || test ! -f "$tbindir/less.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##############
# pkg-config #
##############

if check_package pkg-config; then
  use_support_glib=false
  if test ! -f "$tdir_w32_forward/bin/libglib-2.0-0.dll"; then
    echo "compiling support GLib... " &&
    glibroot=`echo $glibver | sed -e 's/\.[0-9]\+$//'`
    download_file glib-$glibver.tar.gz ftp://ftp.gtk.org/pub/glib/$glibroot/glib-$glibver.tar.gz
    echo -n "decompressing glib... "
    unpack_file glib-$glibver.tar.gz
    mv "$DOWNLOAD_DIR/glib-$glibver" "$DOWNLOAD_DIR/glib"
    echo "done"
    echo -n "compiling glib... "
    (cd "$DOWNLOAD_DIR/glib" &&
      sed -e '/^INTL_LIBS =/ {s/intl\.lib/lib\\intl.lib/;}' build/win32/make.msc > ttt &&
        mv ttt build/win32/make.msc &&
      sed -e 's/-DEBCDIC=0//' \
          -e 's/\\\.obj//' \
          -e 's/pcre_internal\.obj/pcre_chartables.obj/' \
          -e 's/	ucp.*\.obj *\\//' \
          glib/pcre/makefile.msc > ttt &&
        mv ttt glib/pcre/makefile.msc &&
      sed -e '/^PARTS/ {s/tests//;}' makefile.msc > ttt &&
        mv ttt makefile.msc &&
      (cd build/win32/dirent && nmake -f makefile.msc INTL=$tdir_w32_forward LIBICONV=$tdir_w32_forward) &&
      (cd glib && nmake -f makefile.msc "INTL=$tdir_w32_forward" "LIBICONV=$tdir_w32_forward") &&
      echo "done")
    use_support_glib=true
  fi
  download_file pkg-config-0.22.tar.gz http://pkgconfig.freedesktop.org/releases/pkg-config-0.22.tar.gz
  echo -n "decompressing pkg-config... "
  (cd "$DOWNLOAD_DIR" && tar xfz pkg-config-0.22.tar.gz)
  cp libs/pkg-config-0.22.diff "$DOWNLOAD_DIR/pkg-config-0.22"
  echo "done"
  echo -n "compiling pkg-config... "
  (cd "$DOWNLOAD_DIR/pkg-config-0.22" &&
    patch -p1 < pkg-config-0.22.diff &&
    if $use_support_glib; then
      sed -e 's/GLIB_CFLAGS=".*/GLIB_CFLAGS="-I..\/glib -I..\/glib\/glib"/' \
          -e "s/GLIB_LIBS=\".*/GLIB_LIBS=\"-L..\/glib\/glib -lglib-${glibroot}s -liconv -lintl -luser32 -lole32 -lshell32\"/" \
          configure > ttt &&
        mv ttt configure
    fi &&
    configure_package --disable-shared &&
    post_process_libtool &&
    make
    make install &&
    mkdir -p "$tlibdir/pkgconfig") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/pkg-config-0.22"
  if $use_support_glib; then
    remove_package "$DOWNLOAD_DIR/glib"
  fi
  if failed_package || test ! -f "$tbindir/pkg-config.exe"; then
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
    W_CPPFLAGS="$W_CPPFLAGS -DASM_UNDERSCORE" configure_package &&
    make -C src &&
    make -C src install &&
    cp cln.pc "$tlibdir/pkgconfig/cln.pc") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/cln-1.1.13"
  if failed_package || test ! -f "$tlibdir/cln.lib"; then
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
    sed -e '/^Libs:/ { s/-lginac//; s/.*/& -lginac/; }' ginac.pc.in > ttt &&
      mv ttt ginac.pc.in &&
    configure_package --disable-shared &&
    make -C ginac &&
    make -C ginsh &&
    make -C ginac install &&
    make install-pkgconfigDATA) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/ginac-1.3.6"
  if failed_package || test ! -f "$tlibdir/ginac.lib"; then
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
    cp lib/vc_lib/msw/wx/setup.h "$tincludedir/wx") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/wxMSW-2.8.4"
  if failed_package || test ! -f "$tlibdir/wxmsw28.lib"; then
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
  download_file gnuplot-4.2.2.tar.gz 'http://downloads.sourceforge.net/gnuplot/gnuplot-4.2.2.tar.gz?modtime=1173003818&big_mirror=0'
  echo -n "decompressing gnuplot... "
  (cd "$DOWNLOAD_DIR" && tar xfz gnuplot-4.2.2.tar.gz)
  cp libs/gnuplot-4.2.2.diff "$DOWNLOAD_DIR/gnuplot-4.2.2"
  echo "done"
  echo -n "compiling gnuplot... "
  (cd "$DOWNLOAD_DIR/gnuplot-4.2.2" &&
    patch -p1 < gnuplot-4.2.2.diff &&
    sed -e "s,^DESTDIR =.*,DESTDIR = $tdir_w32," -e "s,^WXLOCATION =.*,WXLOCATION = $tdir_w32," \
      -e "s,^VCLIBS_ROOT =.*,VCLIBS_ROOT = $tdir_w32," config/makefile.nt > ttt &&
    mv ttt config/makefile.nt &&
    cd src &&
    nmake -f ../config/makefile.nt &&
    nmake -f ../config/makefile.nt install &&
    mkdir -p "$INSTALL_DIR/doc/gnuplot" &&
	cp "$INSTALL_DIR/Copyright" "$tlicdir/COPYING.GNUPLOT" &&
    mv "$INSTALL_DIR/BUGS" "$INSTALL_DIR/Copyright" "$INSTALL_DIR/FAQ" "$INSTALL_DIR/NEWS" "$INSTALL_DIR/README" \
      "$INSTALL_DIR/doc/gnuplot") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gnuplot-4.2.2"
  download_file gp422win32.zip 'http://downloads.sourceforge.net/gnuplot/gp422win32.zip?modtime=1173777723&big_mirror=0'
  if test -f "$DOWNLOAD_DIR/gp422win32.zip"; then
    (cd "$DOWNLOAD_DIR" && unzip -o -q -j -d "$tbindir" gp422win32.zip gnuplot/bin/wgnuplot.hlp)
  else
    echo "WARNING: could not get wgnuplot.hlp"
  fi
  if failed_package || test ! -f "$tbindir/pgnuplot.exe"; then
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
    vcbuild -upgrade fltkdll.vcproj &&
    vcbuild -upgrade fltk.lib.vcproj &&
    vcbuild -upgrade fltkforms.vcproj &&
    vcbuild -upgrade fltkimages.vcproj &&
    vcbuild -upgrade fluid.vcproj &&
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
    cp fltkdll.dll "$tbindir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/fltk-1.1.7"
  if failed_package || test ! -f "$tbindir/fltkdll.dll"; then
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
    cp qhull.lib "$tlibdir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/qhull-2003.1"
  if failed_package || test ! -f "$tlibdir/qhull.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# libcurl #
###########

if check_package libcurl; then
  download_file curl-$curlver.tar.bz2 http://curl.haxx.se/download/curl-$curlver.tar.bz2
  echo -n "decompressing libcurl... "
  unpack_file curl-$curlver.tar.bz2
  echo "done"
  echo -n "compiling libcurl... "
  (cd "$DOWNLOAD_DIR/curl-$curlver" &&
    for mf in lib/Makefile.vc8 src/Makefile.vc8; do
      sed -e "s/libcurl_imp/libcurl/g" -e "s/zdll\.lib/zlib.lib/g" $mf > ttt &&
      	mv ttt $mf
      if test $crtver -ge 90; then
        sed -e "s/bufferoverflowu\.lib//g" \
            -e "s,/DBUILDING_LIBCURL,& /D_WIN32_WINNT=0x0501," \
            $mf > ttt &&
          mv ttt $mf
      fi
    done
    nmake VC=vc8 vc-dll-zlib-dll &&
    mt -outputresource:lib\\libcurl.dll -manifest lib\\release-dll-zlib-dll\\libcurl.dll.manifest &&
    cp lib/libcurl.dll "$tbindir" &&
    cp lib/libcurl.lib "$tlibdir" &&
    cp COPYING "$tlicdir/COPYING.CURL" &&
    mkdir -p "$tincludedir/curl" && cp include/curl/*.h "$tincludedir/curl") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/curl-$curlver"
  if failed_package || test ! -f "$tbindir/libcurl.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#########
# bzip2 #
#########

if check_package bzip2; then
  download_file bzip2-$bzip2ver.tar.gz http://www.bzip.org/$bzip2ver/bzip2-$bzip2ver.tar.gz
  echo -n "decompressing bzip2... "
  unpack_file bzip2-$bzip2ver.tar.gz
  echo "done"
  echo -n "compiling bzip2... "
  (cd "$DOWNLOAD_DIR/bzip2-$bzip2ver" &&
    create_module_rc BZip2 $bzip2ver libbz2.dll "http://www.bzip.org" \
      "BZip2 - Data Compression Library" "`grep -e '^Copyright ' README`" > bzip2.rc &&
    (cat >> makefile.msc <<\EOF
dll: $(OBJS)
	cl /LD /Felibbz2.dll $(OBJS) bzip2.res /link /implib:bz2.lib /def:libbz2.def
	mt -outputresource:libbz2.dll -manifest libbz2.dll.manifest
EOF
      ) &&
    sed -e "s/^bzip2: .*$/bzip2: dll/" \
        -e "s/libbz2\.lib/bz2.lib/g" makefile.msc > ttt &&
      mv ttt makefile.msc &&
    sed -e "s/WINAPI/__cdecl/g" bzlib.h > ttt &&
      mv ttt bzlib.h &&
    rc -fo bzip2.res bzip2.rc &&
    nmake -f makefile.msc bzip2 &&
    for f in libbz2.dll bzip2.exe bzip2recover.exe; do
      mt -outputresource:$f -manifest $f.manifest
    done &&
    cp libbz2.dll bzip2.exe bzip2recover.exe "$tbindir" &&
    cp bzip2.exe "$tbindir/bunzip2.exe" &&
    cp bzip2.exe "$tbindir/bzcat.exe" &&
    cp bz2.lib "$tlibdir" &&
    cp bzlib.h "$tincludedir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/bzip2-$bzip2ver"
  if failed_package || test ! -f "$tlibdir/bz2.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# libtiff #
###########

if check_package libtiff; then
  download_file tiff-$tiffver.tar.gz ftp://ftp.remotesensing.org/pub/libtiff/tiff-$tiffver.tar.gz
  echo -n "decompressing libtiff... "
  unpack_file tiff-$tiffver.tar.gz
  echo "done"
  echo -n "compiling libtiff... "
  (cd "$DOWNLOAD_DIR/tiff-$tiffver" &&
    create_module_rc LibTIFF $tiffver libtiff.dll "http://www.libtiff.org" \
      "LibTIFF - TIFF Image Library" "Copyright (C) 1988-`date +%Y` Sam Leffler" > libtiff/libtiff.rc &&
    sed -e "s/^#JPEG_SUPPORT/JPEG_SUPPORT/" \
        -e "s/^#ZIP_SUPPORT/ZIP_SUPPORT/" \
        -e "s/^#JPEG_LIB.*$/JPEG_LIB = jpeg.lib/" \
        -e "s/^#ZLIB_LIB.*$/ZLIB_LIB = zlib.lib/" \
        nmake.opt > ttt &&
      mv ttt nmake.opt &&
    sed -e "s/libtiff\.lib/libtiff_i.lib/" tools/Makefile.vc > ttt &&
      mv ttt tools/Makefile.vc &&
    (cd libtiff && rc -fo libtiff.res libtiff.rc) &&
    sed -e "s/^OBJ[ 	]*=/& libtiff.res/" libtiff/Makefile.vc > ttt &&
      mv ttt libtiff/Makefile.vc &&
    nmake -f Makefile.vc &&
    cp libtiff/libtiff.dll "$tbindir" &&
    cp libtiff/libtiff_i.lib "$tlibdir/tiff.lib" &&
    cp tools/*.exe "$tbindir" &&
    cp libtiff/tiff.h libtiff/tiffconf.h libtiff/tiffio.h libtiff/tiffvers.h "$tincludedir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/tiff-$tiffver"
  if failed_package || test ! -f "$tlibdir/tiff.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########
# libwmf #
##########

if check_package libwmf; then
  download_file libwmf-$wmfver.tar.gz "http://downloads.sourceforge.net/wvware/libwmf-$wmfver.tar.gz?big_mirror=0"
  echo -n "decompressing libwmf... "
  unpack_file libwmf-$wmfver.tar.gz
  echo "done"
  echo -n "compiling libwmf... "
  (cd "$DOWNLOAD_DIR/libwmf-$wmfver" &&
    create_module_rc libwmf $wmfver libwmf.dll "http://wvware.sourceforge.net/libwmf.html" \
      "LibWMF - Library for converting WMF" "Copyright (C) wvWare projects" > src/wmf.rc &&
    create_module_rc libwmf $wmfver libwmflite.dll "http://wvware.sourceforge.net/libwmf.html" \
      "LibWMF - Library for converting WMF" "Copyright (C) wvWare projects" > src/wmflite.rc &&
    sed -e "/^LIBS=\"-lpng/ {s/-lm//;}" configure > ttt &&
      mv ttt configure &&
    configure_package --enable-shared --disable-static --disable-gd &&
    post_process_libtool &&
    sed -e "s,/\([a-z]\)/,\1:/,g" libwmf-config > ttt &&
      mv ttt libwmf-config &&
    sed -e "s/^libwmflite_la_LDFLAGS =/& -Wl,-def:wmflite.def -Wl,wmflite.res/" \
        -e "s/^libwmflite\.la:.*$/& wmflite.def wmflite.res/" \
        -e "s/^libwmf_la_LDFLAGS =/& -Wl,-def:wmf.def -Wl,wmf.res/" \
        -e "s/^libwmf\.la:.*$/& wmf.def wmf.res/" \
        src/Makefile > ttt &&
      mv ttt src/Makefile &&
    (cat >> src/Makefile <<\EOF
wmflite.def: $(libwmflite_la_OBJECTS)
	@echo "Generating $@..."
	@echo "EXPORTS" > $@
	@nm $(addprefix .libs/, $(libwmflite_la_OBJECTS:.lo=.o)) | \
	  sed -n -e 's/^[0-9a-fA-F]\+ T _\([^   ]*\).*$$/\1/p' >> $@
wmf.def: $(libwmf_la_OBJECTS)
	@echo "Generating $@..."
	@echo "EXPORTS" > $@
	@nm $(addprefix .libs/, $(libwmf_la_OBJECTS:.lo=.o)) ipa/.libs/libipa.lib | \
	  sed -n -e 's/^[0-9a-fA-F]\+ T _\([^   @]*\).*$$/\1/p' >> $@
wmf.res: wmf.rc
	rc -fo $@ wmf.rc
wmflite.res: wmflite.rc
	rc -fo $@ wmflite.rc
EOF
      ) &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libwmf*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/libwmf-$wmfver"
  if failed_package || test ! -f "$tlibdir/wmf.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########
# jasper #
##########

if check_package jasper; then
  download_file jasper-$jasperver.zip "http://www.ece.uvic.ca/~mdadams/jasper/software/jasper-$jasperver.zip"
  echo -n "decompressing jasper... "
  (cd "$DOWNLOAD_DIR" && unzip -q jasper-$jasperver.zip)
  echo "done"
  echo -n "compiling jasper... "
  (cd "$DOWNLOAD_DIR/jasper-$jasperver" &&
    create_module_rc libjasper $jasperver libjasper.dll "The JasPer Project (http://www.ece.uvic.ca/~mdadams/jasper)" \
      "JasPer - JPEG-2000 Library" "Copyright (C) 1999-`date +%Y` Michael D. Adams" > src/libjasper/jasper.rc &&
    configure_package --enable-shared --disable-static --disable-opengl &&
    post_process_libtool &&
    sed -e "s/^libjasper_la_LDFLAGS =/& -Wl,-def:jasper.def -Wl,jasper.res -no-undefined/" \
        -e "s/^libjasper\.la:.*$/& jasper.def jasper.res/" \
        src/libjasper/Makefile > ttt &&
      mv ttt src/libjasper/Makefile &&
    (cat >> src/libjasper/Makefile <<\EOF
jasper.res: jasper.rc
	rc -fo $@ $<
jasper.def: $(libjasper_la_OBJECTS) $(libjasper_la_LIBADD)
	@echo "Generating $@..."
	@echo "EXPORTS" > $@
	@sublibs=; for lib in $(libjasper_la_LIBADD); do \
	    sublibs="$$sublibs `dirname $$lib`/.libs/`sed -n -e "s/old_library='\(.*\)'/\1/p" $$lib`"; \
	  done;\
	nm $(addprefix .libs/, $(libjasper_la_OBJECTS:.lo=.o)) $$sublibs | \
          grep -v -e ' R __real@[0-9a-fA-F]\+' | \
	  sed -n -e 's/^[0-9a-fA-F]\+ T _\([^         ]*\).*$$/\1/p' \
	         -e 's/^[0-9a-fA-F]\+ [BDGSR] _\([^         ]*\).*$$/\1 DATA/p' >> $@
EOF
      ) &&
    (cd src/libjasper && make && make install) &&
    rm -f $tlibdir_quoted/libjasper*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/jasper-$jasperver"
  if failed_package || test ! -f "$tlibdir/jasper.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##################
# GraphicsMagick #
##################

if check_package GraphicsMagick; then
  download_file GraphicsMagick-$gmagickver.tar.bz2 ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-$gmagickver.tar.bz2
  echo -n "decompressing GraphicsMagick... "
  unpack_file GraphicsMagick-$gmagickver.tar.bz2
  echo "done"
  echo -n "compiling GraphicsMagick... "
  (cd "$DOWNLOAD_DIR/GraphicsMagick-$gmagickver" &&
    create_module_rc GraphicsMagick $gmagickver libGraphicsMagick-1.dll "http://www.graphicsmagick.org" \
      "GraphicsMagick - Image Processing Library" "Copyright (C) 2002-`date +%Y` GraphicsMagick Group" > magick/magick.rc &&
    create_module_rc GraphicsMagick $gmagickver libGraphicsMagick++-1.dll "http://www.graphicsmagick.org" \
      "GraphicsMagick++ - Image Processing Library" "Copyright (C) 2002-`date +%Y` GraphicsMagick Group" > Magick++/lib/magick++.rc &&
    create_module_rc GraphicsMagick $gmagickver libGraphicsMagickWand-1.dll "http://www.graphicsmagick.org" \
      "GraphicsMagickWand - Image Processing Library" "Copyright (C) 2002-`date +%Y` GraphicsMagick Group" > wand/magickwand.rc &&
    W_CPPFLAGS="$W_CPPFLAGS -D_VISUALC_" \
      configure_package --enable-shared --disable-static --without-perl &&
    post_process_libtool &&
    for f in coders/msl.c coders/url.c coders/svg.c; do
      sed -e "s/^# *include <win32config\.h>//g" $f > ttt &&
        mv ttt $f
    done &&
    for f in magick/static.h magick/static.c; do
      sed -e "s/^.*[Rr]egisterXTRNImage.*$//" $f > ttt &&
        mv ttt $f
    done &&
    echo "#define HAVE_MEMCPY 1" >> magick/magick_config.h &&
    sed -e "s/^CPPFLAGS =.*$/& -D_WANDLIB_/" \
        -e "s/^libGraphicsMagickWand_la_LDFLAGS =/& -Wl,magickwand.res/" \
        wand/Makefile > ttt &&
      mv ttt wand/Makefile &&
    sed -e "s/^LTCXXLIBOPTS =.*$/LTCXXLIBOPTS =/" \
        -e "s/^libGraphicsMagick___la_LDFLAGS =/& -no-undefined -Wl,magick++.res/" \
        Magick++/lib/Makefile > ttt &&
      mv ttt Magick++/lib/Makefile &&
    sed -e "s/^libGraphicsMagick_la_LDFLAGS =/& -Wl,magick.res/" \
        -e "/^MAGICK_DEP_LIBS =/ {s/^.*$/& -luser32 -lkernel32 -ladvapi32/;}" \
        magick/Makefile > ttt &&
      mv ttt magick/Makefile &&
    for f in wand/GraphicsMagickWand.pc wand/GraphicsMagickWand-config magick/GraphicsMagick.pc \
             magick/GraphicsMagick-config Magick++/bin/GraphicsMagick++-config \
             Magick++/lib/GraphicsMagick++.pc; do
      sed -e "s,/\([a-z]\)/,\1:/,g" $f > ttt &&
        mv ttt $f
    done &&
    (cd magick && rc -fo magick.res magick.rc) &&
    (cd wand && rc -fo magickwand.res magickwand.rc) &&
    (cd Magick++/lib && rc -fo magick++.res magick++.rc) &&
    make &&
    make install
    rm -f $tlibdir_quoted/libGraphicsMagicks*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/GraphicsMagick-$gmagickver"
  if failed_package || test ! -f "$tlibdir/GraphicsMagick.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###############
# ImageMagick #
###############

if check_package ImageMagick; then
  download_file ImageMagick.tar.gz ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick.tar.gz
  echo -n "decompressing ImageMagick... "
  unpack_file ImageMagick.tar.gz
  echo "done"
  echo -n "compiling ImageMagick... "
  (cd "$DOWNLOAD_DIR/ImageMagick-$imagickver" &&
    create_module_rc ImageMagick $imagickver libMagick-10.dll "http://www.imagemagick.org" \
      "ImageMagick - Image Processing Library" "`grep -e '^Copyright ' LICENSE | sed -e 's/,.*$//'`" > magick/magick.rc &&
    create_module_rc ImageMagick $imagickver libMagick++-10.dll "http://www.imagemagick.org" \
      "ImageMagick - Image Processing Library" "`grep -e '^Copyright ' LICENSE | sed -e 's/,.*$//'`" > Magick++/lib/magick++.rc &&
    create_module_rc ImageMagick $imagickver libWand-10.dll "http://www.imagemagick.org" \
      "ImageMagick - Image Processing Library" "`grep -e '^Copyright ' LICENSE | sed -e 's/,.*$//'`" > wand/magickwand.rc &&
    W_CPPFLAGS="$W_CPPFLAGS -D_VISUALC_" \
      configure_package --prefix="$INSTALL_DIR" --enable-shared --disable-static --without-perl \
      --with-xml --without-modules --with-wmf &&
    post_process_libtool &&
    #read -p "WARNING: libtool needs manual post-processing; press <ENTER> when done " &&
    for f in coders/msl.c coders/url.c coders/svg.c; do
      sed -e "s/^# *include <win32config\.h>//g" $f > ttt &&
        mv ttt $f
    done &&
    for f in magick/static.h magick/static.c; do
      sed -e "s/^.*[Rr]egisterXTRNImage.*$//" $f > ttt &&
        mv ttt $f
    done &&
    (cat >> magick/magick-config.h <<\EOF
#ifndef __cplusplus
#define inline __inline
#endif
#ifdef MAGICKCORE_WMFLITE_DELEGATE 
#define MAGICKCORE_WMF_DELEGATElite  1 
#endif
EOF
      ) &&
    sed -e "s/^wand_libWand_la_LDFLAGS =/& -Wl,wand\/magickwand.res/" \
        -e "s/^Magick___lib_libMagick___la_LDFLAGS =/& -no-undefined -Wl,Magick++\/lib\/magick++.res/" \
        -e "s/^magick_libMagick_la_LDFLAGS =/& -Wl,magick\/magick.res/" \
        -e "s/^LTCXXLIBOPTS =.*$/LTCXXLIBOPTS =/" \
        -e "/^MAGICK_DEP_LIBS =/ {s/^.*$/& -luser32 -lkernel32 -ladvapi32/;}" \
        -e "s/^LIBWAND =.*$/LIBWAND =/" \
        -e "s/magick_libMagick_la-\([^ 	]*\)\.lo/\1.lo/g" \
        -e "s/wand_libWand_la-\([^ 	]*\)\.lo/\1.lo/g" \
        -e 's/^magick_libMagick_la_OBJECTS =.*$/& $(am_wand_libWand_la_OBJECTS)/' \
        -e "s/-export-symbols-regex \"[^\"]*\"//g" \
        Makefile > ttt &&
      mv ttt Makefile &&
    for f in wand/Wand.pc wand/Wand-config magick/ImageMagick.pc \
             magick/Magick-config Magick++/bin/Magick++-config \
             Magick++/lib/ImageMagick++.pc; do
      sed -e "s,/\([a-z]\)/,\1:/,g" -e "s/-lWand//g" $f > ttt &&
        mv ttt $f
    done &&
    (cd magick && rc -fo magick.res magick.rc) &&
    (cd wand && rc -fo magickwand.res magickwand.rc) &&
    (cd Magick++/lib && rc -fo magick++.res magick++.rc) &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libWand*.la &&
    rm -f $tlibdir_quoted/libMagick*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/ImageMagick-$imagickver"
  if failed_package || test ! -f "$tlibdir/Magick.lib"; then
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
    #FIXME: remove this - specific to 2.9.19 version
    (cd "$DOWNLOAD_DIR/octave-$octave_version" &&
      sed -e 's/trunc/ceil/' src/graphics.cc > ttt &&
        mv ttt src/graphics.cc)
    echo "done"
  fi
  echo -n "compiling octave... "
  (cd "$DOWNLOAD_DIR/octave-$octave_version" &&
    #sed -e 's/\(^.*SUBDIRS = .*\)doc examples$/\1 examples/' octMakefile.in > ttt &&
    #mv ttt octMakefile.in &&
    if test ! -f "config.log"; then
      CC=cc-msvc CXX=cc-msvc CFLAGS=-O2 CXXFLAGS=-O2 NM="dumpbin -symbols" \
        F77=fc-msvc FFLAGS="-O2" FC=fc-msvc FCFLAGS="-O2" AR=ar-msvc RANLIB=ranlib-msvc \
        ./configure --build=i686-pc-msdosmsvc --prefix="$octave_prefix" \
        --with-zlib=zlib --with-curl=libcurl &&
        (cd doc &&
          make conf.texi &&
          sed -e 's,/\([a-z]\)/,\1:/,' conf.texi > ttt &&
          mv ttt conf.texi)
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
    cp NEWS THANKS README "$octave_prefix/doc" &&
    mkdir -p "$octave_prefix/share/info" &&
    cp doc/interpreter/octave.info* "$octave_prefix/share/info" &&
    make -f octMakefile mkoctfile.exe octave-config.exe &&
    rm -f "$octave_prefix/bin/mkoctfile" "$octave_prefix/bin/mkoctfile-$octave_version" &&
    rm -f "$octave_prefix/bin/octave-config" "$octave_prefix/bin/octave-config-$octave_version" &&
    cp mkoctfile.exe "$octave_prefix/bin/mkoctfile.exe" &&
    cp mkoctfile.exe "$octave_prefix/bin/mkoctfile-$octave_version.exe" &&
    cp octave-config.exe "$octave_prefix/bin/octave-config.exe" &&
    cp octave-config.exe "$octave_prefix/bin/octave-config-$octave_version.exe" &&
    cp octaverc.win "$octave_prefix/share/octave/$octave_version/m/startup/octaverc"
    ) >&5 2>&1 && end_package
  if failed_package || test ! -f "$INSTALL_DIR/local/octave-$octave_version/bin/octave.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

# Add octave to the PATH (if needed) and make sure octave_prefix is defined

if test -n "$octave_version"; then
  if test -z "$octave_prefix"; then
    octave_prefix="$INSTALL_DIR/local/octave-$octave_version"
  fi
  if test -n "`which octave.exe`"; then
    echo "WARNING: octave is already in your PATH."
    echo "WARNING: overridding with $octave_prefix."
  fi
  export PATH="$octave_prefix/bin:$PATH"
elif test -n "`which octave-config.exe`"; then
  octave_prefix="`octave-config -p PREFIX | sed -e 's,\\,/,g'`"
  octave_prefix="`cd $octave_prefix && pwd`"
else
  echo "WARNING: octave is not in your PATH."
  echo "WARNING: some packages might not compile properly."
fi

#############
# PortAudio #
#############

if check_package PortAudio; then
  download_file pa_stable_v19_20071207.tar.gz http://www.portaudio.com/archives/pa_stable_v19_20071207.tar.gz
  echo -n "decompressing PortAudio... "
  unpack_file pa_stable_v19_20071207.tar.gz
  echo "done"
  echo "compiling PortAudio... "
  (cd "$DOWNLOAD_DIR/portaudio" &&
    sed -e "s/-lm//g" \
        -e "s/-ldsound//g" \
        -e "s/-lole32/-lole32 -luser32 -lkernel32/" \
        -e "s/-mthreads//" \
        -e "s/-L[^ ]*dx7sdk[^ ]*//" \
        -e 's/" -DPA_NO_WDMKS;/ -DPA_NO_WDMKS";/' \
        -e 's/OTHER_OBJS="\(.*\)"/OTHER_OBJS="\1 src\/os\/win\/pa_win_waveformat.o"/' \
        configure > ttt &&
      mv ttt configure &&
    sed -e "s,src/os/unix,src/os/win," \
        -e "s/	\$(MAKE) install-recursive//" \
        Makefile.in > ttt &&
      mv ttt Makefile.in
    configure_package --enable-shared --disable-static --with-winapi=directx &&
    sed -e "s/-lportaudio .*/-lportaudio/" portaudio-2.0.pc > ttt &&
      mv ttt portaudio-2.0.pc &&
    post_process_libtool &&
    make lib/libportaudio.la &&
    make install &&
    rm -f $tlibdir_quoted/libportaudio*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/portaudio"
  if failed_package || test ! -f "$tlibdir/portaudio.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# playrec #
###########

if check_package playrec; then
  download_file playrec_2_1_0.zip http://www.playrec.co.uk/download/playrec_2_1_0.zip
  if test -n "`which mkoctfile.exe`"; then
    echo -n "decompressing playrec... "
    (cd "$DOWNLOAD_DIR" && unzip -q playrec_2_1_0.zip)
    echo "done"
    target="`octave-config -p OCTFILEDIR | sed -e 's,\\\\,/,g'`/playrec.mex"
    echo "compiling playrec... "
    (cd "$DOWNLOAD_DIR/playrec_2_1_0/src" &&
      mkoctfile -c `pkg-config --cflags portaudio-2.0` pa_dll_playrec.c &&
      mkoctfile -c `pkg-config --cflags portaudio-2.0` mex_dll_core.c &&
      mkoctfile --mex -o playrec.mex `pkg-config --libs portaudio-2.0` *.o &&
      cp playrec.mex "$target") >&5 2>&1 && end_package
    remove_package "$DOWNLOAD_DIR/playrec_2_1_0"
    if failed_package || test ! -f "$target"; then
      echo "failed"
      exit -1
    else
      echo "done"
    fi
  else
    echo "octave must be in your PATH in order to compile playrec"
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
    cat LICENSE-JOGL-1.1.0.txt >> "$tlicdir/COPYING.JOGL") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/jogl-1.1.0-windows-i586"
  if failed_package || test ! -f "$tbindir/jogl.jar"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########
# FTPlib #
##########

if check_package FTPlib; then
  download_file ftplib-3.1-1.zip 'http://www.nbpfaus.net/~pfau/ftplib/ftplib-3.1-1.zip'
  echo -n "decompressing FTPlib... "
  (cd "$DOWNLOAD_DIR" && unzip -q ftplib-3.1-1.zip)
  echo "done"
  echo -n "installing FTPlib... "
  (cd "$DOWNLOAD_DIR/ftplib-3.1-1" &&
    cd winnt &&
    create_module_rc FTPlib 3.1 libftp-3.dll "Thomas Pfau <pfau@eclipse.net>" \
      "FTP Protocol Library" "Copyright © 1996-`date +%Y` Thomas Pfau <pfau@eclipse.net>" > ftplib.rc &&
    cc-msvc -O2 -MD -c ftplib.c &&
    rc -fo ftplib.res ftplib.rc &&
    cc-msvc -shared -o libftp-3.dll -Wl,-implib:ftp.lib ftplib.o ftplib.res -lws2_32 &&
    cp libftp-3.dll "$tbindir" &&
    cp ftplib.h "$tincludedir" &&
    cp ftp.lib "$tlibdir") >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/ftplib-3.1-1"
  if failed_package || test ! -f "$tlibdir/ftp.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# SQLite3 #
###########

if check_package SQLite3; then
  download_file sqlite-amalgamation-$sqlite3ver.tar.gz "http://www.sqlite.org/sqlite-amalgamation-$sqlite3ver.tar.gz"
  echo -n "decompressing SQLite3... "
  unpack_file sqlite-amalgamation-$sqlite3ver.tar.gz
  echo "done"
  echo "compiling SQLite3... "
  (cd "$DOWNLOAD_DIR/sqlite-$sqlite3ver" &&
    W_CPPFLAGS="$W_CPPFLAGS -DSQLITE_ENABLE_COLUMN_METADATA" configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e 's/libsqlite3_la_LDFLAGS =/& -export-symbols-regex "^sqlite3_.*"/' Makefile > ttt &&
      mv ttt Makefile &&
    make libsqlite3.la &&
    sed -e '/^#ifndef SQLITE_EXTERN$/ {i \
#ifdef WIN32\
#define SQLITE_EXTERN extern __declspec(dllimport)\
#endif
;}' sqlite3.h > ttt &&
      mv ttt sqlite3.h &&
    make install-libLTLIBRARIES install-includeHEADERS &&
    rm -f $tlibdir_quoted/libsqlite3*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/sqlite-$sqlite3ver"
  if failed_package || test ! -f "$tlibdir/sqlite3.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########
# FFMpeg #
##########

if check_package FFMpeg; then
  download_file ffmpeg-export-snapshot.tar.bz2 "http://ffmpeg.mplayerhq.hu/ffmpeg-export-snapshot.tar.bz2"
  echo -n "decompressing FFMpeg..."
  unpack_file ffmpeg-export-snapshot.tar.bz2
  ffmpegdir=`find "$DOWNLOAD_DIR" -maxdepth 1 -type d -a -name "ffmpeg-export-*" -printf '%f\n' | sed -e "1q"`
  cp libs/ffmpeg.diff "$DOWNLOAD_DIR/$ffmpegdir/ffmpeg.diff"
  echo "done"
  echo -n "compiling FFMpeg..."
  (cd "$DOWNLOAD_DIR/$ffmpegdir" &&
    patch -p1 < ffmpeg.diff &&
	  start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login -c "cd `pwd -W` && ./configure --prefix=\"$tdir_w32_forward\" --enable-avisynth --enable-gpl --enable-shared --disable-static --enable-w32threads --enable-avfilter --enable-swscale --extra-cflags=\"-mno-cygwin -mms-bitfields\" --extra-ldflags=\"-mno-cygwin -mms-bitfields\" --target-os=mingw32 --enable-memalign-hack --disable-mmx --disable-vhook --disable-debug --disable-ffmpeg --disable-ffserver --disable-ffplay" &&
    # some tricks to allow MinGW to link against MSVCR80.DLL instead of MSVCRT.DLL
    #sed -e "s/^EXTRALIBS *=/& -nostdlib -lmingwex -lgcc -lmsvcr80/" \
    #    -e "s/^EXTRALIBS *=.*$/& -luser32 -lkernel32/" \
    #    config.mak > ttt &&
    #  mv ttt config.mak &&
    sed -e "s/^EXTRALIBS *=/& -lmsvcr$crtver/" \
        config.mak > ttt &&
      mv ttt config.mak &&
    start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login \
      -c "cd `pwd -W` && for lib in avutil avcodec avformat swscale avfilter avdevice; do make -C lib\$lib; done" &&
    for lib in avutil avcodec avformat swscale avfilter avdevice; do
      (cd lib$lib &&
        deffile=`find -name "lib$lib-*.def"` &&
        sed -e "s/@[0-9]\+//" $deffile > ttt &&
          mv ttt $deffile &&
        lib -machine:i386 -def:$deffile)
    done &&
    start "//wait" "$CYGWIN_DIR/bin/bash.exe" --login \
      -c "cd `pwd -W` && for lib in avutil avcodec avformat swscale avfilter avdevice; do make -C lib\$lib install; done" &&
    true) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/$ffmpegdir"
  if failed_package || test ! -f "$tlibdir/avcodec.lib"; then
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
          TERM=vt100 "$octave_prefix/bin/octave.exe" -q -f -H --eval "page_screen_output(0); pkg install $auto_ -verbose $packpack"
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

extra_pkgs="fpl msh ad bim civil-engineering integration java jhandles mapping nan ocs secs1d secs2d symband triangular tsa windows"
# packages to fix:
# new packages:
# unsupported packages: engine graceplot multicore pdb tcl-octave xraylib
main_pkgs="signal ann audio bioinfo combinatorics communications control database data-smoothing econometrics time financial fixed ftp miscellaneous ga general gsl ident image informationtheory io irsa linear-algebra missing-functions nnet octcdf odebvp odepkg optim outliers physicalconstants plot sockets specfun special-matrix splines statistics strings struct symbolic video"
# packages to fix: octgpr
# new packages:
# unsupported packages: optiminterp parallel vrml zenity
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
    (cd "$DOWNLOAD_DIR" && tar xfz octave-forge-bundle-$of_version.tar.gz > /dev/null 2>&1)
	if ! test -d "DOWNLOAD_DIR/octave-forge-bundle-$of_version"; then
      (cd "$DOWNLOAD_DIR" && tar xf octave-forge-bundle-$of_version.tar.gz > /dev/null 2>&1)
	fi
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
    make install) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/octplot-0.4.0"
  if failed_package || test ! -f "$INSTALL_DIR/local/octave-$octave_version/share/octplot/oct/octplot.exe"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#######
# ATK #
#######

if check_package ATK; then
  atkroot=`echo $atkver | sed -e 's/\.[0-9]\+$//'`
  download_file atk-$atkver.tar.bz2 "ftp://ftp.gnome.org/pub/gnome/sources/atk/$atkroot/atk-$atkver.tar.bz2"
  echo -n "decompressing ATK... "
  unpack_file atk-$atkver.tar.bz2
  echo "done"
  echo "compiling ATK... "
  (cd "$DOWNLOAD_DIR/atk-$atkver" &&
    configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "s/^SUBDIRS =.*/SUBDIRS = atk/" Makefile > ttt &&
      mv ttt Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libatk*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/atk-$atkver"
  if failed_package || test ! -f "$tbindir/libatk-1.0-0.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#######
# GTK #
#######

if check_package GTK; then
  gtkroot=`echo $gtkver | sed -e 's/\.[0-9]\+$//'`
  download_file gtk+-$gtkver.tar.bz2 "ftp://ftp.gnome.org/pub/gnome/sources/gtk+/$gtkroot/gtk+-$gtkver.tar.bz2"
  echo -n "decompressing GTK... "
  unpack_file gtk+-$gtkver.tar.bz2
  echo "done"
  echo "compiling GTK... "
  (cd "$DOWNLOAD_DIR/gtk+-$gtkver" &&
    sed -e "s/use_x86_asm=yes/use_x86_asm=no/" \
        -e "s/-limm32/-luser32 -ladvapi32 -lkernel32 -limm32/" \
        -e "s/-ltiff -lm/-ltiff/" \
        configure > ttt &&
      mv ttt configure &&
    configure_package --enable-shared --disable-static --disable-cups --with-included-loaders &&
    sed -e 's///g' config.status > ttt &&
      mv ttt config.status &&
    ./config.status &&
    post_process_libtool &&
    sed -e "s/input//" modules/Makefile > ttt &&
      mv ttt modules/Makefile &&
    sed -e "s/snprintf/_snprintf/" gdk-pixbuf/io-tiff.c > ttt &&
      mv ttt gdk-pixbuf/io-tiff.c &&
    sed -e "s/^[ 	]*notebook = /GtkNotebook* notebook = /" modules/engines/ms-windows/msw_style.c > ttt &&
      mv ttt modules/engines/ms-windows/msw_style.c &&
    sed -e "/^SRC_SUBDIRS =/ {s/tests//;}" \
        -e "/^SUBDIRS =/ {s/docs//;}" \
        Makefile > ttt &&
      mv ttt Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libgtk*.la $tlibdir_quoted/libgdk*.la &&
    find "$tlibdir/gtk-2.0" -name "lib*.la" | xargs rm -f) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gtk+-$gtkver"
  if failed_package || test ! -f "$tbindir/libgtk-win32-2.0-0.dll"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#############
# libsigc++ #
#############

if check_package libsigc++; then
  libsigcroot=`echo $libsigcver | sed -e 's/\.[0-9]\+$//'`
  download_file libsigc++-$libsigcver.tar.bz2 "http://ftp.gnome.org/pub/GNOME/sources/libsigc++/$libsigcroot/libsigc++-$libsigcver.tar.bz2"
  echo -n "decompressing libsigc++... "
  unpack_file libsigc++-$libsigcver.tar.bz2
  echo "done"
  echo "compiling libsigc++... "
  (cd "$DOWNLOAD_DIR/libsigc++-$libsigcver" &&
    configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "s/^SUBDIRS =.*/SUBDIRS = sigc++/" Makefile > ttt &&
      mv ttt Makefile &&
    (cat >> sigc++/Makefile <<\EOF
sigc-2.0.res: ../MSVC_Net2003/sigc-2.0.rc
	rc -fo $@ ../MSVC_Net2003/sigc-2.0.rc
EOF
      ) &&
    sed -e "s/^DEFS =.*/& -DSIGC_BUILD -D_WINDLL/" \
        -e "s/libsigc-2\.0\.la:.*/& sigc-2.0.res/" \
        -e "s/-Wl,--export-all-symbols/-Wl,sigc-2.0.res/" \
        sigc++/Makefile > ttt &&
      mv ttt sigc++/Makefile &&
    sed -e 's/^#include "resource.h"/#include <windows.h>/' \
        -e '/^#include "afxres.h".*/d' \
        MSVC_Net2003/sigc-2.0.rc > ttt &&
      mv ttt MSVC_Net2003/sigc-2.0.rc &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libsigc*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/libsigc++-$libsigcver"
  if failed_package || test ! -f "$tlibdir/sigc-2.0.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

##########
# glibmm #
##########

if check_package Glibmm; then
  glibmmroot=`echo $glibmmver | sed -e 's/\.[0-9]\+$//'`
  download_file glibmm-$glibmmver.tar.bz2 "http://ftp.gnome.org/pub/GNOME/sources/glibmm/$glibmmroot/glibmm-$glibmmver.tar.bz2"
  echo -n "decompressing glibmm... "
  unpack_file glibmm-$glibmmver.tar.bz2
  echo "done"
  echo "compiling glibmm... "
  (cd "$DOWNLOAD_DIR/glibmm-$glibmmver" &&
    configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "s/^SUBDIRS =.*/SUBDIRS = glib/" Makefile > ttt &&
      mv ttt Makefile &&
    (cat >> glib/glibmm/Makefile <<\EOF
glibmm.def: ../../MSVC_Net2003/gendef/Release/gendef.exe
	../../MSVC_Net2003/gendef/Release/gendef.exe glibmm.def glibmm.dll .libs/*.o
	sed -e "s/^LIBRARY .*//" $@ > ttt && mv ttt $@

glibmm.res: ../../MSVC_Net2003/glibmm/glibmm.rc
	rc -fo $@ ../../MSVC_Net2003/glibmm/glibmm.rc

../../MSVC_Net2003/gendef/Release/gendef.exe:
	(cd ../../MSVC_Net2003/gendef && vcbuild -u gendef.vcproj)
EOF
      ) &&
    sed -e "s/^libglibmm-2\.4\.la:.*/& glibmm.def glibmm.res/" \
        -e "s/-Wl,--export-all-symbols/-Wl,-def:glibmm.def -Wl,glibmm.res/" \
        glib/glibmm/Makefile > ttt &&
      mv ttt glib/glibmm/Makefile &&
    sed -e 's/^#include "resource.h"/#include <windows.h>/' \
        -e '/^#include "afxres.h".*/d' \
        MSVC_Net2003/glibmm/glibmm.rc > ttt &&
      mv ttt MSVC_Net2003/glibmm/glibmm.rc &&
    vcbuild -upgrade MSVC_Net2003\\gendef\\gendef.vcproj &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libglibmm*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/glibmm-$glibmmver"
  if failed_package || test ! -f "$tlibdir/glibmm-2.4.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

###########
# cairomm #
###########

if check_package Cairomm; then
  cairommroot=`echo $cairommver | sed -e 's/\.[0-9]\+$//'`
  download_file cairomm-$cairommver.tar.gz "http://cairographics.org/releases/cairomm-$cairommver.tar.gz"
  echo -n "decompressing cairomm... "
  unpack_file cairomm-$cairommver.tar.gz
  echo "done"
  echo "compiling cairomm... "
  (cd "$DOWNLOAD_DIR/cairomm-$cairommver" &&
    configure_package --enable-shared --disable-static --disable-docs &&
    post_process_libtool &&
    (cat >> cairomm/Makefile <<\EOF
cairomm.def: ../MSVC/gendef/Release/gendef.exe
	../MSVC/gendef/Release/gendef.exe cairomm.def cairomm.dll .libs/*.o
	sed -e "s/^LIBRARY .*//" $@ > ttt && mv ttt $@

cairomm.res: ../MSVC/cairomm/cairomm.rc
	rc -fo $@ ../MSVC/cairomm/cairomm.rc

../MSVC/gendef/Release/gendef.exe:
	(cd ../MSVC/gendef && vcbuild -u gendef.vcproj)
EOF
      ) &&
    sed -e "s/^libcairomm-1\.0\.la:.*/& cairomm.def cairomm.res/" \
        -e "s/-Wl,--export-all-symbols/-Wl,-def:cairomm.def -Wl,cairomm.res/" \
        cairomm/Makefile > ttt &&
      mv ttt cairomm/Makefile &&
    sed -e 's/^#include "resource.h"/#include <windows.h>/' \
        -e '/^#include "afxres.h".*/d' \
        MSVC/cairomm/cairomm.rc > ttt &&
      mv ttt MSVC/cairomm/cairomm.rc &&
    vcbuild -upgrade MSVC\\gendef\\gendef.vcproj &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libcairomm*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/cairomm-$cairommver"
  if failed_package || test ! -f "$tlibdir/cairomm-1.0.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#########
# gtkmm #
#########

if check_package Gtkmm; then
  gtkmmroot=`echo $gtkmmver | sed -e 's/\.[0-9]\+$//'`
  download_file gtkmm-$gtkmmver.tar.bz2 "http://ftp.gnome.org/pub/GNOME/sources/gtkmm/$gtkmmroot/gtkmm-$gtkmmver.tar.bz2"
  echo -n "decompressing gtkmm... "
  unpack_file gtkmm-$gtkmmver.tar.bz2
  echo "done"
  echo "compiling gtkmm... "
  (cd "$DOWNLOAD_DIR/gtkmm-$gtkmmver" &&
    configure_package --enable-shared --disable-static --disable-docs --disable-examples --disable-demos &&
    post_process_libtool &&
    sed -e "/^SUBDIRS =/ {s/tools//;s/tests//;}" Makefile > ttt &&
      mv ttt Makefile &&
    for module in atk pango gdk gtk; do
      modulemm="${module}mm" &&
      (cat >> $module/$modulemm/Makefile <<EOF
$modulemm.def: ../../MSVC_Net2003/gendef/Release/gendef.exe
	../../MSVC_Net2003/gendef/Release/gendef.exe $modulemm.def $modulemm.dll .libs/*.o
	sed -e "s/^LIBRARY .*//" \$@ > ttt && mv ttt \$@

$modulemm.res: ../../MSVC_Net2003/$modulemm/$modulemm.rc
	rc -fo \$@ ../../MSVC_Net2003/$modulemm/$modulemm.rc

../../MSVC_Net2003/gendef/Release/gendef.exe:
	(cd ../../MSVC_Net2003/gendef && vcbuild -u gendef.vcproj)
EOF
        ) &&
      sed -e "s/^lib$modulemm-.*\.la:.*/& $modulemm.def $modulemm.res/" \
          -e "s/-Wl,--export-all-symbols/-Wl,-def:$modulemm.def -Wl,$modulemm.res/" \
          $module/$modulemm/Makefile > ttt &&
        mv ttt $module/$modulemm/Makefile &&
      sed -e 's/^#include "resource.h"/#include <windows.h>/' \
          -e '/^#include "afxres.h".*/d' \
          MSVC_Net2003/$modulemm/$modulemm.rc > ttt &&
        mv ttt MSVC_Net2003/$modulemm/$modulemm.rc
    done &&
    vcbuild -upgrade MSVC_Net2003\\gendef\\gendef.vcproj &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/lib*mm*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gtkmm-$gtkmmver"
  if failed_package || test ! -f "$tlibdir/gtkmm-2.4.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

############
# libglade #
############

if check_package libglade; then
  libgladeroot=`echo $libgladever | sed -e 's/\.[0-9]\+$//'`
  download_file libglade-$libgladever.tar.bz2 "http://ftp.gnome.org/pub/GNOME/sources/libglade/$libgladeroot/libglade-$libgladever.tar.bz2"
  echo -n "decompressing libglade... "
  unpack_file libglade-$libgladever.tar.bz2
  echo "done"
  echo "compiling libglade... "
  (cd "$DOWNLOAD_DIR/libglade-$libgladever" &&
    configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "/^SUBDIRS =/ {s/doc//;}" Makefile > ttt &&
      mv ttt Makefile &&
    sed -e "/^install-data-local:/ {s/install-libtool-import-lib//;}" glade/Makefile > ttt &&
      mv ttt glade/Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libglade*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/libglade-$libgladever"
  if failed_package || test ! -f "$tlibdir/glade-2.0.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#######
# gdl #
#######

if check_package gdl; then
  gdlroot=`echo $gdlver | sed -e 's/\.[0-9]\+$//'`
  download_file gdl-$gdlver.tar.bz2 "http://ftp.gnome.org/pub/GNOME/sources/gdl/$gdlroot/gdl-$gdlver.tar.bz2"
  echo -n "decompressing gdl... "
  unpack_file gdl-$gdlver.tar.bz2
  echo "done"
  echo "compiling gdl... "
  (cd "$DOWNLOAD_DIR/gdl-$gdlver" &&
    sed -e "s/^IT_PROG_INTLTOOL/#&/" configure.in > ttt &&
      mv ttt configure.in &&
    autoconf &&
    configure_package --enable-shared --disable-static --disable-gnome &&
    post_process_libtool &&
    sed -e "/^SUBDIRS =/ {s/docs//;s/po//;}" Makefile > ttt &&
      mv ttt Makefile &&
    for f in gdl/gdl-tools.h gdl/gdl-dock-object.h; do
      sed -e "s/\.\.\.//" -e "s/##args/args/" $f > ttt &&
        mv ttt $f
    done &&
    sed -e "s/-Wl,--export-all-symbols/-export-symbols-regex '^gdl.*'/" gdl/Makefile > ttt &&
      mv ttt gdl/Makefile &&
    sed -e "s/snprintf/_snprintf/" gdl/test-dock.c > ttt &&
      mv ttt gdl/test-dock.c &&
    sed -e '/^gdl_dock_item_hide_item/,/^}/ {s/gboolean//;s/gint//;s/^{/&gboolean isFloating; gint width,height,x,y;/;}' \
        gdl/gdl-dock-item.c > ttt &&
      mv ttt gdl/gdl-dock-item.c &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libgdl*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gdl-$gdlver"
  if failed_package || test ! -f "$tlibdir/gdl-1.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#################
# gtksourceview #
#################

if check_package gtksourceview; then
  gtksourceviewroot=`echo $gtksourceviewver | sed -e 's/\.[0-9]\+$//'`
  download_file gtksourceview-$gtksourceviewver.tar.bz2 "http://ftp.gnome.org/pub/GNOME/sources/gtksourceview/$gtksourceviewroot/gtksourceview-$gtksourceviewver.tar.bz2"
  echo -n "decompressing gtksourceview... "
  unpack_file gtksourceview-$gtksourceviewver.tar.bz2
  echo "done"
  echo "compiling gtksourceview... "
  (cd "$DOWNLOAD_DIR/gtksourceview-$gtksourceviewver" &&
    sed -e "s/^IT_PROG_INTLTOOL/#&/" configure.ac > ttt &&
      mv ttt configure.ac &&
    autoconf &&
    configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "/^SUBDIRS =/ {s/docs//;s/po//;}" Makefile > ttt &&
      mv ttt Makefile &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libgtksourceview*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gtksourceview-$gtksourceviewver"
  if failed_package || test ! -f "$tlibdir/gtksourceview-2.0.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

if check_package Gtksourceview1; then
  gtksourceview1root=`echo $gtksourceview1ver | sed -e 's/\.[0-9]\+$//'`
  download_file gtksourceview-$gtksourceview1ver.tar.bz2 "http://ftp.gnome.org/pub/GNOME/sources/gtksourceview/$gtksourceview1root/gtksourceview-$gtksourceview1ver.tar.bz2"
  echo -n "decompressing gtksourceview1... "
  unpack_file gtksourceview-$gtksourceview1ver.tar.bz2
  echo "done"
  echo "compiling gtksourceview1... "
  (cd "$DOWNLOAD_DIR/gtksourceview-$gtksourceview1ver" &&
    sed -e "s/^IT_PROG_INTLTOOL/#&/" configure.in > ttt &&
      mv ttt configure.in &&
    autoconf &&
    configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "/^SUBDIRS =/ {s/docs//;s/po//;}" Makefile > ttt &&
      mv ttt Makefile &&
    sed -e '/^prefix/ {s,/\([a-z]\)/,\1:/,;}' gtksourceview-1.0.pc > ttt &&
      mv ttt gtksourceview-1.0.pc &&
    sed -e 's/-no-undefined/& -export-symbols-regex "^gtk_source_*|^gtk_text_region_*"/' \
        gtksourceview/Makefile > ttt &&
      mv ttt gtksourceview/Makefile &&
    sed -e '/#include <sys\/types.h>/ {a \
#include <io.h>
;}'
        gtksourceview/gnu-regex/regex.c > ttt &&
      mv ttt gtksourceview/gnu-regex/regex.c &&
    sed -e '/^regerror/,/^{/ {s/^regerror.*/regerror(int errcode,const regex_t *preg,char *errbuf,size_t errbuf_size)/;s/^.*;//;}' \
        gtksourceview/gnu-regex/regcomp.c > ttt &&
      mv ttt gtksourceview/gnu-regex/regcomp.c &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libgtksourceview-1.0*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gtksourceview-$gtksourceview1ver"
  if failed_package || test ! -f "$tlibdir/gtksourceview-1.0.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#######
# VTE #
#######

if check_package VTE; then
  vteroot=`echo $vtever | sed -e 's/\.[0-9]\+$//'`
  download_file vte-$vtever.tar.bz2 "http://ftp.gnome.org/pub/GNOME/sources/vte/$vteroot/vte-$vtever.tar.bz2"
  echo -n "decompressing VTE... "
  unpack_file vte-$vtever.tar.bz2
  cp libs/vte-$vtever.diff "$DOWNLOAD_DIR/vte-$vtever"
  echo "done"
  echo "compiling VTE... "
  (cd "$DOWNLOAD_DIR/vte-$vtever" &&
    patch -p1 < vte-$vtever.diff &&
    sed -e "s/^IT_PROG_INTLTOOL/#&/" configure.in > ttt &&
      mv ttt configure.in &&
    autoconf &&
    configure_package --enable-shared --disable-static --disable-python --disable-gnome-pty-helper &&
    post_process_libtool &&
    make -C src libvte.la &&
    make -C src install-libLTLIBRARIES install-pkgincludeHEADERS &&
    make install-pkgconfigDATA &&
    make -C termcaps install
    rm -f $tlibdir_quoted/libvte*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/vte-$vtever"
  if failed_package || test ! -f "$tlibdir/vte.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

#############
# GtkGlArea #
#############

if check_package GtkGlArea; then
  gtkglarearoot=`echo $gtkglareaver | sed -e 's/\.[0-9]\+$//'`
  download_file gtkglarea-$gtkglareaver.tar.gz "http://ftp.gnome.org/pub/GNOME/sources/gtkglarea/$gtkglarearoot/gtkglarea-$gtkglareaver.tar.gz"
  echo -n "decompressing GtkGlArea... "
  unpack_file gtkglarea-$gtkglareaver.tar.gz
  echo "done"
  echo "compiling GtkGlArea... "
  (cd "$DOWNLOAD_DIR/gtkglarea-$gtkglareaver" &&
    sed -e "s/-lGLU/-lglu32/g" \
        -e "s/-lGL/-lopengl32/g" \
        -e "/^ *char glBegin()/ {s/glBegin()/__stdcall glBegin(int)/;s/glBegin()/glBegin(0)/;}" \
        configure > ttt &&
      mv ttt configure &&
    configure_package --enable-shared --disable-static &&
    post_process_libtool &&
    sed -e "s/gdkgl\.lo/gdkgl-win32.lo/" \
        -e 's/^libgtkgl.*_LDFLAGS =/& -no-undefined -export-symbols-regex "^gtk_gl_area_.*|^gdk_gl_.*"/' \
        gtkgl/Makefile > ttt &&
      mv ttt gtkgl/Makefile &&
    sed -e "/#include/ {s,gdk/win32,gdk,;}" \
        -e "s/GDK_DRAWABLE_XID/GDK_WINDOW_HWND/g" \
	-e "s/\(HFONT old_font =\).*/\1 SelectObject (dc, GetStockObject (SYSTEM_FONT));/" \
        gtkgl/gdkgl-win32.c > ttt &&
      mv ttt gtkgl/gdkgl-win32.c &&
    sed -e "s/^ *gdk_gl_context_unref.*$/if (gl_area->glcontext != NULL) { &; gl_area->glcontext = NULL; }/" \
        gtkgl/gtkglarea.c > ttt &&
      mv ttt gtkgl/gtkglarea.c &&
    for f in examples/gtkglarea_demo.c examples/glpixmap.c; do
      sed -e '/#include <GL\/gl.h>/ {i\
#include <windows.h>
;}' $f > ttt
        mv ttt $f
    done &&
    make &&
    make install &&
    rm -f $tlibdir_quoted/libgtkgl*.la) >&5 2>&1 && end_package
  remove_package "$DOWNLOAD_DIR/gtkglarea-$gtkglarea"
  if failed_package || test ! -f "$tlibdir/gtkgl-2.0.lib"; then
    echo "failed"
    exit -1
  else
    echo "done"
  fi
fi

############
# OctaveDE #
############

if check_package OctaveDE; then
  if test -n "`which mkoctfile.exe`"; then
    (cd "$OCTAVEDE_DIR" || exit -1
      if test -f "ui/octavede.exe"; then
        echo -n "clearing octavede..."
        make clean >&5 2>&1
        echo "done"
      fi
      echo -n "compiling octavede..."
      (W_CPPFLAGS="$W_CPPFLAGS -DHAVE_OCTAVE_300" configure_package --prefix="$octave_prefix" &&
        make &&
        make install) >&5 2>&1 && end_package
      if failed_package || test ! -f "$octave_prefix/bin/octavede.exe"; then
        echo "failed"
        exit -1
      else
        echo "done"
      fi
      )
  else
    echo "octave must be in your PATH in order to compile octavede"
  fi
fi

##########################
# NSI package generation #
##########################

#isolated_packages="fpl msh bim civil-engineering integration mapping nan secs1d secs2d symband triangular tsa pt_br nnet ad"
isolated_packages=
isolated_sizes=

function get_nsi_additional_files()
{
  packname=$1
  packinstdir=$2
  case "$packname" in
    image)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libjpeg-62.dll\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libpng12-0.dll\""
      found=`find "$octave_prefix/libexec/octave/packages/$packinstdir/" -name "__magick_read__.oct" 2> /dev/null`
      if test -n "$found"; then
        echo "  File \"\${VCLIBS_ROOT}\\bin\\libMagick-10.dll\""
        echo "  File \"\${VCLIBS_ROOT}\\bin\\libMagick++-10.dll\""
        echo "  File \"\${VCLIBS_ROOT}\\bin\\libtiff.dll\""
        echo "  File \"\${VCLIBS_ROOT}\\bin\\libjasper-1.dll\""
        echo "  File \"\${VCLIBS_ROOT}\\bin\\libwmflite-0-2-7.dll\""
        echo "  File \"\${VCLIBS_ROOT}\\bin\\libbz2.dll\""
        echo "  File \"\${VCLIBS_ROOT}\\bin\\libxml2-2.dll\""
        echo "  File \"\${VCLIBS_ROOT}\\bin\\libfreetype-6.dll\""
        echo "  File \"\${VCLIBS_ROOT}\\bin\\zlib1.dll\""
        echo "  SetOutPath \"\$INSTDIR\\lib\\ImageMagick-$imagickver\""
        echo "  File /r \"\${VCLIBS_ROOT}\\lib\\ImageMagick-$imagickver\\*.*\""
        echo "  SetOutPath \"\$INSTDIR\\share\\ImageMagick-$imagickver\""
        echo "  File /r \"\${VCLIBS_ROOT}\\share\\ImageMagick-$imagickver\\*.*\""
      fi
      ;;
    octcdf)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libnetcdf-4.dll\""
      echo "  SetOutPath \"\$INSTDIR\\license\""
      echo "  File \"\${VCLIBS_ROOT}\\license\\COPYING.NETCDF\""
      ;;
    gsl)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libgsl-0.dll\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libgslcblas-0.dll\""
      ;;
    arpack)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libarpack.dll\""
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
    ftp)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libftp-3.dll\""
      ;;
    database)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libsqlite3-0.dll\""
      ;;
    video)
      echo "  SetOutPath \"\$INSTDIR\\bin\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libavformat-*.dll\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libavcodec-*.dll\""
      echo "  File \"\${VCLIBS_ROOT}\\bin\\libavutil-*.dll\""
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
          #packver=`grep -e '^Version:' "$found/packinfo/DESCRIPTION" | sed -e 's/^Version *: *//'`
	  packver=`basename "$found" | sed -e "s/$packname-//"`
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
            get_nsi_additional_files $packname $packinstdir
            echo "  SetOutPath \"\$INSTDIR\\share\\octave\\packages\\$packinstdir\""
            echo "  File /r \"\${OCTAVE_ROOT}\\share\\octave\\packages\\$packinstdir\\*\""
            if test -d "$octave_prefix/libexec/octave/packages/$packinstdir"; then
              echo "  SetOutPath \"\$INSTDIR\\libexec\\octave\\packages\\$packinstdir\""
              echo "  File /r \"\${OCTAVE_ROOT}\\libexec\\octave\\packages\\$packinstdir\\*\""
            fi
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
    #packver=`grep -e '^Version:' "$found/packinfo/DESCRIPTION" | sed -e 's/^Version *: *//'`
    packver=`basename "$found" | sed -e "s/$packname-//"`
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
    have_arch_files="#"
    if test -d "$octave_prefix/libexec/octave/packages/$packinstdir"; then
      have_arch_files=
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
        -e "s/@HAVE_ARCH_FILES@/$have_arch_files/" \
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
    if test ! -f "README.txt"; then
      echo -n "creating README.txt... "
      sed -e "s/@OCTAVE_VERSION@/$octave_version/" \
          -e "s/@MSVC_VER@/$msvcver/" \
          README.txt.in > README.txt
      sed -e '$d' "$INSTALL_DIR/local/octave-$octave_version/doc/NEWS" >> README.txt
      unix2dos README.txt
      echo "done"
    fi
    if test ! -f "octave_main.nsi"; then
      octplot_prefix="#"
      gui_prefix="#"
      playrec_prefix="#"
      if $do_octplot; then
        octplot_prefix=
      fi
      if $do_gui; then
        gui_prefix=
      fi
      if test -f "`octave-config -p OCTFILEDIR | sed -e 's,\\\\,/,g'`/playrec.mex"; then
        playrec_prefix=
      fi
      echo -n "creating octave_main.nsi... "
      sed -e "s/@OCTAVE_VERSION@/$octave_version/" -e "s/@VCLIBS_ROOT@/$tdir_w32/" \
        -e "s/@MSYS_ROOT@/$msys_root/" -e "s/@JHANDLES_VERSION@/$jhandles_version/" \
        -e "s/@SOFTWARE_ROOT@/$software_root/" -e "s/@HAVE_OCTPLOT@/$octplot_prefix/" \
        -e "s/@HAVE_GUI@/$gui_prefix/" -e "s/@HAVE_PLAYREC@/$playrec_prefix/" \
        -e "s/@MSVC_CRT@/$crtver/" \
        octave.nsi.in > octave_main.nsi
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
    if test ! -f "check_cpu_flag.exe"; then
      echo -n "creating CPU feature helper program... "
      cc-msvc -O2 -MT check_cpu_flag.c -luser32 -lshell32
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
      rm -f octave_main.nsi octave_forge*.nsi README.txt check_cpu_flag.exe check_cpu_flag.obj
    fi
  fi
fi
