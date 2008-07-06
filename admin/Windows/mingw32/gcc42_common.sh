# Common Functions for build process

export TOPDIR SRCDIR

# TOOLS USED
TAR=tar
TAR_FLAGS=xvf
TARTYPE=

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

SED=sed

SEVENZIP="/c/Program Files/7-Zip/7z.exe"
SEVENZIP_FLAGS="a -t7z -mx7 -m0=BCJ2 -m1=LZMA:d24 -m2=LZMA:d19 -m3=LZMA:d19 -mb0:1 -mb0s1:2 -mb0s2:3"

MAKENSIS="/c/Programs/NSIS/makensis.exe"

export STRIP STRIP_FLAGS

# GCC compilers used
GCC_VER=-4.2.1
GCC_SYS=-sjlj
GCC_PREFIX=mingw32-

# Prefix for our build
#PREFIX=`echo ${TOPDIR} | sed -e 's+\(.*\)/[^/]*$+\1+'`/usr/local
PREFIX=/usr/local/octm32gcc${GCC_VER}${GCC_SYS}
PREFIX_OCT=${PREFIX}/octave

# Base paths for include files, import libraries, binaries&dlls, static libraries
INCLUDE_BASE=${PREFIX}
LIBRARY_BASE=${PREFIX}
SHAREDLIB_BASE=${PREFIX}
BINARY_BASE=${PREFIX}
STATICLIBRARY_BASE=${PREFIX}
LICENSE_BASE=${PREFIX}

# default subdirectories
INCLUDE_DEFAULT=include
BINARY_DEFAULT=bin
SHAREDLIB_DEFAULT=bin
LIBRARY_DEFAULT=lib
STATICLIBRARY_DEFAULT=staticlib
LICENSE_DEFAULT=license

# subdirs for above components, can be overridden locally
# (e.g. for GSL: ${INCLUDE} = include/gsl )
if [ -z ${INCLUDE_DIR} ]; then INCLUDE_DIR=${INCLUDE_DEFAULT}; fi
if [ -z ${BINARY_DIR} ]; then BINARY_DIR=${BINARY_DEFAULT}; fi
if [ -z ${SHAREDLIB_DIR} ]; then SHAREDLIB_DIR=${SHAREDLIB_DEFAULT}; fi
if [ -z ${LIBRARY_DIR} ]; then LIBRARY_DIR=${LIBRARY_DEFAULT}; fi
if [ -z ${STATICLIBRARY_DIR} ]; then STATICLIBRARY_DIR=${STATICLIBRARY_DEFAULT}; fi
if [ -z ${LICENSE_DIR} ]; then LICENSE_DIR=${LICENSE_DEFAULT}; fi

# create full paths for component directories
BINARY_PATH=${BINARY_BASE}/${BINARY_DIR}
INCLUDE_PATH=${INCLUDE_BASE}/${INCLUDE_DIR}
SHAREDLIB_PATH=${SHAREDLIB_BASE}/${SHAREDLIB_DIR}
LIBRARY_PATH=${LIBRARY_BASE}/${LIBRARY_DIR}
STATICLIBRARY_PATH=${STATICLIBRARY_BASE}/${STATICLIBRARY_DIR}
LICENSE_PATH=${LICENSE_BASE}/${LICENSE_DIR}

PATH=${PATH}:${BINARY_PATH}

export BINARY_PATH INCLUDE_PATH LIBRARY_PATH SHAREDLIB_PATH STATICLIBRARY_PATH

# Set environment variables for GCC
LIBRARY_PATH=${LIBRARY_PATH}
CPATH=${INCLUDE_BASE}/${INCLUDE_DEFAULT}

export LIBRARY_PATH CPATH


CC=${GCC_PREFIX}gcc${GCC_VER}${GCC_SYS}
CXX=${GCC_PREFIX}g++${GCC_VER}${GCC_SYS}
F77=${GCC_PREFIX}gfortran${GCC_VER}${GCC_SYS}

export CC CXX F77

# Common GCC FLAGS

# Architecture flags
GCC_ARCH_FLAGS="-march=i686 -mtune=i686"
# Optimization flags
GCC_OPT_FLAGS="-O2"
# Linker flags
LDFLAGS="-shared-libgcc -Wl,-Bdynamic -Wl,-s"

export GCC_ARCH_FLAGS GCC_OPT_FLAGS LDFLAGS

# Common Functions

