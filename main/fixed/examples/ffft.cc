/*

Copyright (C) 2003 Motorola Inc
Copyright (C) 2003 Laurent Mazet
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

#include <cmath>
#include <octave/config.h>
#include <octave/oct.h>
#include "ffft.h"

/*
 *---------------------------------------------------------------------------*
 | Module: FFT Radix4                                                        |
 |                                                                           |
 | Description: contains five radix4 - butterfly functions, and a function   |
 |              performing the radix4 FFT.                                   |
 |              All the butterflies have the following structure:            |
 |                                                                           |
 |                    u ____          ____ u <-- [(u+y)+(x+z)]W0             |
 |                           \      /                                        |
 |                            \    /                                         |
 |                    x _______\  /_______ x <-- [(u-y)-j(x-z)]Wk            |
 |                              \/                                           |
 |                              /\                                           |
 |                    y ______ /  \ ______ y <-- [(u+y)-(x+z)]W2k            |
 |                            /    \                                         |
 |                           /      \                                        | 
 |                    z ___ /        \ ___ z <-- [(u-y)+j(x-z)]W3k           |
 |                                                                           |
 *---------------------------------------------------------------------------*
 */

template <class S, class C, class CV>
inline void Fft<S,C,CV>::corebutterfly (C &u, C &x, C &y, C &z) {

  apc = reshape(u) + reshape(y);
  amc = reshape(u) - reshape(y);
  bpd = reshape(x) + reshape(z);
  bmd = reshape(x) - reshape(z);
}

template <class S, class C, class CV>
void Fft<S,C,CV>::r4butterfly0 (C &u, C &x, C &y, C &z) {

  // W0, W0, W0, W0

  corebutterfly(u, x, y, z);

  // first branch
  u = reshape(apc) + reshape(bpd);
  // third branch
  y = reshape(apc) - reshape(bpd);
  // second branch
  x = C (reshape(real(amc)) + reshape(imag(bmd)),
		 reshape(imag(amc)) - reshape(real(bmd)));
  // last branch
  z = C (reshape(real(amc)) - reshape(imag(bmd)),
		 reshape(imag(amc)) + reshape(real(bmd)));

}

template <class S, class C, class CV>
void Fft<S,C,CV>::r4butterfly1 (C &u, C &x, C &y, C &z, int n) {

  // W0, W1/16, W1/8, W3/16

  corebutterfly(u, x, y, z);

  // first branch
  u = reshape(apc) + reshape(bpd);
  // third branch
  C t(reshape(apc) - reshape(bpd));
  y = C (real(t)*inv_sqrt_2 + imag(t)*inv_sqrt_2,
		 imag(t)*inv_sqrt_2 - real(t)*inv_sqrt_2); // Respect ASIC
  // second branch
  x = C (reshape(real(amc)) + reshape(imag(bmd)),
		 reshape(imag(amc)) - reshape(real(bmd)))*twiddle(n);
  // last branch
  z = C (reshape(real(amc)) - reshape(imag(bmd)),
		 reshape(imag(amc)) + reshape(real(bmd)))*twiddle(3*n);

}

template <class S, class C, class CV>
void Fft<S,C,CV>::r4butterfly2 (C &u, C &x, C &y, C &z) {

  //* W0, W1/8, W1/4, W3/8

  corebutterfly(u, x, y, z);

  // first branch
  u = reshape(apc) + reshape(bpd);
  // third branch
  y =  C (reshape(imag(apc)) - reshape(imag(bpd)),
		 reshape(real(bpd)) - reshape(real(apc)));
  // second branch
  C t(reshape(real(amc)) + reshape(imag(bmd)),
	       reshape(imag(amc)) - reshape(real(bmd)));
  x = C (real(t)*inv_sqrt_2 + imag(t)*inv_sqrt_2,
		 imag(t)*inv_sqrt_2 - real(t)*inv_sqrt_2); // Respect ASIC
  // last branch
  t = C (reshape(real(amc)) - reshape(imag(bmd)),
		 reshape(imag(amc)) + reshape(real(bmd)));
  z = C (real(t)*(-inv_sqrt_2) - imag(t)*(-inv_sqrt_2),
		 real(t)*(-inv_sqrt_2) + imag(t)*(-inv_sqrt_2)); // Respect ASIC

}

