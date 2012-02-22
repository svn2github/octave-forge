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
along with this program; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#include <octave/config.h>
#include "int/fixed.h"
#include "fixedComplex.h"
//#include "fixedMatrix.h"
//#include "fixedCMatrix.h"

inline FixedPoint
xmin (const FixedPoint& x, const FixedPoint& y)
{
  return x <= y ? x : y;
}

inline FixedPoint
xmax (const FixedPoint& x, const FixedPoint& y)
{
  return x >= y ? x : y;
}

inline FixedPointComplex
xmin (const FixedPointComplex& x, const FixedPointComplex& y)
{
  return x <= y ? x : y;
}

inline FixedPointComplex
xmax (const FixedPointComplex& x, const FixedPointComplex& y)
{
  return x >= y ? x : y;
}

#include <octave/Array.h>
#include <octave/Array.cc>
#include <octave/MArray.h>
#include <octave/MArray.cc>

#include <octave/oct-sort.cc>

static bool
operator < (const FixedPointComplex& a, const FixedPointComplex& b)
{
  return ((abs (a) < abs (b)) || ((abs (a) == abs (b)) && 
				    (arg (a) < arg (b))));
}

static bool
operator > (const FixedPointComplex& a, const FixedPointComplex& b)
{
  return ((abs (a) > abs (b)) || ((abs (a) == abs (b)) && 
				    (arg (a) > arg (b))));
}

INSTANTIATE_ARRAY (FixedPoint, );
template class MArray<FixedPoint>;
INSTANTIATE_MARRAY_FRIENDS (FixedPoint, )

INSTANTIATE_ARRAY (FixedPointComplex, );
template class MArray<FixedPointComplex>;
INSTANTIATE_MARRAY_FRIENDS (FixedPointComplex, )

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