# download
download_core() {
  ( for a in $1; do ${WGET} ${WGET_FLAGS} "$a"; done )
}

download() {
  ( download_core ${URL} )
}

mkpatch_pre() { echo ; }
mkpatch()
{
   mkpatch_pre
   ( cd ${TOPDIR} && diff -urN -x '*.exe' -x '*.dll' -x '*.o' -x '*.a' -x '*.bak' ${DIFF_FLAGS} `basename ${SRCDIR_ORIG}` `basename ${SRCDIR}` > ${PATCHFILE} )
   mkpatch_post
}
mkpatch_post() { echo ; }

# apply source code patch file to source code
applypatch_pre() { echo ; }
applypatch() {
  applypatch_pre
  ( cd ${SRCDIR} && patch -p 1 -u -i ../${PATCHFILE} )
  applypatch_post
}
applypatch_post() { echo ; }

make_common_pre() 
{
   if [ ! -z ${MAKEFILE} ]; then MAKE_FLAGS="-f ${MAKEFILE}"; fi
}
make_common()
{
  make_common_pre
  echo make ${MAKE_FLAGS} $1 
  make ${MAKE_FLAGS} $1 
}

build_pre() { echo ; }
build()
{
   build_pre
   ( cd ${BUILDDIR} && make_common )
   build_post
}
build_post() { echo ; }

install_pre()
{
  if [ ! -e ${BINARY_PATH} ]; then mkdir -vp ${BINARY_PATH}; fi
  if [ ! -e ${LIBRARY_PATH} ]; then mkdir -vp ${LIBRARY_PATH}; fi
  if [ ! -e ${INCLUDE_PATH} ]; then mkdir -vp ${INCLUDE_PATH}; fi
  if [ ! -e ${STATICLIBRARY_PATH} ]; then mkdir -vp ${STATICLIBRARY_PATH}; fi
  if [ ! -e ${LICENSE_PATH} ];        then mkdir -vp ${LICENSE_PATH}; fi
 }
install()
{
  install_pre
  ( cd ${BUILDDIR} && make_common install );
  install_post
}
install_post() { echo ; }

clean_pre() { echo ; }
clean()
{
  clean_pre
  ( cd ${BUILDDIR} && make_common clean );
  clean_post
}
clean_post() { echo ; }

uninstall_pre() { echo ; }
uninstall()
{
  uninstall_pre
  ( cd ${BUILDDIR} && make_common uninstall );
  uninstall_post
}
uninstall_post() { echo ; }

check_pre() { echo ; }
check()
{
  check_pre
  ( cd ${BUILDDIR} && make_common check );
  check_post
}
check_post() { echo ; }

unpack_pre() { echo ; }
unpack()
{
(
  unpack_pre
  ${TAR} -${TAR_TYPE} -${TAR_FLAGS} ${TOPDIR}/${SRCFILE}
  unpack_post
)
}
unpack_post() { echo ; }

unpack_orig_pre() { echo ; }
unpack_orig()
{
(
  unpack_orig_pre
  ( mkdir -p ${TOPDIR}/tmp && cd ${TOPDIR}/tmp && unpack && mv `basename ${SRCDIR}` ${TOPDIR}/${SRCDIR_ORIG} && cd ${TOPDIR} && rm -rf tmp)
  unpack_orig_post
)
}
unpack_orig_post() { echo ; }

conf_pre() { echo ; }
conf()
{
   echo Not implemented!
}
conf_post() { echo ; }

mkdirs_pre() { echo ; }
mkdirs()
{
   mkdirs_pre;
   ( cd ${TOPDIR} && mkdir -vp ${BUILDDIR}; )
   mkdirs_post;
}
mkdirs_post() { echo; }

substvars_pre() { echo ; }
substvars()
{
   echo Making $2 from $1 ...
   ${SED} -e "s+@SRCDIR@+${TOPDIR}/${SRCDIR}+" \
   $1 > $2
}
substvars_post() { echo ; }

srcpkg()
{
   "${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/${FULLPKG}-src.7z ${SRCFILE} ${PATCHFILE} build-${VER}-${REL}.sh
}

main() {
(
   echo "$1" "$2" "$3" "$4" "$5"
   
   until [[ $1 == "" ]];
   do
     
     arg=$1;
     
      case $arg in
       mkpatch|build|install|clean|uninstall|check|unpack|unpack_orig|conf|mkdirs|all|applypatch|install_pkg|srcpkg)
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