template <class S, class C, class CV>
void Fft<S,C,CV>::r4butterfly3 (C &u, C &x, C &y, C &z, int n) {

  // W0, W3/16, W3/8, W9/16

  corebutterfly(u, x, y, z);

  // first branch
  u = reshape(apc) + reshape(bpd);
  // third branch
  C t(reshape(apc) - reshape(bpd));
  y = C (real(t)*(-inv_sqrt_2) - imag(t)*(-inv_sqrt_2),
	 real(t)*(-inv_sqrt_2) + imag(t)*(-inv_sqrt_2)); // Respect ASIC
  // second branch
  x = C (reshape(real(amc)) + reshape(imag(bmd)),
		 reshape(imag(amc)) - reshape(real(bmd)))*twiddle(3*n);
  // last branch
  z = C (reshape(real(amc)) - reshape(imag(bmd)),
		 reshape(imag(amc)) + reshape(real(bmd)))*twiddle(9*n);

}

template <class S, class C, class CV>
void Fft<S,C,CV>::r4butterfly4 (C &u, C &x, C &y, C &z, int n) {

  // others

  corebutterfly(u, x, y, z);

  // first branch
  u = reshape(apc) + reshape(bpd);
  // third branch
  y = (reshape(apc) - reshape(bpd))*twiddle(2*n);
  // second branch
  x = C (reshape(real(amc)) + reshape(imag(bmd)),
		 reshape(imag(amc)) - reshape(real(bmd)))*twiddle(n);
  // last branch
  z = C (reshape(real(amc)) - reshape(imag(bmd)),
		 reshape(imag(amc)) + reshape(real(bmd)))*twiddle(3*n);

}

/*
 *---------------------------------------------------------------------------*
 | Function: Radix4FFT                                                       |
 |                                                                           |
 | Description: performs a Radix4 FFT for size 256 or 1024                   |
 |                                                                           |
 | Inputs:        fft_public FFT_PARAM_PUBLIC			             |
 | Input/Output:  realpart   CARRIERTYPE*   real part of the input data/FFT  |
 |                imagpart   CARRIERTYPE*   imag part of the input data/FFT  |
 *---------------------------------------------------------------------------*
 */

