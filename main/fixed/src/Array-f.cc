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

#include <octave/Array.h>
#include <octave/Array.cc>
#include <octave/MArray.h>
#include <octave/MArray.cc>

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

template class OCTAVE_FIXED_API Array<FixedPoint>;
template class MArray<FixedPoint>;
template class OCTAVE_FIXED_API Array<FixedPointComplex>;
template class MArray<FixedPointComplex>;

INSTANTIATE_MARRAY_FRIENDS (FixedPoint, )
INSTANTIATE_MARRAY_FRIENDS (FixedPointComplex, )

#include <octave/Array2.h>
#include <octave/MArray2.h>
#include <octave/MArray2.cc>

template class Array2<FixedPoint>;
template class MArray2<FixedPoint>;
template class Array2<FixedPointComplex>;
template class MArray2<FixedPointComplex>;

INSTANTIATE_MARRAY2_FRIENDS (FixedPoint, OCTAVE_FIXED_API)
INSTANTIATE_MARRAY2_FRIENDS (FixedPointComplex, OCTAVE_FIXED_API)

#include <octave/ArrayN.h>
#include <octave/ArrayN.cc>
#include <octave/MArrayN.h>
#include <octave/MArrayN.cc>

template class ArrayN<FixedPoint>;
template class MArrayN<FixedPoint>;
template class ArrayN<FixedPointComplex>;
template class MArrayN<FixedPointComplex>;

INSTANTIATE_MARRAYN_FRIENDS (FixedPoint, )
INSTANTIATE_MARRAYN_FRIENDS (FixedPointComplex, )

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
