#! /bin/sh

# directory roots
PREFIX=/usr/local
PREFIX_OCTAVE=${PREFIX}/octave

#  subdirectories of binaries (dlls), include files and import libaries relative to ${PREFIX}
# these can be overridden in the build script if necessary (e.g. putting the includefiles somewhere else)
if [ -z ${INSTALLDIR_BIN} ]; then INSTALLDIR_BIN=bin; fi
if [ -z ${INSTALLDIR_LIB} ]; then INSTALLDIR_LIB=lib; fi
if [ -z ${INSTALLDIR_INCLUDE} ]; then INSTALLDIR_INCLUDE=include; fi

# Directories to install dlls, import libraries and include files
INSTALL_BIN=${PREFIX}/${INSTALLDIR_BIN}
INSTALL_LIB=${PREFIX}/${INSTALLDIR_LIB}
INSTALL_INCLUDE=${PREFIX}/${INSTALLDIR_INCLUDE}

# Make the installed include files/libraries available in GCC'S search path
export CPATH=${INSTALL_INCLUDE}
export LIBRARY_PATH=${INSTALL_LIB}

# programs
WGET=wget
TAR=tar

# common flags
CP_FLAGS=-v
RM_FLAGS=-vf
export STRIP_FLAGS="-p --strip-unneeded"
WGET_FLAGS=-N

# download
download_core() {
( for a in $1; do ${WGET} ${WGET_FLAGS} "$a"; done )
}

download() {
( donwload ${URL} )
}

# unpack source code
unpack() {
(
   tarflag=?
   if [ -e ${TOPDIR}/${SRCPKG}.tar.bz2 ]; then tarflag=j; fi
   if [ -e ${TOPDIR}/${SRCPKG}.tar.gz  ]; then tarflag=z; fi
   if [ -e ${TOPDIR}/${SRCPKG}.tgz     ]; then tarflag=z; fi
   # --- Unpack source file ---
   tar xfv${tarflag} ${TOPDIR}/${SRCFILE}
)
}

# unpack source code to ${PKGNAME}-orig directory for comparing and creating a patch file
unpack_orig() {
(  mkdir -p tmp && cd tmp && unpack && cd .. && mv tmp/${PKGNAME} ${PKGNAME}-orig && rm -rf tmp )
}

# make build directories
mkdirs() {
(
   # --- create build dir ---
   mkdir -p ${BUILDDIR}
)
}

# create the install directories
mkinstalldirs() {
(
  mkdir -p ${INSTALL_BIN}
  mkdir -p ${INSTALL_INCLUDE}
  mkdir -p ${INSTALL_LIB}
)
}

mkpatchpre() {
  echo skip >/dev/null
}

# create source code patch file
mkpatch() {
( 
  mkpatchpre
  diff -urN -x '*.o' -x '*.bak' -x '*.dll' -x '*.a' -x '*.exe' -x '*.def' -x '*.res' ${MKPATCHFLAGS} ${PKGNAME}-orig ${PKGNAME} > ${FULLPKG}.diff
)
}

# apply source code patch file to source code
applypatch() {
( cd ${SRCDIR} && patch -p 1 -u -i ../${PATCHFILE} )
}

# "make"
build() {
(cd ${BUILDDIR} && make )
}

# "make clean"
clean() {
( cd ${BUILDDIR} && make clean; )
}

main() {
(
   #echo "$1" "$2" "$3" "$4" "$5"
   
   until [[ $1 == "" ]];
   do
     
     arg=$1;
     
      case $arg in
       download|unpack|mkdirs|applypatch|build|mkpatch|unpack_orig|clean|install|uninstall|conf|all|install_pkg)
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
