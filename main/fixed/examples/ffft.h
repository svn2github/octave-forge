/*

Copyright (C) 2001-2003 Motorola Inc
Copyright (C) 2001-2003 Laurent Mazet 
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
Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (ffft_h)
#define ffft_h 1

#include "fixed.h"

template <class S, class C, class CV>
class Fft 
{
private :
  int size;

  S output_gain;
  int output_gain_fp;
  S inv_sqrt_2;
  Complex j_complex;

  Array<int> sort;
  CV twiddle;

  C apc, amc, bpd, bmd;

  void computetemplatevalues (const unsigned int &is = 0, 
			      const unsigned int &ds = 0);

  void generatetwiddle (const unsigned int &is = 0, 
			const unsigned int &ds = 0);

  S reshape (S t);
  C reshape (C t);
  void normalize (CV &x);
  void generatesort ();

  void corebutterfly (C &u, C &x, C &y, C &z);

  void r4butterfly0 (C &u, C &x, C &y, C &z);
  void r4butterfly1 (C &u, C &x, C &y, C &z, int n);
  void r4butterfly2 (C &u, C &x, C &y, C &z);
  void r4butterfly3 (C &u, C &x, C &y, C &z, int n);
  void r4butterfly4 (C &u, C &x, C &y, C &z, int n);

  void radix4fft (CV &x);

  CV sortingfft (CV &x);

public :
  Fft (const int &n = 64, const unsigned int &is = 0, 
       const unsigned int &ds = 0);

  CV process (CV &x);
};

template <class S, class C, class CV>
class Ifft : Fft<S,C,CV> {

public :
  Ifft (const int &n = 64, const unsigned int &is = 0, 
	const unsigned int &ds = 0) : Fft<S, C, CV> (n, is, ds) {};
  CV process (CV &x);
};
#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
