# Common functions & settings for building with gcc-4.4.x

# Executables used
TAR=tar
TAR_FLAGS=

STRIP=strip
STRIP_FLAGS=--strip-unneeded

CP=${TOPDIR}/../copy-if-changed.sh
CP_FLAGS=-vp

WGET=wget
WGET_FLAGS=-N

RM=rm
RM_FLAGS=-v

MV=mv
MV_FLAGS=-v

AR=ar
RANLIB=ranlib

RC=windres

LD=ld

SED=sed

MAKE=make

# Path to utilities required during the build process
# Leave these empty to search for them on default PATH
# If not empty, path to utilities will be added to PATH
# where necessry

# Microsoft Help Workshop (gnuplot)
PATH_HCW=
# MiKTeX (gnuplot, octave)
PATH_MIKTEX=
# Ghostscript (octave)
PATH_GHOSTSCRIPT=


# GCC configuration used
BUILD_TARGET=mingw32

GCC_VER=4.4.0
GCC_SYS=dw2
GCC_HOST=$BUILD_TARGET

if [ -z "$GCC_VER" ]; then
   GCC_VERSION=
else
   GCC_VERSION=-${GCC_VER}
fi

if [ -z "$GCC_SYS" ]; then
   GCC_SYSTEM=
else
   GCC_SYSTEM=-${GCC_SYS}
fi

if [ -z "$GCC_HOST" ]; then
   GCC_TARGET=
else
   GCC_TARGET=${GCC_HOST}-
fi

# Prefix for building dependency libraries
PREFIX=/usr/local/octmgw32_gcc${GCC_VERSION}${GCC_SYSTEM}
# Prefix for building octave
PREFIX_OCTAVE=${PREFIX}/octave

# Base paths for include files, import libraries, binaries&dlls, static 
# libraries, license files and shared files
INCLUDE_BASE=${PREFIX}
LIBRARY_BASE=${PREFIX}
SHAREDLIB_BASE=${PREFIX}
BINARY_BASE=${PREFIX}
STATICLIB_BASE=${PREFIX}
LICENSE_BASE=${PREFIX}
SHARE_BASE=${PREFIX}
DOC_BASE=${PREFIX}

# default subdirectories
INCLUDE_DEFAULT=include
BINARY_DEFAULT=bin
SHAREDLIB_DEFAULT=bin
LIBRARY_DEFAULT=lib
STATICLIB_DEFAULT=staticlib
LICENSE_DEFAULT=license
SHARE_DEFAULT=share
DOC_DEFAULT=doc

# subdirs for above components, can be overridden locally
# (e.g. for GSL: ${INCLUDE} = include/gsl )
if [ -z ${INCLUDE_DIR} ]; then INCLUDE_DIR=${INCLUDE_DEFAULT}; fi
if [ -z ${BINARY_DIR} ]; then BINARY_DIR=${BINARY_DEFAULT}; fi
if [ -z ${SHAREDLIB_DIR} ]; then SHAREDLIB_DIR=${SHAREDLIB_DEFAULT}; fi
if [ -z ${LIBRARY_DIR} ]; then LIBRARY_DIR=${LIBRARY_DEFAULT}; fi
if [ -z ${STATICLIB_DIR} ]; then STATICLIB_DIR=${STATICLIB_DEFAULT}; fi
if [ -z ${LICENSE_DIR} ]; then LICENSE_DIR=${LICENSE_DEFAULT}; fi
if [ -z ${SHARE_DIR} ]; then SHARE_DIR=${SHARE_DEFAULT}; fi
if [ -z ${DOC_DIR} ]; then DOC_DIR=${DOC_DEFAULT}; fi