template <class S, class C, class CV>
void Fft<S,C,CV>::radix4fft (CV &x) {

  // code for radix4FFT function

  int p1, p2, p3, p4, pfirst;

  int size_16 = size/16;

  for (int nb=0, nb_nb = x.length()/size; nb<nb_nb; nb++) {
    for (int n_but=4*size_16, l=4*size_16, n_block=1;n_block<l; n_but>>=2, n_block<<=2)
      for (int block =0; block<n_block; block++) {

	pfirst = p1 = nb*size+block*n_but*4;
	p2 = p1 + n_but;
	p3 = p2 + n_but;
	p4 = p3 + n_but;

	// 1st butterfly : W0, W0, W0, W0
	
	r4butterfly0(x(p1), x(p2), x(p3), x(p4));

	p1++; p2++; p3++; p4++;
	
	// from 1 to N/16
	
	for (int but=n_block, l=size_16; but<l; but+=n_block) {
	  
	  r4butterfly4(x(p1), x(p2), x(p3), x(p4), but);
	  
	  p1++; p2++; p3++; p4++;
	  
	}

	// (N/16+1)th butterfly: W0, W1/16, W1/8, W3/16 */
	
	r4butterfly1(x(p1), x(p2), x(p3), x(p4), size_16);
	
	p1++; p2++; p3++; p4++;
	
	// from N/16 to N/8
	
	for (int but=size_16+n_block, l=2*size_16; but<l; but+=n_block) {
	  
	  r4butterfly4(x(p1), x(p2), x(p3), x(p4), but);
	  
	  p1++; p2++; p3++; p4++;
	  
	}
	
	// (N/8+1)th butterfly : W0, W1/8, W1/4, W3/8
	
	r4butterfly2(x(p1), x(p2), x(p3), x(p4));
	
	p1++; p2++; p3++; p4++;

	// from N/8 to 3N/16
	
	for (int but=2*size_16+n_block, l=3*size_16; but<l; but+=n_block) {
	  
	  r4butterfly4(x(p1), x(p2), x(p3), x(p4), but);
	  
	  p1++; p2++; p3++; p4++;
	  
	}
	
	// (3N/16+1)th butterfly:W0, W3/16, W3/8, W9/16
	
	r4butterfly3(x(p1), x(p2), x(p3), x(p4), size_16);
	
	p1++; p2++; p3++; p4++;
	
	// from 3N/16 to N/4
	
	for (int but=3*size_16+n_block, l=4*size_16; but<l; but+=n_block) {
	  
	  r4butterfly4(x(p1), x(p2), x(p3), x(p4), but);
	  
	  p1++; p2++; p3++; p4++;
	  
	}
	
      }

    // last stage: butterflies (W0,W0,W0,W0) only !
    
    int p=nb*size;
    int i = 0;
    while (i < size) {
      r4butterfly0 (x(p), x(p+1), x(p+2), x(p+3));
      p += 4;
      i += 4;
    }

  }

  normalize (x);

}

/*
 *---------------------------------------------------------------------------*
 | Function: sortingFFT                                                      |
 |                                                                           |
 | Description: this function sorts the FFT outputs using the table          |
 |              contained in the file tables/fft_out_sort		     |
 |                                                                           |
 | Inputs:  param_public SORTINGFFT_PARAM_PUBLIC                             |
 |          pr_in        CARRIERTYPE*  real part of the nonsorted FFT outputs|
 |          pi_in        CARRIERTYPE*  imag part of the nonsorted FFT outputs|
 | Outputs: pr_out       CARRIERTYPE*   real part of the sorted FFT outputs  |
 |          pi_out       CARRIERTYPE*   imag part of the sorted FFT outputs  |
 *---------------------------------------------------------------------------*
 */

template <class S, class C, class CV>
CV Fft<S,C,CV>::sortingfft (CV &x) {

  CV y(x);

  // outputs sorting
  for (int n=0, l=y.length()/size; n<l; n++)
    for (int i=0; i<size; i++)
      y(i+n*size) = x(sort(i)+n*size);

  return y;
}

template <>
void Fft<double,Complex,ComplexRowVector>::generatetwiddle 
	(const unsigned int &is, const unsigned int &ds) {

  const double Pi2 = 2 * 3.14159265358979; // 2*pi

  twiddle.resize (size);
  
  for (int i=0; i<size; i++)
    twiddle(i) = exp (-j_complex*(double)(i)/(double)(size)*Pi2);
}

template <>
void Fft<FixedPoint,FixedPointComplex,FixedComplexRowVector>::generatetwiddle 
	(const unsigned int &is, const unsigned int &ds) {
  const double Pi2 = 2 * 3.14159265358979; // 2*pi

  ComplexRowVector twiddle_double (size);
  
  for (int i=0; i<size; i++)
   twiddle_double(i) = exp (-j_complex*(double)(i)/(double)(size)*Pi2);

  twiddle = FixedComplexRowVector (is, ds, twiddle_double);
  
}

