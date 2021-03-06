#!/usr/bin/sh

source gcc44_common.sh
source gcc44_pkg_version.sh

# INSTALL built deps into package root

install_bin() {
 ( mkdir -p ${PACKAGE_ROOT}/${BINARY_DIR}
   echo cp -pR ${BINARY_PATH} ${PACKAGE_ROOT};
   cp -pR ${BINARY_PATH} ${PACKAGE_ROOT};
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/${BINARY_DIR}/*.exe
 )
}

install_lib() {
 ( mkdir -p ${PACKAGE_ROOT}/${LIBRARY_DIR}
   echo cp -pR ${LIBRARY_PATH} ${PACKAGE_ROOT} 
   cp -pR ${LIBRARY_PATH} ${PACKAGE_ROOT} 
 )
}

install_sharedlib() {
 ( mkdir -p ${PACKAGE_ROOT}/${SHAREDLIB_DIR}
   echo cp -pR ${SHAREDLIB_PATH} ${PACKAGE_ROOT} 
   cp -pR ${SHAREDLIB_PATH} ${PACKAGE_ROOT} 
   find ${PACKAGE_ROOT}/${SHAREDLIB_DIR} \
   -iname '*.dll' -a -not -iname 'jogl*.dll' -a -not -iname 'gluegen-rt.dll' \
   -exec strip ${STRIP_FLAGS} '{}' \;
 )
}

install_staticlib() {
 ( mkdir -p ${PACKAGE_ROOT}/${STATICLIB_DIR}
   echo cp -pR ${STATICLIB_PATH} ${PACKAGE_ROOT} 
   cp -pR ${STATICLIB_PATH} ${PACKAGE_ROOT} 
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/${STATICLIB_DIR}/*.a
 )
}

install_include() {
 ( mkdir -p ${PACKAGE_ROOT}/${INCLUDE_DIR}
   echo cp -pR ${INCLUDE_PATH} ${PACKAGE_ROOT}
   cp -pR ${INCLUDE_PATH} ${PACKAGE_ROOT}
 )
}

install_license() {
  ( mkdir -p ${PACKAGE_ROOT}/${LICENSE_DIR}
    echo cp -pR ${LICENSE_PATH} ${PACKAGE_ROOT}
    cp -pR ${LICENSE_PATH} ${PACKAGE_ROOT}
  )
}

install_share() {
  ( mkdir -p ${PACKAGE_ROOT}/${SHARE_DIR}
    echo cp -pR ${SHARE_PATH} ${PACKAGE_ROOT}
    cp -pR ${SHARE_PATH} ${PACKAGE_ROOT}
  )
}

install_doc() {
  ( mkdir -p ${PACKAGE_ROOT}/${DOC_DIR}
    echo cp -pR ${DOC_PATH} ${PACKAGE_ROOT}
    cp -pR ${DOC_PATH} ${PACKAGE_ROOT}
  )
}

install_etc() {
  ( mkdir -p ${PACKAGE_ROOT}/${ETC_DIR}
    echo cp -pR ${ETC_PATH} ${PACKAGE_ROOT}
    cp -pR ${ETC_PATH} ${PACKAGE_ROOT}
  )
}

install_bin;
install_lib;
install_sharedlib;
install_staticlib;
install_include;
install_license;
install_share;
install_doc;
install_etc;
