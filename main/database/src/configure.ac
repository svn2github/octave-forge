#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.67])
AC_INIT([database], [2.2.0], [i7tiol@t-online.de])
AC_CONFIG_SRCDIR([__pq_connect__.cc])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CXX
if test "$GXX" != yes; then
AC_MSG_ERROR([This package needs the GNU C++ compiler, which wasn't found.], 1);
fi
  
AC_CHECK_PROG(OCTAVE, octave, octave)
AC_CHECK_PROG(MKOCTFILE, mkoctfile, mkoctfile)
AC_CHECK_PROG(OCTAVE_CONFIG, octave-config, octave-config)
AC_CHECK_PROG(PG_CONFIG, pg_config, pg_config)
if test -z "$PG_CONFIG"; then
AC_MSG_ERROR([pg_config not found], 1);
fi

# Checks for libraries.
AC_CHECK_LIB([pq], [PQconnectdb])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_FUNC_ERROR_AT_LINE

# Check for PostgreSQL version. (Octave is 'abused' here for string
# and version handling, only because I'm more familiar with it than
# with other tools. Should not interfer with cross-compiling as long
# as you have any Octave installed locally.)
AC_MSG_CHECKING([whether PostgreSQL version is >= 8.3])
if $OCTAVE -q --eval ["[~, vs] = system ('$PG_CONFIG --version'); if (compare_versions (regexp (vs, '(\\d+\\.\\d+\\.\\d+)', 'tokens'){1}{:}, '8.3', '>=')) exit (1); else exit (0); endif"]; then
   AC_MSG_RESULT(no)
  AC_MSG_ERROR([package \"database\" does not work with PostgreSQL version < 8.3], 1);
else
   AC_MSG_RESULT(yes)
fi

# Start of checks for Octave features, preparations for checks.
OCTLIBDIR=${OCTLIBDIR:-`$OCTAVE_CONFIG -p OCTLIBDIR`}
OCTINCLUDEDIR=${OCTINCLUDEDIR:-`$OCTAVE_CONFIG -p OCTINCLUDEDIR`}
AC_LANG_PUSH([C++])
TCXXFLAGS=$CXXFLAGS
TLDFLAGS=$LDFLAGS
TLIBS=$LIBS
LDFLAGS="-L$OCTLIBDIR $LDFLAGS"
LIBS="-loctinterp $LIBS"
CXXFLAGS="-I$OCTINCLUDEDIR $CXXFLAGS"

## Presence of 'error_state' -- does _not_ indicate no exceptions are
## used.
AC_LINK_IFELSE(
  [AC_LANG_PROGRAM([[#include <oct.h>]
                    [#include <stdio.h>]],
                   [[printf ("%i", error_state);]])],
  [AC_DEFINE([HAVE_OCTAVE_ERROR_STATE], 1)])

## Presence of 'verror (octave_execution_exception&, const char *,
## va_list)'
AC_LINK_IFELSE(
  [AC_LANG_PROGRAM([[#include <oct.h>]],
                   [[octave_execution_exception e;]
                    [va_list args;]
                    [verror (e, "test", args);]])],
  [AC_DEFINE([HAVE_OCTAVE_VERROR_ARG_EXC], 1)])

LIBS=$TLIBS
LDFLAGS=$TLDFLAGS
CXXFLAGS=$TCXXFLAGS
AC_LANG_POP([C++])
# End of checks for Octave features.

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
