dnl acinclude.m4 for Octave-GPC
dnl
dnl Copyright (C) 2001, 2004  Rafael Laboissiere
dnl
dnl This script is part of Octave-GPC
dnl
dnl Octave-gpc is free software; you can redistribute it and/or modify it
dnl under the terms of the GNU General Public License as published by
dnl the Free Software Foundation; either version 2, or (at your option)
dnl any later version.
dnl
dnl Octave-gpc is distributed in the hope that it will be useful, but
dnl WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with Octave; see the file COPYING.  If not, write to the Free
dnl Software Foundation, 59 Temple Place - Suite 330, Boston, MA
dnl 02110-1301, USA.
dnl
dnl
dnl -------------------------------------------------------------------
dnl OCTAVE_CONFIG_INFO (VARIABLE, CONFIG_INFO)
dnl
dnl If VARIABLE is not yet set, run Octave to extract the CONFIG_INFO of
dnl octave_config_info().  Put the result in VARIABLE, replacing
dnl eventually the prefix at the beginning by '${prefix}'.
dnl --------------------------------------------------------------------
AC_DEFUN([OCTAVE_CONFIG_INFO], [
  if test -z "$[]$1" ; then
    octave_config_info_out=`$OCTAVE -q -f 2>&1 <<EOF
                              printf(octave_config_info("$2"));
EOF`
    $1=`echo $octave_config_info_out | sed "s:^${prefix}:\\\${prefix}:"`
  fi
])
dnl
dnl -------------------------------------------------------------------
dnl CHECK_PROG (VARIABLE, PROGRAM)
dnl
dnl Check if PROGRAM is available in the PATH.  If not, issue an error
dnl message.
dnl -------------------------------------------------------------------
AC_DEFUN([CHECK_PROG], [
  if test -z "$[]$1" ; then
    AC_PATH_PROG($1, $2, [not found])
  fi
  if test "$[]$1" = "not found" ; then
    AC_MSG_ERROR([$2 program not found.  Giving up.])
  fi
])