# create full paths for component directories
BINARY_PATH=${BINARY_BASE}/${BINARY_DIR}
INCLUDE_PATH=${INCLUDE_BASE}/${INCLUDE_DIR}
SHAREDLIB_PATH=${SHAREDLIB_BASE}/${SHAREDLIB_DIR}
LIBRARY_PATH=${LIBRARY_BASE}/${LIBRARY_DIR}
STATICLIB_PATH=${STATICLIB_BASE}/${STATICLIB_DIR}
LICENSE_PATH=${LICENSE_BASE}/${LICENSE_DIR}
SHARE_PATH=${SHARE_BASE}/${SHARE_DIR}
DOC_PATH=${DOC_BASE}/${DOC_DIR}

# Path to pkg-config .pc files
PKGCONFIGDATA_PATH=${LIBRARY_PATH}/pkgconfig

# Set environment variables for GCC
LIBRARY_PATH=${LIBRARY_PATH}
CPATH=${INCLUDE_BASE}/${INCLUDE_DEFAULT}

export LIBRARY_PATH CPATH

PATH=${PATH}:${BINARY_PATH}

# GCC compilers used
CC=${GCC_TARGET}gcc${GCC_VERSION}${GCC_SYSTEM}
CXX=${GCC_TARGET}g++${GCC_VERSION}${GCC_SYSTEM}
F77=${GCC_TARGET}gfortran${GCC_VERSION}${GCC_SYSTEM}
CPP=${GCC_TARGET}cpp${GCC_VERSION}${GCC_SYSTEM}

# == GCC flags ==

# Building with shared libgcc and shared libsdtc++ support
#
# According to mingw32, the way to do is:
#  LDFLAGS="-shared-libgcc" CXXFLAGS="-D_DLL" 
# and add "-lstdc++_s" at linking stage
#
#   http://garr.dl.sourceforge.net/sourceforge/mingw/gcc-4.2.1-dw2-2-release_notes.txt
#   http://sourceforge.net/project/shownotes.php?release_id=596917
#
# Unfortunately, libtool does (yet?) not honour LDFLAGS, and here in our case
# especially -shared-libgcc.
#
#   http://lists.gnu.org/archive/html/libtool/2006-02/msg00058.html
#   http://lists.gnu.org/archive/html/bug-libtool/2005-10/msg00002.html
#
# The suggested workaround is to specify the -shared-libgcc flag as part
# of the compiled name, e.g.
#   CC="mingw32-gcc-4.3.0-dw2.exe -shared-libgcc"
#
# This works, so I'll use this for building the dependency libs, which use
# libtool, and the former method for those without libtool
#
# Since LDFLAGS might containg additional flags, here I define a separate
# variable LIBGCCLDFLAGS, which can be inserted into LDFLAGS and/or
# CC, CXX and F77 as necessary at configure&build stage.
#
# MIND that you should NOT add -shared-libgcc to CPP's name, since cpp does
# not understand this flag (why sould it, anyway)
#
# ADDENDUM:
# ========
#  For GCC-4.4.0 the flag for shared libstdc++ was changed to _GLIBCXX_DLL
#  thus CXXFLAGS="-D_GLIBCXX_DLL"
#

# Optimization flag
GCC_OPT_FLAGS="-O3"
# Archtecture & tuning flags
GCC_ARCH_FLAGS="-march=i686 -mtune=generic"
# shared libgcc link flag
LIBGCCLDFLAGS="-shared-libgcc"
# Linker flags
LDFLAGS="$LIBGCCLDFLAGS"
# Linker flas for Fortran
FLDFLAGS=$LDFLAGS
# C++ libraries
CXXLIBS="-lstdc++_s"
# C++ Compiler Flags
CXXFLAGS="-D_GLIBCXX_DLL"


# _WIN32_WINNT=0x0500 required for
#    fontconfig-2.7.1

# == Make flags ==

# parallel execution
MAKE_PARALLEL=
# compilers used
MAKE_GCC="CC=$CC CXX=$CXX F77=$F77 CPP=$CPP AR=$AR RC=$RC RANLIB=$RANLIB"
# makefile to use
# MAKEFILE=
# extra flags to pass to make
# MAKE_XTRA=

# == common subfunctions ==
#
#  Every function foo() has corresponding foo_pre() and foo_post()

