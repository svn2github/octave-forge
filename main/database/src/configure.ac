#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.67])
AC_INIT([database], [2.1.1], [i7tiol@t-online.de])
AC_CONFIG_SRCDIR([__pq_connect__.cc])

# Checks for programs.
AC_PROG_CXX
AC_CHECK_PROG(OCTAVE, octave, octave)
AC_CHECK_PROG(MKOCTFILE, mkoctfile, mkoctfile)
AC_CHECK_PROG(PG_CONFIG, pg_config, pg_config)
if test -z "$PG_CONFIG"; then exit 1; fi

# Checks for libraries.
AC_CHECK_LIB([pq], [PQconnectdb])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_FUNC_ERROR_AT_LINE

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
