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

#if !defined (__fixed_complex_h)
#define __fixed_complex_h 1

#include <complex>
#include <octave/oct-cmplx.h>
#include "int/fixed.h"

class OCTAVE_FIXED_API FixedPointComplex : public std::complex<FixedPoint>
{
public:

  FixedPointComplex (void) :
    std::complex<FixedPoint> (FixedPoint(), FixedPoint()) { }

  FixedPointComplex (const std::complex<FixedPoint> &c) :
    std::complex<FixedPoint> (c) { }

  FixedPointComplex (const FixedPoint& f) :
    std::complex<FixedPoint> (f, FixedPoint(f.getintsize(),f.getdecsize())) { }

  FixedPointComplex (const int x) :
    std::complex<FixedPoint> (FixedPoint (x), FixedPoint ()) { }

  FixedPointComplex (const double x) :
    std::complex<FixedPoint> (FixedPoint (x), FixedPoint ()) { }

  FixedPointComplex (const FixedPoint& r, const FixedPoint& i) :
    std::complex<FixedPoint> (r, i) { }

  FixedPointComplex (const FixedPointComplex &c) :
    std::complex<FixedPoint> (c) { }

  FixedPointComplex (const unsigned int& is, const unsigned int& ds,
		     const FixedPoint& d) :
    std::complex<FixedPoint> (FixedPoint(is,ds,d), FixedPoint(is,ds)) { }

  FixedPointComplex (const unsigned int& is, const unsigned int& ds) :
    std::complex<FixedPoint> (FixedPoint(is,ds), FixedPoint(is,ds)) { }

  FixedPointComplex (const unsigned int& is, const unsigned int& ds,
		     const FixedPoint& r, const FixedPoint& i) :
    std::complex<FixedPoint> (FixedPoint(is,ds,r), FixedPoint(is,ds,i)) { }

  FixedPointComplex (const unsigned int& is, const unsigned int& ds,
		     const FixedPointComplex& c) :
    std::complex<FixedPoint> (FixedPoint(is,ds,c.real()), 
			      FixedPoint(is,ds,c.imag())) { }

  FixedPointComplex (const unsigned int& is, const unsigned int& ds,
		     const double& d) :
    std::complex<FixedPoint> (FixedPoint(is,ds,d), FixedPoint(is,ds)) { }

  FixedPointComplex (const unsigned int& is, const unsigned int& ds,
		     const Complex& c) :
    std::complex<FixedPoint> (FixedPoint(is,ds,c.real()), 
		      FixedPoint(is,ds,c.imag())) { }

  FixedPointComplex (const unsigned int& is, const unsigned int& ds, 
		     const Complex& a, const Complex& b) :
    std::complex<FixedPoint> (FixedPoint(is, ds, (unsigned int)a.real(), 
					 (unsigned int)b.real()), 
			      FixedPoint(is, ds, (unsigned int)a.imag(), 
					 (unsigned int)b.imag())) { }

  FixedPointComplex (const unsigned int& is, const unsigned int& ds,
		     const double& r, const double &i) :
    std::complex<FixedPoint> (FixedPoint(is, ds, r), FixedPoint(is, ds, i)) { }

  FixedPointComplex (const Complex& is, const Complex& ds) :
    std::complex<FixedPoint> (FixedPoint((int)is.real(), (int)ds.real()), 
			      FixedPoint((int)is.imag(), (int)ds.imag())) { }

  FixedPointComplex (const Complex& is, const Complex& ds, const double& d) :
    std::complex<FixedPoint> (FixedPoint((int)is.real(), (int)ds.real(), 
					 d), 
			      FixedPoint((int)is.imag(), (int)ds.imag())) { }

  FixedPointComplex (const Complex& is, const Complex& ds, const Complex& c) :
    std::complex<FixedPoint> (FixedPoint((int)is.real(), (int)ds.real(), 
					 c.real()), 
			      FixedPoint((int)is.imag(), (int)ds.imag(), 
					 c.imag())) { }

  FixedPointComplex (const Complex& is, const Complex& ds, 
		     const FixedPointComplex& c) :
    std::complex<FixedPoint> (FixedPoint((int)is.real(), (int)ds.real(), 
					 c.real()), 
			      FixedPoint((int)is.imag(), (int)ds.imag(), 
					 c.imag())) { }

