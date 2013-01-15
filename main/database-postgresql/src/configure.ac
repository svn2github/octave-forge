#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.67])
AC_INIT([postgresql], [0.1.0], [i7tiol@t-online.de])
AC_CONFIG_SRCDIR([__pq_connect__.cc])

# Checks for programs.
AC_PROG_CXX
AC_CHECK_PROG(OCTAVE, octave, octave)
AC_CHECK_PROG(MKOCTFILE, mkoctfile, mkoctfile)

# Checks for libraries.
AC_CHECK_LIB([pq], [PQconnectdb])

# Checks for header files.
AC_CHECK_HEADER([postgresql/libpq-fe.h], ,[exit 1])
AC_CHECK_HEADER([postgresql/pg_config_manual.h], ,[exit 1])
AC_CHECK_HEADER([postgresql/libpq/libpq-fs.h], ,[exit 1])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_FUNC_ERROR_AT_LINE

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
