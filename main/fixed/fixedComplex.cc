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

#include <complex>
#include <cmath>
#include "int/fixed.h"
#include "fixedComplex.h"

#if !defined (CXX_ISO_COMPLIANT_LIBRARY)
#error "Need ISO compliant C++ libraries. Try a more recent compiler!!!"
#endif

#define GET_FIXED_PROP(METHOD) \
  Complex \
  FixedPointComplex:: METHOD (void) const \
  { \
    return Complex(real() . METHOD (), imag(). METHOD ()); \
  }

GET_FIXED_PROP(sign);
GET_FIXED_PROP(getdecsize);
GET_FIXED_PROP(getintsize);
GET_FIXED_PROP(getnumber);
GET_FIXED_PROP(fixedpoint);

#undef GET_FIXED_PROP

FixedPointComplex 
FixedPointComplex::chdecsize (const Complex n)
{
  return FixedPointComplex (
	     FixedPoint(real().getintsize(), (int)std::real(n), real()), 
	     FixedPoint(imag().getintsize(), (int)std::imag(n), imag()));
}

FixedPointComplex 
FixedPointComplex::chintsize (const Complex n)
{
  return FixedPointComplex (
	     FixedPoint((int)std::real(n), real().getdecsize(), real()), 
	     FixedPoint((int)std::imag(n), imag().getdecsize(), imag()));
}

FixedPointComplex 
FixedPointComplex::incdecsize (const Complex n) {
  return chdecsize ( getdecsize() + n);
}

FixedPointComplex 
FixedPointComplex::incdecsize () {
  return chdecsize ( getdecsize() + Complex(1,1));
}

FixedPointComplex 
FixedPointComplex::incintsize (const Complex n) {
  return chdecsize ( getintsize() + n);
}
 
FixedPointComplex 
FixedPointComplex::incintsize () {
  return chdecsize ( getintsize() + Complex(1,1));
}

FixedPointComplex operator ! (const FixedPointComplex &x) 
{
  return FixedPointComplex ( ! x.real(), ! x.imag());
}

#define DO_FIXED_CMPLX_FUNC(FUNC, MT) \
  MT FUNC (const FixedPointComplex& x) \
  { \
    return std:: FUNC (x); \
  }

DO_FIXED_CMPLX_FUNC(real, FixedPoint);
DO_FIXED_CMPLX_FUNC(imag, FixedPoint);
DO_FIXED_CMPLX_FUNC(conj, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(norm, FixedPoint);
DO_FIXED_CMPLX_FUNC(arg, FixedPoint);
DO_FIXED_CMPLX_FUNC(cos, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(cosh, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(sin, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(sinh, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(tan, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(tanh, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(sqrt, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(exp, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(log, FixedPointComplex);
DO_FIXED_CMPLX_FUNC(log10, FixedPointComplex);

#define DO_FIXED_CMPLX_FUNC2(FUNC) \
  FixedPointComplex FUNC (const FixedPointComplex& x) \
  {  \
    return FixedPointComplex( FUNC (std::real(x)), FUNC (std::imag(x))); \
  }

DO_FIXED_CMPLX_FUNC2(round);
DO_FIXED_CMPLX_FUNC2(rint);
DO_FIXED_CMPLX_FUNC2(floor);
DO_FIXED_CMPLX_FUNC2(ceil);

FixedPointComplex polar (const FixedPoint &r, const FixedPoint &p)
{
  return std::polar ( r, p);
}

FixedPoint abs(const FixedPointComplex& z) 
{
// SGI MipsPRO 7.3 defines abs(Complex<T>&) as a call to
// the C-lib hypot(double,double), so avoid using std::abs
// and instead inline the function here.
  FixedPoint x = z.real();
  FixedPoint y = z.imag();
  if (abs(x) > abs(y)) {
    y /= x;
    return x * sqrt (1 + y*y);
  } else if (x == 0 && y == 0) {
    return 0;
  } else {
    x /= y;
    return y * sqrt (1 + x*x);
  }
}

FixedPointComplex pow (const FixedPointComplex& a, const int b)
{
// Should be able to do a std::pow(a,b), except for a bug in some cmath.tcc
// files in g++ . The bug is in /usr/include/g++*/bits/cmath.tcc where
// "_Tp = bool ? _Tp : int;" should be "_Tp = bool ? _Tp : _Tp(int);
// Maybe this is fixed on versions later than g++ 3.0.4?
  unsigned int n = std::abs(b);
  FixedPointComplex x(a);
  FixedPointComplex y = n % 2 ? x : FixedPointComplex(1);

  while (n >>= 1)
    {
      x = x * x;
      if (n % 2)
	y = y * x;
    }

  if (b < 0) 
    return (FixedPointComplex(1) / y);
  else
    return y;
}

FixedPointComplex pow  (const FixedPointComplex &a, const FixedPoint &b)
{
  return std::pow(a, b);
}

FixedPointComplex pow  (const FixedPoint &a, const FixedPointComplex &b)
{
  return std::pow(a, b);
}

FixedPointComplex pow  (const FixedPointComplex &a, const FixedPointComplex &b)
{
  return std::pow(a, b);
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