  FixedPointComplex (const Complex& is, const Complex& ds, 
		     const Complex& a, const Complex& b) :
    std::complex<FixedPoint> (FixedPoint((int)is.real(), (int)ds.real(), 
					 (unsigned int)a.real(), 
					 (unsigned int)b.real()), 
			      FixedPoint((int)is.imag(), (int)ds.imag(), 
					 (unsigned int)a.imag(), 
					 (unsigned int)b.imag())) { }

  Complex sign (void) const;
  Complex getdecsize (void) const;
  Complex getintsize (void) const;
  Complex getnumber (void) const;
  Complex fixedpoint (void) const;
  FixedPointComplex chdecsize (const Complex n);
  FixedPointComplex chintsize (const Complex n);
  FixedPointComplex incdecsize (const Complex n);
  FixedPointComplex incdecsize ();
  FixedPointComplex incintsize (const Complex n);
  FixedPointComplex incintsize ();

  friend Complex fixedpoint (const FixedPointComplex &x); 
  friend Complex sign (const FixedPointComplex &x);
  friend Complex getintsize (const FixedPointComplex &x);
  friend Complex getdecsize (const FixedPointComplex &x);
  friend Complex getnumber (const FixedPointComplex &x);

  // FixedPointComplex operators

  friend OCTAVE_FIXED_API FixedPointComplex operator ! (const FixedPointComplex &x);
  
  // FixedPointComplex mathematic functions

  friend OCTAVE_FIXED_API FixedPoint real  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPoint imag  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex conj  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPoint abs  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPoint norm  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPoint arg  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex polar  (const FixedPoint &r, const FixedPoint &p);
  friend OCTAVE_FIXED_API FixedPointComplex cos  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex cosh  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex sin  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex sinh  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex tan  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex tanh  (const FixedPointComplex &x);

  friend OCTAVE_FIXED_API FixedPointComplex sqrt  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex pow  (const FixedPointComplex &w, const int y);
  friend OCTAVE_FIXED_API FixedPointComplex pow  (const FixedPointComplex &x, 
				 const FixedPoint& y);
  friend OCTAVE_FIXED_API FixedPointComplex pow  (const FixedPoint &x, 
				 const FixedPointComplex& y);
  friend OCTAVE_FIXED_API FixedPointComplex pow  (const FixedPointComplex &x, 
				 const FixedPointComplex &y);
  friend OCTAVE_FIXED_API FixedPointComplex exp  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex log  (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex log10  (const FixedPointComplex &x);

  friend OCTAVE_FIXED_API FixedPointComplex round (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex rint (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex floor (const FixedPointComplex &x);
  friend OCTAVE_FIXED_API FixedPointComplex ceil (const FixedPointComplex &x);
};

inline Complex fixedpoint (const FixedPointComplex &x) { 
  return (x.fixedpoint());
}

inline Complex sign (const FixedPointComplex &x) {
  return (x.sign());
}

inline Complex getintsize (const FixedPointComplex &x) {
  return (x.getintsize());
}

inline Complex getdecsize (const FixedPointComplex &x) {
  return (x.getdecsize());
}

inline Complex getnumber (const FixedPointComplex &x) {
  return (x.getnumber());
}

OCTAVE_FIXED_API FixedPointComplex operator ! (const FixedPointComplex &x);
  
OCTAVE_FIXED_API FixedPoint real  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPoint imag  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex conj  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPoint abs  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPoint norm  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPoint arg  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex polar  (const FixedPoint &r, const FixedPoint &p);
OCTAVE_FIXED_API FixedPointComplex cos  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex cosh  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex sin  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex sinh  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex tan  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex tanh  (const FixedPointComplex &x);

OCTAVE_FIXED_API FixedPointComplex sqrt (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex pow (const FixedPointComplex &w, const int y);
OCTAVE_FIXED_API FixedPointComplex pow (const FixedPointComplex &x, const FixedPoint& y);
OCTAVE_FIXED_API FixedPointComplex pow (const FixedPoint &x, const FixedPointComplex& y);
OCTAVE_FIXED_API FixedPointComplex pow (const FixedPointComplex &x, const FixedPointComplex &y);
OCTAVE_FIXED_API FixedPointComplex exp  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex log  (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex log10  (const FixedPointComplex &x);

OCTAVE_FIXED_API FixedPointComplex round (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex rint (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex floor (const FixedPointComplex &x);
OCTAVE_FIXED_API FixedPointComplex ceil (const FixedPointComplex &x);

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

