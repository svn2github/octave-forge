#!/usr/bin/sh

source gcc42_common.sh
source gcc42_pkg_version.sh

# INSTALL built deps into package root

install_bin() {
 ( mkdir -p ${PACKAGE_ROOT}/${BINARY_DIR}
   cp -vR ${BINARY_PATH} ${PACKAGE_ROOT};
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/*.dll
 )
}

install_lib() {
 ( mkdir -p ${PACKAGE_ROOT}/${LIBRARY_DIR}
   cp -vR ${LIBRARY_PATH} ${PACKAGE_ROOT} 
 )
}

install_sharedlib() {
 ( mkdir -p ${PACKAGE_ROOT}/${SHAREDLIB_DIR}
   cp -vR ${SHAREDLIB_PATH} ${PACKAGE_ROOT} 
 )
}

install_staticlib() {
 ( mkdir -p ${PACKAGE_ROOT}/${STATICLIB_DIR}
   cp -vR ${STATICLIBRARY_PATH} ${PACKAGE_ROOT} 
 )
}

install_include() {
 ( mkdir -p ${PACKAGE_ROOT}/${INCLUDE_DIR}
   cp -vR ${INCLUDE_PATH} ${PACKAGE_ROOT}
 )
}

install_bin;
install_lib;
install_sharedlib;
install_staticlib;
install_include;
