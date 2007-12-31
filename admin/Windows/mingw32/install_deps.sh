#!/usr/bin/sh

source common.sh
source pkg_version.sh

# INSTALL built deps into package root

install_bin() {
 ( cp -vR ${BINARY_PATH} ${PACKAGE_ROOT};
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/*.dll )
}

install_lib() {
 ( cp -vR ${LIBRARY_PATH} ${PACKAGE_ROOT} )
}

install_sharedlib() {
 ( cp -vR ${SHAREDLIB_PATH} ${PACKAGE_ROOT} )
}

install_staticlib() {
 ( cp -vR ${STATICLIBRARY_PATH} ${PACKAGE_ROOT} )
}

install_include() {
 ( cp -vR ${INCLUDE_PATH} ${PACKAGE_ROOT} )
}

install_bin;
install_lib;
install_sharedlib;
install_staticlib;
install_include;