# == download ==
download_core() {
  ( for a in $1; do ${WGET} ${WGET_FLAGS} "$a"; done )
}
download() {
  ( download_core "${URL}" )
}

# == create patch file ==
mkpatch_pre() { echo ; }
mkpatch()
{
   mkpatch_pre
   if [ ! -d ${SRCDIR_ORIG} ]; then
      echo Orig source directory ${SRCDIR_ORIG} does not exist. Call unpack_orig.
   else
      ( cd ${TOPDIR} && diff -urN -x '*.exe' -x '*.dll' -x '*.o' -x '*.a' -x '*.bak' -x '~' -x '.hg' -x '*.orig' ${DIFF_FLAGS} `basename ${SRCDIR_ORIG}` `basename ${SRCDIR}` > ${PATCHFILE} )
   fi
   mkpatch_post
}
mkpatch_post() { echo ; }

# == apply patch file to source code ==
applypatch_pre() { echo ; }
applypatch() {
  applypatch_pre
  if [ ! -e ${PATCHFILE} ]; then
     echo "== No patchfile available =="
  else
     ( cd ${SRCDIR} && patch -p 1 -u -i ../${PATCHFILE} )
  fi
  applypatch_post
}
applypatch_post() { echo ; }


# == make ==
#  Assume we already chdir'd to the build directory
make_common()
{
   # specific makefile specified?
   if [ ! -z "${MAKEFILE}" ]; then
      MAKE_FILE="-f $MAKEFILE";
   else
      MAKE_FILE=""
   fi
   
   # call make
   if [ -e have_configure ]; then
      # we had a configure script setup all variable accordingly
      echo $MAKE $MAKE_FILE $MAKE_PARALLEL $MAKE_XTRA $*
      $MAKE $MAKE_FILE $MAKE_PARALLEL $MAKE_XTRA $*
   else
      # No configure script, simple makefile
      echo $MAKE \
      $MAKE_FILE \
      $MAKE_GCC \
      $MAKE_PARALLEL \
      CFLAGS="$CFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CXXFLAGS="$CXXFLAGS" \
      FFLAGS="$FFLAGS" \
      CXXLIBS="$CXXLIBS" \
      LDFLAGS="$LDFLAGS" \
      $MAKE_XTRA $*
      
      $MAKE \
      $MAKE_FILE \
      $MAKE_GCC \
      $MAKE_PARALLEL \
      CFLAGS="$CFLAGS" \
      CPPFLAGS="$CPPFLAGS" \
      CXXFLAGS="$CXXFLAGS" \
      FFLAGS="$FFLAGS" \
      CXXLIBS="$CXXLIBS" \
      LDFLAGS="$LDFLAGS" \
      $MAKE_XTRA $*
   fi
}

# == build ==
build_pre()
{
   if [ ! -e ${BUILDDIR} ]; then 
      echo Build directory $BUILDDIR does not exist! Call mkdirs first.
      exit 1
   fi
}
build()
{
   build_pre
   ( cd ${BUILDDIR} && make_common )
   build_post
}
build_post() { echo ; }

# == install ==
install_pre()
{
  if [ ! -e ${BINARY_PATH} ];        then mkdir -vp ${BINARY_PATH}; fi
  if [ ! -e ${LIBRARY_PATH} ];       then mkdir -vp ${LIBRARY_PATH}; fi
  if [ ! -e ${INCLUDE_PATH} ];       then mkdir -vp ${INCLUDE_PATH}; fi
  if [ ! -e ${STATICLIB_PATH} ];     then mkdir -vp ${STATICLIB_PATH}; fi
  if [ ! -e ${LICENSE_PATH} ];       then mkdir -vp ${LICENSE_PATH}; fi
  if [ ! -e ${LICENSE_PATH}/${PKG} ]; then mkdir -vp ${LICENSE_PATH}/${PKG}; fi
  if [ ! -e ${PKGCONFIGDATA_PATH} ]; then mkdir -vp ${PKGCONFIGDATA_PATH}; fi
 }