template <class S, class C, class CV>
void Fft<S,C,CV>::generatesort () {

  // Resize and fill sort with zeros..
  sort.resize (0);
#if HAVE_RESIZE_AND_FILL
  sort.resize_and_fill (size, 0);
#else
  sort.resize (size, 0);
#endif

  for (int i=0; i<size; i++)
    for (int j=1, k=size/4; j<size; j<<=2, k>>=2)
      sort(i) += j*((i/k)%4);
}

template<>
inline void Fft<FixedPoint,FixedPointComplex,FixedComplexRowVector>::normalize 
	(FixedComplexRowVector &x) {

  /*
    We reshape data before each butterfly, so we have to multiply 
    by sqrt(size).
  */

  for (int i=0, l=x.length(); i<l; i++)
    x(i) = FixedPointComplex  (real(x(i))<<output_gain_fp,
			      imag(x(i))<<output_gain_fp);
}

template <>
inline void Fft<double,Complex,ComplexRowVector>::normalize 
	(ComplexRowVector &x) {

  for (int i=0, l=x.length(); i<l; i++)
    x(i) = x(i) / output_gain;

}

template <>
inline FixedPoint Fft<FixedPoint,FixedPointComplex,FixedComplexRowVector>::
	reshape (FixedPoint t) {
  return (t>>1);
}

template <>
inline FixedPointComplex 
Fft<FixedPoint,FixedPointComplex,FixedComplexRowVector>::reshape
	 (FixedPointComplex  t) {
  return (FixedPointComplex  (real(t)>>1, imag(t)>>1));
}

template <>
inline Complex Fft<double,Complex,ComplexRowVector>::reshape (Complex t) {

  return (t);
}

template <>
inline double Fft<double,Complex,ComplexRowVector>::reshape (double t) {

  return (t);
}

template <>
void Fft<FixedPoint,FixedPointComplex,FixedComplexRowVector>::
	computetemplatevalues (const unsigned int &FftInputI, 
	const unsigned int &FftInputD) {

  j_complex = Complex(0, 1.);
  output_gain_fp = 0;
  long int i = size;
  while (i >>=1)
    output_gain_fp++;
  output_gain_fp = output_gain_fp / 2;
  inv_sqrt_2 = FixedPoint(FftInputI, FftInputD, 1 / sqrt(2.0));
}

template <>
void Fft<double,Complex,ComplexRowVector>::computetemplatevalues (
	const unsigned int &FftInputI, const unsigned int &FftInputD) {

  j_complex = Complex(0, 1.);
  output_gain = sqrt(double(size));
  inv_sqrt_2 = 1 / sqrt(2.0);
}

template <>
Fft<FixedPoint,FixedPointComplex,FixedComplexRowVector>::Fft 
	(const int &n, const unsigned int &is, const unsigned int &ds) {

  size = n;

  int quot = n / 4;
  int rem = n % 4;
  while ((rem == 0) && (quot != 1)) {
    rem = quot % 4;
    quot = quot / 4;
  }
  if (rem) {
    error("fft: invalid radix 4 fft\n");
    return;
  }

  computetemplatevalues(is, ds);
  generatetwiddle(is, ds);
  generatesort();
}

template <>
Fft<double,Complex,ComplexRowVector>::Fft
	(const int &n, const unsigned int &is, const unsigned int &ds) {

  size = n;

  int quot = n / 4;
  int rem = n % 4;
  while ((rem == 0) && (quot != 1)) {
    rem = quot % 4;
    quot = quot / 4;
  }
  if (rem) {
    error("fft: invalid radix 4 fft\n");
    return;
  }

  computetemplatevalues();
  generatetwiddle();
  generatesort();
}

template <class S, class C, class CV>
CV Fft<S,C,CV>::process (CV &x) {

  CV y(x);

  if (y.length()%size != 0) {
    error("fft: incorrect length of fft\n");
    return y;
  }
  radix4fft(y);

  return (sortingfft(y));
}

