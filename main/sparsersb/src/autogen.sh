#! /bin/sh

## Generate ./configure
rm -f configure.in
echo "dnl --- DO NOT EDIT --- Automatically generated by autogen.sh" > configure.in
cat configure.base >> configure.in
cat <<EOF >> configure.in
AC_PATH_PROG(LIBRSB_CONFIG,librsb-config)
test -z "\$LIBRSB_CONFIG" && AC_MSG_ERROR('librsb-config not found in the path. Did you install librsb ?')
if test x\$LIBRSB_CONFIG = x ; then LIBRSB_CONFIG=librsb-config ; fi
LIBRSB_CXXFLAGS="\`\$LIBRSB_CONFIG --cflags\`"
LIBRSB_LIBS="\`\$LIBRSB_CONFIG --ldflags | sed s/-static//g\` -lgomp"
AC_OPENMP([])
EOF
cat <<EOF >> configure.in
  AC_OUTPUT(\$CONFIGURE_OUTPUTS)
  dnl XXX FIXME XXX chmod is not in autoconf's list of portable functions

  echo " "
  echo "  \"\\\$prefix\" is \$prefix"
  echo "  \"\\\$exec_prefix\" is \$exec_prefix"
  AC_MSG_RESULT([\$STATUS_MSG

find . -name NOINSTALL -print    # shows which toolboxes won't be installed
])
EOF

autoconf configure.in > configure.tmp
if [ diff configure.tmp configure > /dev/null 2>&1 ]; then
  rm -f configure.tmp;
else
  mv -f configure.tmp configure
  chmod 0755 configure
fi
rm -f configure.in
