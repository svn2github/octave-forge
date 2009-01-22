# Common Functions for build process

export TOPDIR SRCDIR

# TOOLS USED
TAR=tar
TAR_FLAGS=xf
TARTYPE=

STRIP=strip
STRIP_FLAGS="--strip-unneeded"

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
GCC_VER=-4.3.0
GCC_SYS=-dw2
GCC_PREFIX=mingw32-

# Prefix for our build
#PREFIX=`echo ${TOPDIR} | sed -e 's+\(.*\)/[^/]*$+\1+'`/usr/local
PREFIX=/usr/local/octave-mingw32_gcc${GCC_VER}${GCC_SYS}
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

PKGCONFIGDATA_PATH=${LIBRARY_PATH}/pkgconfig

DEVBIN_PATH=${PREFIX}/dev/bin

PATH=${PATH}:${BINARY_PATH}:${DEVBIN_PATH}

export BINARY_PATH INCLUDE_PATH LIBRARY_PATH SHAREDLIB_PATH STATICLIBRARY_PATH DEVBIN_PATH

# Set environment variables for GCC
LIBRARY_PATH=${LIBRARY_PATH}
CPATH=${INCLUDE_BASE}/${INCLUDE_DEFAULT}

export LIBRARY_PATH CPATH


CC=${GCC_PREFIX}gcc${GCC_VER}${GCC_SYS}
CXX=${GCC_PREFIX}g++${GCC_VER}${GCC_SYS}
F77=${GCC_PREFIX}gfortran${GCC_VER}${GCC_SYS}
CPP=${GCC_PREFIX}cpp${GCC_VER}${GCC_SYS}

export CC CXX F77 CPP

# Common GCC FLAGS

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

case $GCC_VER in
   -4.3.0)
# shared libgcc link flag
LIBGCCLDFLAGS="-shared-libgcc"
# Architecture flags
GCC_ARCH_FLAGS="-march=i686 -mtune=generic"
# Optimization flags
GCC_OPT_FLAGS="-O2"
# Linker flags
LDFLAGS="$LIBGCCLDFLAGS"
# Linker flas for Fortran
FLDFLAGS=$LDFLAGS
# C++ libraries
CXXLIBS="-lstdc++_s"
# C++ Compiler Flags
CXXFLAGS="-D_DLL"
;;

   -4.3.1)
# Architecture flags
GCC_ARCH_FLAGS="-march=i686 -mtune=i686"
# Optimization flags
GCC_OPT_FLAGS="-O2"
# Linker flags
LDFLAGS=""
FLDFLAGS=$LDFLAGS
CXXLIBS=""
CXXFLAGS=""
;;

esac 

export GCC_ARCH_FLAGS GCC_OPT_FLAGS LDFLAGS FLDFLAGS CXXLIBS CXXFLAGS

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
   if [ ! -z ${MAKEFILE} ]; then MAKE_FLAGS="${MAKE_FLAGS} -f ${MAKEFILE}"; fi
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
  if [ ! -e ${PKGCONFIGDATA_PATH} ];        then mkdir -vp ${PKGCONFIGDATA_PATH}; fi
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
uninstall_post()
{ 
   # Remove installation directories if empty
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}
   rmdir --ignore-fail-on-non-empty ${BINARY_PATH}
   rmdir --ignore-fail-on-non-empty ${LIBRARY_PATH}
   rmdir --ignore-fail-on-non-empty ${SHAREDLIB_PATH}
   rmdir --ignore-fail-on-non-empty ${STATICLIBRARY_PATH}

   # The LICENSE Directory
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}
   
}

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
   ${SED} \
	-e "s+@SRCDIR@+${TOPDIR}/${SRCDIR}+" \
	-e "s+@TOPDIR@+${TOPDIR}+" \
	-e "s+@GCC_VER@+${GCC_VER}+" \
	-e "s+@GCC_SYS@+${GCC_SYS}+" \
	-e "s+@REL@+${REL}+" \
   $1 > $2
}
substvars_post() { echo ; }

srcpkg()
{
   "${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/${FULLPKG}-src.7z ${SRCFILE} ${PATCHFILE} build-${VER}-${REL}.sh
}

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

modify_libtool_add_compilerflag()
{
   if [ -f $1 ]; then
      libtool_version=`sed -ne 's@^VERSION=\(.*\)\$@\1@p' $1`
      case $libtool_version in
         2.2.6)
            _libtool_add_compilerflag $1;
         ;;
         *)
            echo "Libtool version is too old (${libtool_version}) - ignored!"
         ;;
      esac
   fi
}

_libtool_removelibprefix()
{
   # remove the 'LIB' prefix of shared library names
   echo "  Removing 'LIB' prefix of shared library names..."
   sed -e '/^soname_spec/ s+"\\${libname}+"\\\`echo \\\${libname} | \\\$SED -e s/^lib//\\\`+' $1 > $1.mod && mv $1.mod $1
}

_libtool_removerelease()
{
   # remove the ${release} from shared library names
   echo "  Removing \${release} from shared library names..."
   sed -e '/^soname_spec/ s+\\`echo \\${release} | \\$SED -e s/\[.\]/-/g\\`++' $1 > $1.mod && mv $1.mod $1
}

_libtool_removeversuffix()
{
   # remove the ${versuffix} from shared library names
   echo "  Removing \${versuffix} from shared library names..."
   sed -e '/^soname_spec/ s+\\\${versuffix}++' $1 > $1.mod && mv $1.mod $1
}

_libtool_add_compilerflag()
{
   # modify libtool to recognize the -shared-libgcc option 
   # alseo when linking a shared library
   echo "  Adding \"	compiler_flags=\"\$compiler_flags \$arg\" to libtool..."
cat >_libtool.awk << EOF
BEGIN {
   in_func_mode_link = 0;
   in_case_arg = 0;
   in_case = 0;
   found_it = 0;
}

/^[ \t]*func_mode_link[ \t]*\(\)/ {
   in_func_mode_link = 1;
}

/[ \t]*case \\\$arg in/ {
   if( in_func_mode_link )
      in_case_arg = 1;
}

/[ \t]*\-\*[ ]+\|[ ]+\+\*\)/ {
   if( in_case_arg )
      in_case = 1;
}

/arg=\"\\\$func_quote_for_eval_result\"/ {
   if( in_case ) {
      found_it = 1
   }
}

/[ \t]*;;/ {
   if( in_case )
      in_case = 0
}

{
   print \$0
   if( found_it ) {
      print "	compiler_flags=\"\$compiler_flags \$arg\""
      found_it = 0;
   }
}
EOF

   gawk -f _libtool.awk $1 > $1.mod && mv $1.mod $1
}

clone()
{
   # new release
   NREL=$((${REL}+1))
   
   sed -e "s|REL=${REL}|REL=${NREL}|" < build-${VER}-${REL}.sh > build-${VER}-${NREL}.sh
}
   
main() {
(
   echo "$1" "$2" "$3" "$4" "$5"
   
   until [[ $1 == "" ]];
   do
     
     arg=$1;
     
      case $arg in
       download|mkpatch|build|install|clean|uninstall|check|unpack|unpack_orig|conf|mkdirs|all|applypatch|install_pkg|srcpkg|clone)
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
if [ -e gcc43_localconf.sh ]; then
   source gcc43_localconf.sh
fi

if [ -e ../gcc43_localconf.sh ]; then
   source ../gcc43_localconf.sh
fi