install()
{
  install_pre
  ( cd ${BUILDDIR} && make_common install );
  install_post
}
install_post() { echo ; }

# == clean ==
clean_pre() { echo ; }
clean()
{
  clean_pre
  ( cd ${BUILDDIR} && make_common clean );
  clean_post
}
clean_post() { echo ; }

# == uninstall ==
uninstall_pre() { echo ; }
uninstall()
{
  uninstall_pre
  ( cd ${BUILDDIR} && make_common uninstall );
  uninstall_post
}
uninstall_post()
{ 
   # Remove installation directories if empty
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}
   rmdir --ignore-fail-on-non-empty ${BINARY_PATH}
   rmdir --ignore-fail-on-non-empty ${PKGCONFIGDATA_PATH}
   rmdir --ignore-fail-on-non-empty ${LIBRARY_PATH}
   rmdir --ignore-fail-on-non-empty ${SHAREDLIB_PATH}
   rmdir --ignore-fail-on-non-empty ${STATICLIB_PATH}

   # The LICENSE Directory
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}
   
   # The SHARE Directory
   rmdir --ignore-fail-on-non-empty ${SHARE_PATH}/${PKGVER}
   rmdir --ignore-fail-on-non-empty ${SHARE_PATH}
   
}

# == check ==
check_pre() { echo ; }
check()
{
  check_pre
  ( cd ${BUILDDIR} && make_common check );
  check_post
}
check_post() { echo ; }

# == unpack ==
unpack_pre()
{ 
   if [ -d ${TOPDIR}/${SRCDIR} ]; then 
      echo Removing ${TOPDIR}/${SRCDIR} ...
      rm -rf ${TOPDIR}/${SRCDIR}; 
   fi 
}
unpack()
{
  unpack_pre
  unpack_core
  unpack_post
}
unpack_post() { echo ; }

unpack_core()
{
   case ${SRCFILE} in
     *.tar.gz|*.tgz)
       $TAR xzf ${TOPDIR}/${SRCFILE}
     ;;
     *.tar.bz2)
       $TAR xjf ${TOPDIR}/${SRCFILE}
     ;;
     *.tar.lzma)
       $TAR x --lzma -f ${TOPDIR}/${SRCFILE}
     ;;
     *.tar.xz)
       $TAR x --xz -f ${TOPDIR}/${SRCFILE}
     ;;
     *.zip)
       # zip requires bsdtar...
       bsdtar x -f ${TOPDIR}/${SRCFILE}
     ;;
     *)
       echo ERROR: Source file $SRCFILE archive type not handled!
       exit 10
       ;;
   esac
}

unpack_add_ver()
{
   # some packages extract into the subdirectory solely containing
   # the package NAME, not a combination of NAME and VERSION
   #
   # for these, add the version specifically in here
   unpack_pre;
   
   rm -rf tmp
   ( mkdir tmp && cd tmp && unpack_core && mv $PKG ../$SRCDIR  && cd .. && rm -rf tmp )
   
   unpack_post;
}

# == unpack into SRCORIG directory ==
unpack_orig_pre()
{ 
   if [ -d ${TOPDIR}/${SRCDIR_ORIG} ]; then 
      echo Removing ${TOPDIR}/${SRCDIR_ORIG} ...
      rm -rf ${TOPDIR}/${SRCDIR_ORIG}; 
   fi 
}
unpack_orig()
{
  unpack_orig_pre
  ( mkdir -p ${TOPDIR}/tmp && cd ${TOPDIR}/tmp && unpack_core && mv ${SRCDIR} ${TOPDIR}/${SRCDIR_ORIG} && cd ${TOPDIR} && rm -rf tmp)
  unpack_orig_post
}
unpack_orig_post() { echo ; }