template <class S, class C, class CV>
CV Ifft<S,C,CV>::process (CV &x) {

  CV y(x);

  for (int i=0, l=y.length(); i<l; i++)
    y(i) = C (imag(y(i)), real(y(i)));

  y = Fft<S,C,CV>::process (y);

  for (int i=0, l=y.length(); i<l; i++)
    y(i) = C (imag(y(i)), real(y(i)));

  return y;
}

/* class instantiation */

template class Fft<double,Complex,ComplexRowVector>;
template class Fft<FixedPoint,FixedPointComplex,FixedComplexRowVector>;

template class Ifft<double,Complex,ComplexRowVector>;
template class Ifft<FixedPoint,FixedPointComplex,FixedComplexRowVector>;

DEFUN_DLD (ffft, args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =}  ffft (@var{x})\n\
Radix-4 fft in floating and fixed point for vectors of length 4^@var{n},\n\
where @var{n} is an integer. The variable @var{x} can be a either a row of\n\
column vector, in which case a single fft is carried out over the vector\n\
of length 4^@var{n}. If @var{x} is a matrix, the fft is carried on each\n\
column of @var{x} and the matrix must contain 4^@var{n} rows.\n\
\n\
The radix-4 fft is implemented in a manner that attempts to approximate\n\
how it will be implemented in hardware, rather than use a generic butterfly.\n\
The radix-4 algorithm is faster and more precise than the equivalent radix-2\n\
algorithm, and thus is preferred for hardware implementation.\n\
@seealso{fifft}\n\
@end deftypefn")
{
  octave_value retval;

  if (args.length() != 1)
    print_usage("ffft");
  else {

    if ((args(0).type_id () == octave_fixed_matrix::static_type_id ()) ||
	(args(0).type_id () == octave_fixed_complex_matrix::static_type_id ())) {
      FixedComplexMatrix f;
      if (args(0).type_id () == octave_fixed_matrix::static_type_id ())
	f = ((const octave_fixed_matrix&) args(0).get_rep()).
	  fixed_complex_matrix_value();
      else if (args(0).type_id () == 
	       octave_fixed_complex_matrix::static_type_id ())
	f = ((const octave_fixed_complex_matrix&) 
	     args(0).get_rep()).fixed_complex_matrix_value();

      if (!error_state) {
	bool rowvect = false;
	int is = (int)std::max(real(f.getintsize()).row_max().max(),
			       imag(f.getintsize()).row_max().max());
	int ds = (int)std::max(real(f.getdecsize()).row_max().max(),
			       imag(f.getdecsize()).row_max().max());
	
	if (f.rows() == 1) {
	  f = f.transpose();
	  rowvect = true;
	}
	
	Fft<FixedPoint,FixedPointComplex,FixedComplexRowVector> 
	  fft_radix4(f.rows(), is, ds);
	
	if (!error_state) {
	  for (int i=0; i < f.cols(); i++) {
	    FixedComplexRowVector x(f.rows());
	    for (int j=0; j < f.rows(); j++)
	      x(j) = f(j,i); 
	    x = fft_radix4.process(x);
	    for (int j=0; j < f.rows(); j++)
	      f(j,i) = x(j); 
	  }

	  if (rowvect)
	    f = f.transpose();

	  retval = new octave_fixed_complex_matrix (f);
	  retval.maybe_mutate();
	}
      }
    } else {
      ComplexMatrix f;
      if (args(0).is_matrix_type())
	f = args(0).complex_matrix_value();
      else 
	error("ffft: must be called with a floating or fixed point vector\n");

      if (!error_state) {
	bool rowvect = false;

	if (f.rows() == 1) {
	  f = f.transpose();
	  rowvect = true;
	}
	
	Fft<double,Complex,ComplexRowVector> fft_radix4(f.rows());
	
	if (!error_state) {
	  for (int i=0; i < f.cols(); i++) {
	    ComplexRowVector x(f.rows());
	    for (int j=0; j < f.rows(); j++)
	      x(j) = f(j,i); 
	    x = fft_radix4.process(x);
	    for (int j=0; j < f.rows(); j++)
	      f(j,i) = x(j); 
	  }

	  if (rowvect)
	    f = f.transpose();

	  retval = octave_value(f);
	}
      }
    }
  }
  return retval;
}

