#!/usr/bin/sh

source common.sh
source pkg_version.sh

# INSTALL built deps into package root

install_bin() {
 ( cp -vR ${INSTALL_BIN} ${PACKAGE_ROOT};
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/*.dll )
}

install_lib() {
 ( cp -vR ${INSTALL_LIB} ${PACKAGE_ROOT} )
}

install_include() {
 ( cp -vR ${INSTALL_INCLUDE} ${PACKAGE_ROOT} )
}

install_bin;
install_lib;
install_include;
