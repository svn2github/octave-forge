/*

Copyright (C) 2003 Motorola Inc
Copyright (C) 2003 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (fixed_def_h)
#define fixed_def_h 1

#include "ov-fixed-mat.h"
#include "ov-fixed-cx-mat.h"

#define __FIXED_SIGN_STR "sign"
#define __FIXED_VALUE_STR "x"
#define __FIXED_DECSIZE_STR "dec"
#define __FIXED_INTSIZE_STR "int"

#define FIXED_DEFUNOP_OP(name, t, op) \
  UNOPDECL (name, a) \
  { \
      CAST_UNOP_ARG (const octave_ ## t&); \
      return new octave_ ## t (op v.t ## _value ()); \
  }

#define FIXED_DEFBINOP_OP(name, t1, t2, ret, op) \
  BINOPDECL (name, a1, a2) \
  { \
    CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
    octave_value retval = new octave_ ## ret \
      (v1.t1 ## _value () op v2.t2 ## _value ()); \
    retval.maybe_mutate(); \
    return retval; \
  }

#define FIXED_DEFBINOP_FN(name, t1, t2, ret, f) \
  BINOPDECL (name, a1, a2) \
  { \
    CAST_BINOP_ARGS (const octave_ ## t1&, const octave_ ## t2&); \
    octave_value retval = new octave_ ## ret \
      (f (v1.t1 ## _value (), v2.t2 ## _value ())); \
    retval.maybe_mutate(); \
    return retval; \
  }

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

