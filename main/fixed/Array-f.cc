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

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma implementation
#endif

#include <octave/config.h>
#include "int/fixed.h"
#include "fixedComplex.h"
#include "fixedMatrix.h"
#include "fixedCMatrix.h"

#include <octave/Array.h>
#include <octave/Array.cc>
#include <octave/MArray.h>
#include <octave/MArray.cc>

template class Array<FixedPoint>;
template class MArray<FixedPoint>;
template class Array<FixedPointComplex>;
template class MArray<FixedPointComplex>;

template int assign (Array<FixedPoint>&, const Array<FixedPoint>&);
template int assign (Array<FixedPointComplex>&, const Array<FixedPoint>&);
template int assign (Array<FixedPointComplex>&, 
		const Array<FixedPointComplex>&);

template int assign (Array<FixedPoint>&, const Array<FixedPoint>&, 
		const FixedPoint&);
template int assign (Array<FixedPointComplex>&, const Array<FixedPoint>&,
		const FixedPointComplex&);
template int assign (Array<FixedPointComplex>&, 
		const Array<FixedPointComplex>&, const FixedPointComplex&);

INSTANTIATE_MARRAY_FRIENDS (FixedPoint)
INSTANTIATE_MARRAY_FRIENDS (FixedPointComplex)

#include <octave/Array2.h>
#ifndef HAVE_ND_ARRAYS
#include <octave/Array2.cc>
#endif
#include <octave/MArray2.h>
#include <octave/MArray2.cc>

template class Array2<FixedPoint>;
template class MArray2<FixedPoint>;
template class Array2<FixedPointComplex>;
template class MArray2<FixedPointComplex>;

#ifndef HAVE_ND_ARRAYS
template int assign (Array2<FixedPoint>&, const Array2<FixedPoint>&);
template int assign (Array2<FixedPointComplex>&, const Array2<FixedPoint>&);
template int assign (Array2<FixedPointComplex>&, 
		const Array2<FixedPointComplex>&);

template int assign (Array2<FixedPoint>&, const Array2<FixedPoint>&, 
		const FixedPoint&);
template int assign (Array2<FixedPointComplex>&, const Array2<FixedPoint>&,
		const FixedPointComplex&);
template int assign (Array2<FixedPointComplex>&, 
		const Array2<FixedPointComplex>&, const FixedPointComplex&);
#else
INSTANTIATE_ARRAY_CAT (FixedPoint);
INSTANTIATE_ARRAY_CAT (FixedPointComplex);
#endif

INSTANTIATE_MARRAY2_FRIENDS (FixedPoint)
INSTANTIATE_MARRAY2_FRIENDS (FixedPointComplex)

#ifdef HAVE_ND_ARRAYS
#include <octave/ArrayN.h>
#include <octave/ArrayN.cc>
#include <octave/MArrayN.h>
#include <octave/MArrayN.cc>

template class ArrayN<FixedPoint>;
template class MArrayN<FixedPoint>;
template class ArrayN<FixedPointComplex>;
template class MArrayN<FixedPointComplex>;

INSTANTIATE_MARRAYN_FRIENDS (FixedPoint)
INSTANTIATE_MARRAYN_FRIENDS (FixedPointComplex)
#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