DEFUN_DLD (fifft, args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =}  fifft (@var{x})\n\
Radix-4 ifft in fixed point for vectors of length 4^@var{n}, where.\n\
@var{n} is an integer. The variable @var{x} can be a either a row of\n\
column vector, in which case a single ifft is carried out over the vector\n\
of length 4^@var{n}. If @var{x} is a matrix, the ifft is carried on each\n\
column of @var{x} and the matrix must contain 4^@var{n} rows.\n\
\n\
The radix-4 ifft is implemented in a manner that attempts to approximate\n\
how it will be implemented in hardware, rather than use a generic butterfly.\n\
The radix-4 algorithm is faster and more precise than the equivalent radix-2\n\
algorithm, and thus is preferred for hardware implementation.\n\
@seealso{ffft}\n\
@end deftypefn")
{
  octave_value retval;

  if (args.length() != 1)
    print_usage("fifft");
  else {

    if ((args(0).type_id () == octave_fixed_matrix::static_type_id ()) ||
	(args(0).type_id () == octave_fixed_complex_matrix::static_type_id ())) {
      FixedComplexMatrix f;
      if (args(0).type_id () == octave_fixed_matrix::static_type_id ())
	f = ((const octave_fixed_matrix&) args(0).get_rep()).
	  fixed_complex_matrix_value();
      else if (args(0).type_id () == 
	       octave_fixed_complex_matrix::static_type_id ())
	f = ((const octave_fixed_complex_matrix&) 
	     args(0).get_rep()).fixed_complex_matrix_value();

      if (!error_state) {
	bool rowvect = false;
	int is = (int)std::max(real(f.getintsize()).row_max().max(),
			       imag(f.getintsize()).row_max().max());
	int ds = (int)std::max(real(f.getdecsize()).row_max().max(),
			       imag(f.getdecsize()).row_max().max());
	
	if (f.rows() == 1) {
	  f = f.transpose();
	  rowvect = true;
	}
	
	Ifft<FixedPoint,FixedPointComplex,FixedComplexRowVector> 
	  ifft_radix4(f.rows(), is, ds);
	
	if (!error_state) {
	  for (int i=0; i < f.cols(); i++) {
	    FixedComplexRowVector x(f.rows());
	    for (int j=0; j < f.rows(); j++)
	      x(j) = f(j,i); 
	    x = ifft_radix4.process(x);
	    for (int j=0; j < f.rows(); j++)
	      f(j,i) = x(j); 
	  }

	  if (rowvect)
	    f = f.transpose();

	  retval = new octave_fixed_complex_matrix (f);
	  retval.maybe_mutate();
	}
      }
    } else {
      ComplexMatrix f;
      if (args(0).is_matrix_type())
	f = args(0).complex_matrix_value();
      else 
	error("fifft: must be called with a floating or fixed point vector\n");

      if (!error_state) {
	bool rowvect = false;

	if (f.rows() == 1) {
	  f = f.transpose();
	  rowvect = true;
	}
	
	Ifft<double,Complex,ComplexRowVector> ifft_radix4(f.rows());
	
	if (!error_state) {
	  for (int i=0; i < f.cols(); i++) {
	    ComplexRowVector x(f.rows());
	    for (int j=0; j < f.rows(); j++)
	      x(j) = f(j,i); 
	    x = ifft_radix4.process(x);
	    for (int j=0; j < f.rows(); j++)
	      f(j,i) = x(j); 
	  }

	  if (rowvect)
	    f = f.transpose();

	  retval = octave_value(f);
	}
      }
    }
  }
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