unpack_orig_add_ver()
{
   # some packages extract into the subdirectory solely containing
   # the package NAME, not a combination of NAME and VERSION
   #
   # for these, add the version specifically in here
   unpack_orig_pre;
   
   rm -rf tmp
   ( mkdir tmp && cd tmp && unpack_core && mv $PKG ../$SRCDIR_ORIG && cd .. && rm -rf tmp)
   
   rm -rf tmp
   
   unpack_orig_post;
}

# == configure ==
conf_pre() { echo ; }
conf()
{
   echo Not implemented!
}
conf_post() { echo ; }


# == mkdirs ==
mkdirs_pre()
{ 
   if [ -d ${BUILDDIR} ]; then 
      echo removing ${BUILDDIR} ...
      rm -rf ${BUILDDIR}
   fi
}
mkdirs()
{
   mkdirs_pre;
   ( cd ${TOPDIR} && mkdir -vp ${BUILDDIR}; )
   mkdirs_post;
}
mkdirs_post() { echo; }

# == substvars ==
substvars_pre() { echo ; }
substvars()
{
   echo Making $2 from $1 ...
   ${SED} \
	-e "s+@SRCDIR@+${TOPDIR}/${SRCDIR}+" \
	-e "s+@TOPDIR@+${TOPDIR}+" \
	-e "s+@GCC_VER@+${GCC_VER}+" \
	-e "s+@GCC_SYS@+${GCC_SYS}+" \
	-e "s+@REL@+${REL}+" \
   $1 > $2
}
substvars_post() { echo ; }

# == modify libtool ==
modify_libtool_all()
{
   if [ -f $1 ]; then
      _libtool_removelibprefix $1;
      _libtool_removerelease $1;
      _libtool_removeversuffix $1;
   fi
}

modify_libtool_noversuffix()
{
   if [ -f $1 ]; then
      _libtool_removelibprefix $1;
      _libtool_removeversuffix $1;
   fi
}

modify_libtool_norelease()
{
   if [ -f $1 ]; then
      _libtool_removelibprefix $1;
      _libtool_removerelease $1;
   fi
}

modify_libtool_nolibprefix()
{
   if [ -f $1 ]; then
      _libtool_removelibprefix $1;
   fi
}

_libtool_removelibprefix()
{
   # remove the 'LIB' prefix of shared library names
   echo "  Removing 'LIB' prefix of shared library names..."
   sed -e '/^soname_spec/ s+"\\${libname}+"\\\`echo \\\${libname} | \\\$SED -e s/^lib//\\\`+' $1 > $1.mod && ${CP} ${CP_FLAGS} $1.mod $1
}

_libtool_removerelease()
{
   # remove the ${release} from shared library names
   echo "  Removing \${release} from shared library names..."
   sed -e '/^soname_spec/ s+\\`echo \\${release} | \\$SED -e s/\[.\]/-/g\\`++' $1 > $1.mod && ${CP} ${CP_FLAGS} $1.mod $1
}

_libtool_removeversuffix()
{
   # remove the ${versuffix} from shared library names
   echo "  Removing \${versuffix} from shared library names..."
   sed -e '/^soname_spec/ s+\\\${versuffix}++' $1 > $1.mod && ${CP} ${CP_FLAGS} $1.mod $1
}

# == MAIN ==
main() {
(
   echo "$1" "$2" "$3" "$4" "$5"
   
   until [[ $1 == "" ]];
   do
     
     arg=$1;
     
      case $arg in
       download|mkpatch|build|install|clean|uninstall|check|unpack|unpack_orig|conf|mkdirs|all|applypatch|install_pkg)
         $arg
         export STATUS=$?
       ;;
     
       *)
         echo "Error: bad arguments"
         exit 1
       ;;
      esac
     
     shift
   done
)
}

# possibly override something in here by a user
# or machine-dependent local configuration...
if [ -e gcc44_localconf.sh ]; then
   source gcc44_localconf.sh
fi

if [ -e ../gcc44_localconf.sh ]; then
   source ../gcc44_localconf.sh
fi

if [ -e ../../gcc44_localconf.sh ]; then
   source ../../gcc44_localconf.sh
fi
