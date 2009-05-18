/*

Copyright (C) 2009 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (octave_fixed_inlines_h)
#define octave_fixed_inlines_h 1

#include <cstddef>
#include <cmath>

#include <octave/quit.h>

#include <octave/oct-cmplx.h>
#include <octave/oct-locbuf.h>
#include <octave/oct-inttypes.h>

#include <octave/mx-inlines.cc>

inline bool xis_true (FixedPoint x) {return x != FixedPoint(); }
inline bool xis_false (FixedPoint x) {return x == FixedPoint(); }

inline bool xis_true (FixedPointComplex x) 
   {return x.real() != FixedPoint() || x.imag() != FixedPoint (); }
inline bool xis_false (FixedPointComplex x) 
   {return x.real() == FixedPoint() && x.imag() == FixedPoint (); }

#endif
