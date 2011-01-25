#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.62)
AC_INIT(parallel, 2.0.5, olaf.till@uni-jena.de)
AC_CONFIG_SRCDIR([__internal_exit__.cc])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CXX
AC_PROG_CC
AC_CHECK_PROG(MKOCTFILE, mkoctfile, mkoctfile)
AC_CHECK_PROG(OCTAVE, octave, octave)

# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([arpa/inet.h fcntl.h netdb.h netinet/in.h sys/socket.h sys/time.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_TYPE_PID_T
AC_TYPE_SIZE_T
AC_TYPE_SSIZE_T

# Checks for library functions.
AC_FUNC_ERROR_AT_LINE
AC_FUNC_FORK
AC_FUNC_MALLOC
AC_TYPE_SIGNAL
AC_CHECK_FUNCS([getcwd gethostbyaddr gethostbyname gethostname modf select socket strchr])

# Checks for Octave features.
AC_MSG_CHECKING([whether Octave version is <= 3.2.4])
if $OCTAVE -q --eval "if (compare_versions (version (), \"3.2.4\", \"<=\")) exit (1); endif"; then
   AC_MSG_RESULT(no)
else
   AC_MSG_RESULT(yes)
   AC_DEFINE(OCTAVE_LE_3_2_4, 1, [Define to Octave version <= 3.2.4.])
fi

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
