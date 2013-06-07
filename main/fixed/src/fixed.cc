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

#include "ov-fixed.h"
#include "ov-fixed-mat.h"
#include "ov-fixed-complex.h"
#include "ov-fixed-cx-mat.h"
#include "fixed-var.h"

#include <octave/variables.h>
#include <octave/utils.h>
#include <octave/pager.h>
#include <octave/defun-dld.h>
#include <octave/gripes.h>

extern void install_fs_fs_ops (void);
extern void install_fs_fm_ops (void);
extern void install_fm_fs_ops (void);
extern void install_fm_fm_ops (void);

extern void install_fs_fcs_ops (void);
extern void install_fs_fcm_ops (void);
extern void install_fm_fcs_ops (void);
extern void install_fm_fcm_ops (void);

extern void install_fcs_fs_ops (void);
extern void install_fcs_fm_ops (void);
extern void install_fcm_fs_ops (void);
extern void install_fcm_fm_ops (void);

extern void install_fcs_fcs_ops (void);
extern void install_fcs_fcm_ops (void);
extern void install_fcm_fcs_ops (void);
extern void install_fcm_fcm_ops (void);

static bool fixed_type_loaded = false;

void load_fixed_type (void)
{
  octave_fixed::register_type ();
  octave_fixed_matrix::register_type ();
  octave_fixed_complex::register_type ();
  octave_fixed_complex_matrix::register_type ();

  install_fs_fs_ops ();
  install_fs_fm_ops ();
  install_fm_fs_ops ();
  install_fm_fm_ops ();

  install_fs_fcs_ops ();
  install_fs_fcm_ops ();
  install_fm_fcs_ops ();
  install_fm_fcm_ops ();

  install_fcs_fs_ops ();
  install_fcs_fm_ops ();
  install_fcm_fs_ops ();
  install_fcm_fm_ops ();

  install_fcs_fcs_ops ();
  install_fcs_fcm_ops ();
  install_fcm_fcs_ops ();
  install_fcm_fcm_ops ();

  fixed_type_loaded = true;

  mlock ();
}

// PKG_ADD: autoload ("display_fixed_operations", "fixed.oct");
DEFUN_DLD (display_fixed_operations, args, ,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} display_fixed_operations ( )\n"
"Displays out a summary of the number of fixed point operations of each\n"
"type that have been used. This can be used to give a estimate of the\n"
"complexity of an algorithm.\n"
"@end deftypefn\n"
"@seealso{fixed_point_count_operations, reset_fixed_operations}") 
{
  octave_value retval;
  if ((args.length() != 0) || !fixed_type_loaded)
    print_usage ();
  else if (Fixed::FP_CountOperations)
    octave_stdout << Fixed::FP_Operations;
  else
    error("display_fixed_operations: variable fixed_point_count_operations is zero");

  return retval;
}

// PKG_ADD: autoload ("reset_fixed_operations", "fixed.oct");
DEFUN_DLD (reset_fixed_operations, args, ,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} reset_fixed_operations ( )\n"
"Reset the count of fixed point operations to zero.\n"
"@end deftypefn\n"
"@seealso{fixed_point_count_operations, display_fixed_operations}") 
{
  octave_value retval;
  if ((args.length() != 0) || !fixed_type_loaded)
    print_usage ();
  else
    Fixed::FP_Operations.reset();
    
  return retval;
}

// PKG_ADD: autoload ("isfixed", "fixed.oct");
DEFUN_DLD (isfixed, args, ,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} isfixed (@var{expr})\n"
"Return 1 if the value of the expression @var{expr} is a fixed point value.\n"
"@end deftypefn") 
{
   if (args.length() != 1) 
     print_usage ();
   else if (!fixed_type_loaded)
     // Can't be of fixed type if the type isn't load :-/
     return octave_value(false);
   else 
     return (octave_value((args(0).type_id () ==
			   octave_fixed::static_type_id ()) ||
			  (args(0).type_id () ==
			   octave_fixed_matrix::static_type_id ()) ||
			  (args(0).type_id () ==
			   octave_fixed_complex::static_type_id ()) ||
			  (args(0).type_id () ==
			   octave_fixed_complex_matrix::static_type_id ())));
   return octave_value();
}

DEFUN_DLD (fixed, args, nargout,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {@var{y} =} fixed (@var{f})\n"
"@deftypefnx {Loadable Function} {@var{y} =} fixed (@var{is},@var{ds})\n"
"@deftypefnx {Loadable Function} {@var{y} =} fixed (@var{is},@var{ds},@var{f})\n"
"Used the create a fixed point variable. Called with a single argument, if\n"
"@var{f} is itself a fixed point value, then @dfn{fixed} is equivalent to\n"
"@code{@var{y} = @var{f}}. Otherwise the integer part of @var{f} is used\n"
"to create a fixed point variable with the minimum number of bits needed\n"
"to represent it. @var{f} can be either real of complex.\n"
"\n"
"Called with two or more arguments @var{is} represents the number of bits\n"
"used to represent the integer part of the fixed point numbers, and @var{ds}\n"
"the number used to represent the decimal part. These variables must be\n"
"either positive integer scalars or matrices. If they are matrices they\n"
"must be of the same dimension, and each fixed point number in the created\n"
"matrix will have the representation given by the corresponding values of\n"
"@var{is} and @var{ds}.\n"
"\n"
"When creating complex fixed point values, the fixed point representation\n"
"can be different for the real and imaginary parts. In this case @var{is}\n"
"and @var{ds} are complex integers."
"\n"
"Additionally the maximum value of the sum of @var{is} and @var{ds} is\n"
"limited by the representation of long integers to either 30 or 62.\n"
"\n"
"Called with only two arguments, the fixed point variable that is created\n"
"will contain only zeros. A third argument can be used to give the values\n"
"of the fixed variables elements. This third argument @var{f} can be either\n"
"a fixed point variable itself, which results in a new fixed point variable\n"
"being created with a different representation, or a real or complex matrix.\n"
"@end deftypefn\n")
{
  int nargin = args.length();
  octave_value retval;

  if ( nargin == 0 ) {
    print_usage ();
  } else if (nargin == 1 ) {
    if (fixed_type_loaded &&
	(args(0).type_id () == octave_fixed_matrix::static_type_id ())) {
      FixedMatrix f = ((const octave_fixed_matrix&) args(0).get_rep()).
	fixed_matrix_value();
      retval = new octave_fixed_matrix (f);
    } else if (fixed_type_loaded &&
	       (args(0).type_id () == octave_fixed::static_type_id ())) {
      FixedPoint f = ((const octave_fixed&) args(0).get_rep()).fixed_value();
      retval = new octave_fixed (f);
    } else if (fixed_type_loaded &&
           (args(0).type_id () == octave_fixed_complex::static_type_id ())) {
      FixedPointComplex f = ((const octave_fixed_complex&) 
		      args(0).get_rep()).fixed_complex_value();
      retval = new octave_fixed_complex (f);
    } else if (fixed_type_loaded &&
	       (args(0).type_id () == 
		octave_fixed_complex_matrix::static_type_id ())) {
      FixedComplexMatrix f = ((const octave_fixed_complex_matrix&) 
		      args(0).get_rep()).fixed_complex_matrix_value();
      retval = new octave_fixed_complex_matrix (f);
    } else {
      if (args(0).is_complex_type()) {
	ComplexMatrix a = args(0).complex_matrix_value();
	MArray<int> b(dim_vector (a.rows(),a.cols()));
	for (int j = 0; j < a.cols(); j++)
	  for (int i = 0; i < a.rows(); i++)
	    b(i,j) = (int)real(a(i,j));
	FixedMatrix fr(b);
	for (int j = 0; j < a.cols(); j++)
	  for (int i = 0; i < a.rows(); i++)
	    b(i,j) = (int)imag(a(i,j));
	FixedMatrix fi(b);
	retval = new octave_fixed_complex_matrix (fr, fi);
      } else {
	Matrix a = args(0).matrix_value();
	MArray<int> b(dim_vector (a.rows(),a.cols()));
	for (int j = 0; j < a.cols(); j++)
	  for (int i = 0; i < a.rows(); i++)
	    b(i,j) = (int)a(i,j);
	FixedMatrix f(b);
	retval = new octave_fixed_matrix (f);
      }
    }
  } else if ((nargin ==2) || (nargin == 3)) {
    if (args(0).is_complex_type() || args(1).is_complex_type() || 
	((nargin > 2) && args(2).is_complex_type())) {

      MArray<int> mir, mii, mdr, mdi;
      ComplexMatrix a, b;
      if (args(0).is_complex_type())
	a = args(0).complex_matrix_value();
      else {
	a = ComplexMatrix(args(0).matrix_value());
	a = a + Complex(0.,1.)*a;
      }
      if (args(1).is_complex_type())
	b = args(1).complex_matrix_value();
      else {
	b = ComplexMatrix(args(1).matrix_value());
	b = b + Complex(0.,1.)*b;
      }

      mir.resize(dim_vector (a.rows(),a.cols()));
      mii.resize(dim_vector (a.rows(),a.cols()));
      for (int j = 0; j < a.cols(); j++)
	for (int i = 0; i < a.rows(); i++) {
	  mir(i,j) = (int) real(a(i,j));
	  mii(i,j) = (int) imag(a(i,j));
	  if ((std::abs(real(a(i,j))-(double)mir(i,j)) != 0.) || 
	      (std::abs(imag(a(i,j))-(double)mii(i,j)) != 0.) || 
	      (mir(i,j) < 0) || (mii(i,j) < 0)) {
	    error("fixed: invalid fixed point representation");
	    return retval;
	  }
	}

      mdr.resize(dim_vector (b.rows(),b.cols()));
      mdi.resize(dim_vector (b.rows(),b.cols()));
      for (int j = 0; j < b.cols(); j++)
	for (int i = 0; i < b.rows(); i++) {
	  mdr(i,j) = (int) real(b(i,j));
	  mdi(i,j) = (int) imag(b(i,j));
	  if ((std::abs(real(b(i,j))-(double)mdr(i,j)) != 0.) || 
	      (std::abs(imag(b(i,j))-(double)mdi(i,j)) != 0.) || 
	      (mir(i,j) < 0) || (mdi(i,j) < 0)) {
	    error("fixed: invalid fixed point representation");
	    return retval;
	  }
	}

      if ((mir.rows() == 1) && (mir.cols() == 1)) {
	mir.resize(dim_vector (mdr.rows(),mdr.cols()), mir(0,0));
	mii.resize(dim_vector (mdr.rows(),mdr.cols()), mii(0,0));
      }
      if ((mdr.rows() == 1) && (mdr.cols() == 1)) {
	mdr.resize(dim_vector (mir.rows(),mir.cols()), mdr(0,0));
	mdi.resize(dim_vector (mir.rows(),mir.cols()), mdi(0,0));
      }

      if ((mir.rows() != mdr.rows()) || (mir.cols() != mdr.cols())) {
	error("fixed: dimension mismatch in args");
	return retval;
      }
    
      if (nargin == 2 ) {
	if (!fixed_type_loaded) load_fixed_type();
	if ((mir.rows() == 1) && (mir.cols() == 1)) {
	  FixedPointComplex f( FixedPoint((int)mir(0,0), (int)mdr(0,0)),
			       FixedPoint((int)mii(0,0), (int)mdi(0,0)));
	  retval = new octave_fixed_complex (f);
	} else {
	  FixedComplexMatrix f (FixedMatrix (mir, mdr), 
				FixedMatrix (mii, mdi));
	  retval = new octave_fixed_complex_matrix (f);
	}
      } else if (nargin == 3) {
	ComplexMatrix c = args(2).complex_matrix_value();
	if ((mir.rows() == 1) && (mir.cols() == 1)) {
	  if (!fixed_type_loaded) load_fixed_type ();
	  FixedComplexMatrix f(FixedMatrix((int)mir(0,0), (int)mdr(0,0), 
					   real(c)),
			       FixedMatrix((int)mii(0,0), (int)mdi(0,0),
					   imag(c)));
	  retval = new octave_fixed_complex_matrix (f);
	} else {
	  if ((mir.rows() != c.rows()) || (mir.cols() != c.cols()))
	    error("fixed: dimension mismatch in args");
	  else {
	    if (!fixed_type_loaded) load_fixed_type ();
	    FixedComplexMatrix f(FixedMatrix(mir, mdr, real(c)),
				 FixedMatrix(mii, mdi, imag(c)));
	    retval = new octave_fixed_complex_matrix (f);
	  }
	}
      }
    } else {
      MArray<int> mis, mds;
      Matrix a = args(0).matrix_value();
      Matrix b = args(1).matrix_value();

      mis.resize(dim_vector (a.rows(),a.cols()));
      for (int j = 0; j < a.cols(); j++)
	for (int i = 0; i < a.rows(); i++) {
	  mis(i,j) = (int)a(i,j);
	  if ((std::abs(a(i,j)-(double)mis(i,j)) != 0.) || (mis(i,j) < 0)) {
	    error("fixed: invalid fixed point representation");
	    return retval;
	  }
	}
      mds.resize(dim_vector (b.rows(),b.cols()));
      for (int j=0; j < b.cols(); j++)
	for (int i=0; i < b.rows(); i++) {
	  mds(i,j) = (int)b(i,j);
	  if ((std::abs(b(i,j)-(double)mds(i,j)) != 0.) || (mds(i,j) < 0)) {
	    error("fixed: invalid fixed point representation");
	    return retval;
	  }
	}

      if ((mis.rows() == 1) && (mis.cols() == 1))
	mis.resize(dim_vector (mds.rows(),mds.cols()),mis(0,0));
      if ((mds.rows() == 1) && (mds.cols() == 1))
	mds.resize(dim_vector (mis.rows(),mis.cols()),mds(0,0));
    
      if ((mis.rows() != mds.rows()) || (mis.cols() != mds.cols())) {
	error("fixed: dimension mismatch in args");
	return retval;
      }
    
      if (nargin == 2 ) {
	if (!fixed_type_loaded) load_fixed_type();
	if ((mis.rows() == 1) && (mis.cols() == 1)) {
	  FixedPoint f(mis(0,0), mds(0,0));
	  retval = new octave_fixed (f);
	} else {
	  FixedMatrix f(mis, mds);
	  retval = new octave_fixed_matrix (f);
	}
      } else if (nargin == 3) {
	Matrix a = args(2).matrix_value();
	if ((mis.rows() == 1) && (mis.cols() == 1)) {
	  if (!fixed_type_loaded) load_fixed_type ();
	  FixedMatrix f (mis(0,0), mds(0,0), a);
	  retval = new octave_fixed_matrix (f);
	} else {
	  if ((mis.rows() != a.rows()) || (mis.cols() != a.cols()))
	    error("fixed: dimension mismatch in args");
	  else {
	    if (!fixed_type_loaded) load_fixed_type ();
	    FixedMatrix f (mis, mds, a);
	    retval = new octave_fixed_matrix (f);
	  }
	}
      }
    }
  } else
    print_usage ();
  
  
  if (error_state) {
    error("fixed: failed to create fixed point number");
    return octave_value();
  } else {
    retval.maybe_mutate();
    return retval;
  }
}

// This macro must start with DEFUN_DLD so that the automatic collection
// of the function helps can take place!! The second DEFUN_DLD must NOT
// appear on a new-line, otherwise the indexing script will be confused!!
#define DEFUN_DLD_FIXED_SNGL_ARG(NAME, HELP, FUNC, \
   REAL_CAN_RET_CMPLX_UPPER,UPPER, REAL_CAN_RET_CMPLX_LOWER, \
   LOWER) DEFUN_DLD (NAME, args, nargout, HELP) \
  { \
    int nargin = args.length(); \
    octave_value retval; \
    if ( nargin != 1 ) { \
      print_usage (); \
    } else { \
      if (fixed_type_loaded) { \
        if (args(0).type_id () == octave_fixed::static_type_id ()) { \
	  FixedPoint f = ((const octave_fixed&) args(0).get_rep()) \
	    .fixed_value (); \
          if ((REAL_CAN_RET_CMPLX_UPPER && (f > UPPER)) || \
              (REAL_CAN_RET_CMPLX_LOWER && (f < LOWER))) \
	    retval = new octave_fixed_complex \
                    (FUNC (FixedPointComplex(f,FixedPoint(f.getintsize(), \
						f.getdecsize())))); \
          else \
	    retval = new octave_fixed (FUNC (f)); \
        } else if (args(0).type_id () == \
				octave_fixed_matrix::static_type_id ()) { \
	  FixedMatrix f = ((const octave_fixed_matrix&) args(0).get_rep()) \
	    .fixed_matrix_value (); \
          if ((REAL_CAN_RET_CMPLX_UPPER && (f.row_max().max() \
							> UPPER)) || \
              (REAL_CAN_RET_CMPLX_LOWER && (f.row_min().min() \
							< LOWER))) { \
             retval = new octave_fixed_complex_matrix \
                     (FUNC (FixedComplexMatrix(f))); \
          } else \
	    retval = new octave_fixed_matrix (FUNC (f)); \
        } else if (args(0).type_id () == \
		   octave_fixed_complex::static_type_id ()) { \
	  FixedPointComplex f = ((const octave_fixed_complex&) \
                   args(0).get_rep()).fixed_complex_value (); \
          retval = new octave_fixed_complex (FUNC (f)); \
        } else if (args(0).type_id () == \
		   octave_fixed_complex_matrix::static_type_id ()) { \
	  FixedComplexMatrix f = ((const octave_fixed_complex_matrix&) \
                   args(0).get_rep()).fixed_complex_matrix_value (); \
          retval = new octave_fixed_complex_matrix (FUNC (f)); \
        } else \
	  print_usage (); \
      } else \
        print_usage (); \
    } \
    retval.maybe_mutate(); \
    return retval; \
  }

// PKG_ADD: autoload ("freal", "fixed.oct");
// PKG_ADD: dispatch ("real", "freal", "fixed scalar")
// PKG_ADD: dispatch ("real", "freal", "fixed matrix")
// PKG_ADD: dispatch ("real", "freal", "fixed complex")
// PKG_ADD: dispatch ("real", "freal", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (freal, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} freal (@var{x})\n\
Returns the real part of the fixed point value @var{x}.\n\
@end deftypefn", ::real, 0, 0, 0, 0)

// PKG_ADD: autoload ("fimag", "fixed.oct");
// PKG_ADD: dispatch ("imag", "fimag", "fixed scalar")
// PKG_ADD: dispatch ("imag", "fimag", "fixed matrix")
// PKG_ADD: dispatch ("imag", "fimag", "fixed complex")
// PKG_ADD: dispatch ("imag", "fimag", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fimag, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fimag (@var{x})\n\
Returns the imaginary part of the fixed point value @var{x}.\n\
@end deftypefn", ::imag, 0, 0, 0, 0)

// PKG_ADD: autoload ("fconj", "fixed.oct");
// PKG_ADD: dispatch ("conj", "fconj", "fixed scalar")
// PKG_ADD: dispatch ("conj", "fconj", "fixed matrix")
// PKG_ADD: dispatch ("conj", "fconj", "fixed complex")
// PKG_ADD: dispatch ("conj", "fconj", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fconj, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fconj (@var{x})\n\
Returns the conjuate of the fixed point value @var{x}.\n\
@end deftypefn", ::conj, 0, 0, 0, 0)

// PKG_ADD: autoload ("fabs", "fixed.oct");
// PKG_ADD: dispatch ("abs", "fabs", "fixed scalar")
// PKG_ADD: dispatch ("abs", "fabs", "fixed matrix")
// PKG_ADD: dispatch ("abs", "fabs", "fixed complex")
// PKG_ADD: dispatch ("abs", "fabs", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fabs, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fabs (@var{x})\n\
Compute the magnitude of the fixed point value @var{x}.\n\
@end deftypefn", ::abs, 0, 0, 0, 0)

// PKG_ADD: autoload ("farg", "fixed.oct");
// PKG_ADD: dispatch ("arg", "farg", "fixed scalar")
// PKG_ADD: dispatch ("arg", "farg", "fixed matrix")
// PKG_ADD: dispatch ("arg", "farg", "fixed complex")
// PKG_ADD: dispatch ("arg", "farg", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (farg, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} farg (@var{x})\n\
Compute the argument of @var{x}, defined as\n\
@iftex\n\
@tex\n\
$\\theta = atan2( y , x)$\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
@var{theta} = @code{atan2 (@var{y}, @var{x})}\n\
@end ifinfo\n\
in radians. For example\n\
\n\
@example\n\
@group\n\
farg (fixed (3,5,3+4i))\n\
      @result{}  0.90625\n\
@end group\n\
@end example\n\
@end deftypefn", ::arg, 1, FixedPoint(1,0,1,0), 1, FixedPoint())

// PKG_ADD: autoload ("fangle", "fixed.oct");
// PKG_ADD: dispatch ("angle", "fangle", "fixed scalar")
// PKG_ADD: dispatch ("angle", "fangle", "fixed matrix")
// PKG_ADD: dispatch ("angle", "fangle", "fixed complex")
// PKG_ADD: dispatch ("angle", "fangle", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fangle, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fangle (@var{x})\n\
See @dfn{farg}.\n\
@end deftypefn", ::arg, 1, FixedPoint(1,0,1,0), 1, FixedPoint())

// PKG_ADD: autoload ("fcos", "fixed.oct");
// PKG_ADD: dispatch ("cos", "fcos", "fixed scalar")
// PKG_ADD: dispatch ("cos", "fcos", "fixed matrix")
// PKG_ADD: dispatch ("cos", "fcos", "fixed complex")
// PKG_ADD: dispatch ("cos", "fcos", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fcos, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fcos (@var{x})\n\
Compute the cosine of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{fcosh, fsin, fsinh, ftan, ftanh}", ::cos, 0, 0, 0, 0)

// PKG_ADD: autoload ("fcosh", "fixed.oct");
// PKG_ADD: dispatch ("cosh", "fcosh", "fixed scalar")
// PKG_ADD: dispatch ("cosh", "fcosh", "fixed matrix")
// PKG_ADD: dispatch ("cosh", "fcosh", "fixed complex")
// PKG_ADD: dispatch ("cosh", "fcosh", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fcosh, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fcosh (@var{x})\n\
Compute the hyperbolic cosine of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{fcos, fsin, fsinh, ftan, ftanh}", ::cosh, 0, 0, 0, 0)

// PKG_ADD: autoload ("fsin", "fixed.oct");
// PKG_ADD: dispatch ("sin", "fsin", "fixed scalar")
// PKG_ADD: dispatch ("sin", "fsin", "fixed matrix")
// PKG_ADD: dispatch ("sin", "fsin", "fixed complex")
// PKG_ADD: dispatch ("sin", "fsin", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fsin, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fsin (@var{x})\n\
Compute the sine of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{fcos, fcosh, fsinh, ftan, ftanh}", ::sin, 0, 0, 0, 0)

// PKG_ADD: autoload ("fsinh", "fixed.oct");
// PKG_ADD: dispatch ("sinh", "fsinh", "fixed scalar")
// PKG_ADD: dispatch ("sinh", "fsinh", "fixed matrix")
// PKG_ADD: dispatch ("sinh", "fsinh", "fixed complex")
// PKG_ADD: dispatch ("sinh", "fsinh", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fsinh, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fsinh (@var{x})\n\
Compute the hyperbolic sine of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{fcos, fcosh, fsin, ftan, ftanh}", ::sinh, 0, 0, 0, 0)

// PKG_ADD: autoload ("ftan", "fixed.oct");
// PKG_ADD: dispatch ("tan", "ftan", "fixed scalar")
// PKG_ADD: dispatch ("tan", "ftan", "fixed matrix")
// PKG_ADD: dispatch ("tan", "ftan", "fixed complex")
// PKG_ADD: dispatch ("tan", "ftan", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (ftan, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} ftan (@var{x})\n\
Compute the tan of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{fcos, fcosh, fsinh, ftan, ftanh}", ::tan, 0, 0, 0, 0)

// PKG_ADD: autoload ("ftanh", "fixed.oct");
// PKG_ADD: dispatch ("tanh", "ftanh", "fixed scalar")
// PKG_ADD: dispatch ("tanh", "ftanh", "fixed matrix")
// PKG_ADD: dispatch ("tanh", "ftanh", "fixed complex")
// PKG_ADD: dispatch ("tanh", "ftanh", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (ftanh, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} ftanh (@var{x})\n\
Compute the hyperbolic tan of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{fcos, fcosh, fsin, fsinh, ftan}", ::tanh, 0, 0, 0, 0)

// PKG_ADD: autoload ("fsqrt", "fixed.oct");
// PKG_ADD: dispatch ("sqrt", "fsqrt", "fixed scalar")
// PKG_ADD: dispatch ("sqrt", "fsqrt", "fixed matrix")
// PKG_ADD: dispatch ("sqrt", "fsqrt", "fixed complex")
// PKG_ADD: dispatch ("sqrt", "fsqrt", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fsqrt, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fsqrt (@var{x})\n\
Compute the square-root of the fixed point value @var{x}.\n\
@end deftypefn", ::sqrt, 0, 0, 1, FixedPoint());

// PKG_ADD: autoload ("fexp", "fixed.oct");
// PKG_ADD: dispatch ("exp", "fexp", "fixed scalar")
// PKG_ADD: dispatch ("exp", "fexp", "fixed matrix")
// PKG_ADD: dispatch ("exp", "fexp", "fixed complex")
// PKG_ADD: dispatch ("exp", "fexp", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fexp, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fexp (@var{x})\n\
Compute the exponential of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{log, log10, pow}", ::exp, 0, 0, 0, 0);

// PKG_ADD: autoload ("flog", "fixed.oct");
// PKG_ADD: dispatch ("log", "flog", "fixed scalar")
// PKG_ADD: dispatch ("log", "flog", "fixed matrix")
// PKG_ADD: dispatch ("log", "flog", "fixed complex")
// PKG_ADD: dispatch ("log", "flog", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (flog, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} flog (@var{x})\n\
Compute the natural logarithm of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{fexp, flog10, fpow}", ::log, 0, 0, 1, FixedPoint());

// PKG_ADD: autoload ("flog10", "fixed.oct");
// PKG_ADD: dispatch ("log10", "flog10", "fixed scalar")
// PKG_ADD: dispatch ("log10", "flog10", "fixed matrix")
// PKG_ADD: dispatch ("log10", "flog10", "fixed complex")
// PKG_ADD: dispatch ("log10", "flog10", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (flog10, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} flog10 (@var{x})\n\
Compute the base-10 logarithm of the fixed point value @var{x}.\n\
@end deftypefn\n\
@seealso{fexp, flog, fpow}", ::log10, 0, 0, 1, FixedPoint());

// PKG_ADD: autoload ("fround", "fixed.oct");
// PKG_ADD: dispatch ("round", "fround", "fixed scalar")
// PKG_ADD: dispatch ("round", "fround", "fixed matrix")
// PKG_ADD: dispatch ("round", "fround", "fixed complex")
// PKG_ADD: dispatch ("round", "fround", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fround, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fround (@var{x})\n\
Return the rounded value to the nearest integer of @var{x}.\n\
@end deftypefn\n\
@seealso{ffloor, fceil}", ::round, 0, 0, 0, 0);

// PKG_ADD: autoload ("ffloor", "fixed.oct");
// PKG_ADD: dispatch ("floor", "ffloor", "fixed scalar")
// PKG_ADD: dispatch ("floor", "ffloor", "fixed matrix")
// PKG_ADD: dispatch ("floor", "ffloor", "fixed complex")
// PKG_ADD: dispatch ("floor", "ffloor", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (ffloor, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} ffloor (@var{x})\n\
Return the largest integer not greater than @var{x}.\n\
@end deftypefn\n\
@seealso{fround, fceil}", ::floor, 0, 0, 0, 0);

// PKG_ADD: autoload ("fceil", "fixed.oct");
// PKG_ADD: dispatch ("ceil", "fceil", "fixed scalar")
// PKG_ADD: dispatch ("ceil", "fceil", "fixed matrix")
// PKG_ADD: dispatch ("ceil", "fceil", "fixed complex")
// PKG_ADD: dispatch ("ceil", "fceil", "fixed complex matrix")
DEFUN_DLD_FIXED_SNGL_ARG (fceil, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fceil (@var{x})\n\
Return the smallest integer not less than @var{x}.\n\
@end deftypefn\n\
@seealso{fround, ffloor}", ::ceil, 0, 0, 0, 0);

// This macro must start with DEFUN_DLD so that the automatic collection
// of the function helps can take place!! The second DEFUN_DLD must NOT
// appear on a new-line, otherwise the indexing script will be confused!!
#define DEFUN_DLD_FIXED_DIM_ARG(NAME, HELP, FUNC) DEFUN_DLD (NAME, args, nargout, HELP) \
  { \
    int nargin = args.length(); \
    octave_value retval; \
    if ((nargin != 1 ) && (nargin != 2)) \
      print_usage (); \
    else { \
      int dim = (nargin == 1 ? -1 : args(1).int_value(true) - 1); \
      if (error_state) return retval; \
      if (dim < -1 || dim > 1) { \
	error (#NAME ": invalid dimension argument = %d", dim + 1); \
        return retval; \
      } \
      if (fixed_type_loaded) { \
        if (args(0).type_id () == octave_fixed::static_type_id ()) { \
	    FixedMatrix f = ((const octave_fixed&) args(0).get_rep()) \
	      .fixed_matrix_value (); \
            retval  = new octave_fixed( f .FUNC (dim) (0,0)); \
        } else if (args(0).type_id () == octave_fixed_complex:: \
		 static_type_id ()) { \
	    FixedComplexMatrix f = ((const octave_fixed_complex&) \
	      args(0).get_rep()).fixed_complex_matrix_value (); \
            retval = new octave_fixed_complex(f .FUNC (dim) (0,0)); \
        } else if (args(0).type_id () == \
		   octave_fixed_matrix::static_type_id ()) { \
	    FixedMatrix f = ((const octave_fixed_matrix&) args(0).get_rep()) \
	      .fixed_matrix_value (); \
            retval = new octave_fixed_matrix(f .FUNC (dim)); \
        } else if (args(0).type_id () == \
		   octave_fixed_complex_matrix::static_type_id ()) { \
	    FixedComplexMatrix f = ((const octave_fixed_complex_matrix&) \
	      args(0).get_rep()).fixed_complex_matrix_value (); \
            retval = new octave_fixed_complex_matrix(f .FUNC (dim)); \
        } else \
	    print_usage (); \
      } else \
        print_usage (); \
    } \
    retval.maybe_mutate(); \
    return retval; \
  }

// PKG_ADD: autoload ("fprod", "fixed.oct");
// PKG_ADD: dispatch ("prod", "fprod", "fixed scalar");
// PKG_ADD: dispatch ("prod", "fprod", "fixed matrix");
// PKG_ADD: dispatch ("prod", "fprod", "fixed complex");
// PKG_ADD: dispatch ("prod", "fprod", "fixed complex matrix");
DEFUN_DLD_FIXED_DIM_ARG (fprod, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fprod (@var{x},@var{dim})\n\
Product of elements along dimension @var{dim}.  If @var{dim} is omitted,\n\
it defaults to 1 (column-wise products).\n\
@end deftypefn\n\
@seealso{fsum, fsumsq}", prod)

// PKG_ADD: autoload ("fcumprod", "fixed.oct");
// PKG_ADD: dispatch ("cumprod", "fcumprod", "fixed scalar");
// PKG_ADD: dispatch ("cumprod", "fcumprod", "fixed matrix");
// PKG_ADD: dispatch ("cumprod", "fcumprod", "fixed complex");
// PKG_ADD: dispatch ("cumprod", "fcumprod", "fixed complex matrix");
DEFUN_DLD_FIXED_DIM_ARG (fcumprod, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fcumprod (@var{x},@var{dim})\n\
Cumulative product of elements along dimension @var{dim}.  If @var{dim}\n\
is omitted, it defaults to 1 (column-wise cumulative products).\n\
@end deftypefn\n\
@seealso{fcumsum}", cumprod)

// PKG_ADD: autoload ("fsum", "fixed.oct");
// PKG_ADD: dispatch ("sum", "fsum", "fixed scalar");
// PKG_ADD: dispatch ("sum", "fsum", "fixed matrix");
// PKG_ADD: dispatch ("sum", "fsum", "fixed complex");
// PKG_ADD: dispatch ("sum", "fsum", "fixed complex matrix");
DEFUN_DLD_FIXED_DIM_ARG (fsum, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fsum (@var{x},@var{dim})\n\
Sum of elements along dimension @var{dim}.  If @var{dim} is omitted, it\n\
defaults to 1 (column-wise sum).\n\
@end deftypefn\n\
@seealso{fprod, fsumsq}", sum)

// PKG_ADD: autoload ("fcumsum", "fixed.oct");
// PKG_ADD: dispatch ("cumsum", "fcumsum", "fixed scalar");
// PKG_ADD: dispatch ("cumsum", "fcumsum", "fixed matrix");
// PKG_ADD: dispatch ("cumsum", "fcumsum", "fixed complex");
// PKG_ADD: dispatch ("cumsum", "fcumsum", "fixed complex matrix");
DEFUN_DLD_FIXED_DIM_ARG (fcumsum, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fcumsum (@var{x},@var{dim})\n\
Cumulative sum of elements along dimension @var{dim}.  If @var{dim}\n\
is omitted, it defaults to 1 (column-wise cumulative sums).\n\
@end deftypefn\n\
@seealso{fcumprod}", cumsum)

// PKG_ADD: autoload ("fsumsq", "fixed.oct");
// PKG_ADD: dispatch ("sumsq", "fsumsq", "fixed scalar");
// PKG_ADD: dispatch ("sumsq", "fsumsq", "fixed matrix");
// PKG_ADD: dispatch ("sumsq", "fsumsq", "fixed complex");
// PKG_ADD: dispatch ("sumsq", "fsumsq", "fixed complex matrix");
DEFUN_DLD_FIXED_DIM_ARG (fsumsq, "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} fsumsq (@var{x},@var{dim})\n\
Sum of squares of elements along dimension @var{dim}.  If @var{dim}\n\
is omitted, it defaults to 1 (column-wise sum of squares).\n\
This function is equivalent to computing\n\
@example\n\
fsum (x .* fconj (x), dim)\n\
@end example\n\
but it uses less memory and avoids calling @code{fconj} if @var{x} is real.\n\
@end deftypefn\n\
@seealso{fprod, fsum}", sumsq)

// PKG_ADD: autoload ("freshape", "fixed.oct");
// PKG_ADD: dispatch ("reshape", "freshape", "fixed scalar");
// PKG_ADD: dispatch ("reshape", "freshape", "fixed matrix");
// PKG_ADD: dispatch ("reshape", "freshape", "fixed complex");
// PKG_ADD: dispatch ("reshape", "freshape", "fixed complex matrix");
DEFUN_DLD (freshape, args, ,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} freshape (@var{a}, @var{m}, @var{n})\n"
"Return a fixed matrix with @var{m} rows and @var{n} columns whose elements\n"
"are taken from the fixed matrix @var{a}.  To decide how to order the\n"
"elements, Octave pretends that the elements of a matrix are stored in\n"
"column-major order (like Fortran arrays are stored).\n"
"\n"
"For example,\n"
"\n"
"@example\n"
"freshape (fixed(3, 2, [1, 2, 3, 4]), 2, 2)\n"
"ans =\n"
"\n"
"  1.00  3.00\n"
"  2.00  4.00\n"
"@end example\n"
"\n"
"If the variable @code{do_fortran_indexing} is nonzero, the\n"
"@code{freshape} function is equivalent to\n"
"\n"
"@example\n"
"@group\n"
"retval = fixed(0,0,zeros (m, n));\n"
"retval (:) = a;\n"
"@end group\n"
"@end example\n"
"\n"
"@noindent\n"
"but it is somewhat less cryptic to use @code{freshape} instead of the\n"
"colon operator.  Note that the total number of elements in the original\n"
"matrix must match the total number of elements in the new matrix.\n"
"@end deftypefn\n"
"@seealso{`:' and do_fortran_indexing}") 
{
  octave_value retval;
  int nargin = args.length ();

  if (nargin != 2 && nargin !=3) {
    error("freshape (a, m, m) or freshape (a, size(b))");
    print_usage ();
  } else {
    int mr = 0, mc = 0;
    if (nargin == 2) {
      RowVector tmp = args(1).row_vector_value();
      if (tmp.length() != 2)
	error("freshape: called with 2 args, second must be 2-element vector"); 
      mr = (int)tmp(0);
      mc = (int)tmp(1);
    } else if (nargin == 3) {
      mr = args(1).nint_value ();
      mc = args(2).nint_value ();
    } 
    if (args(0).is_scalar_type())
      if (mr != 1 || mc != 1)
	error("freshape: sizes must match");
      else
	retval = args(0);
    else {
      if (args(0).is_complex_type()) {
	if (fixed_type_loaded &&
	    (args(0).type_id () == 
	       octave_fixed_complex_matrix::static_type_id ())) {
	  FixedComplexMatrix a = ((const octave_fixed_complex_matrix&) 
			args(0).get_rep()).fixed_complex_matrix_value();
	  int nr = a.rows();
	  int nc = a.cols();
	  if ((nr * nc) != (mr * mc))
	    error("freshape: sizes must match");
	  else {
	    FixedComplexRowVector tmp1(mr*mc);
	    for (int i=0;i<nr;i++)
	      for (int j=0;j<nc;j++)
		tmp1(i+j*nr) = a(i,j);
	    FixedComplexMatrix tmp2(mr,mc);
	    for (int i=0;i<mr;i++)
	      for (int j=0;j<mc;j++)
		tmp2(i,j) = tmp1(i+j*mr);
	    retval = new octave_fixed_complex_matrix(tmp2);
	  }
	} else {
	  gripe_wrong_type_arg ("freshape", args(0));
	  return retval;
	}
      } else {
	if (fixed_type_loaded &&
	    (args(0).type_id () == octave_fixed_matrix::static_type_id ())) {
	  FixedMatrix a = ((const octave_fixed_matrix&) args(0).get_rep()).
	    fixed_matrix_value();
	  int nr = a.rows();
	  int nc = a.cols();
	  if ((nr * nc) != (mr * mc))
	    error("freshape: sizes must match");
	  else {
	    FixedRowVector tmp1(mr*mc);
	    for (int i=0;i<nr;i++)
	      for (int j=0;j<nc;j++)
		tmp1(i+j*nr) = a(i,j);
	    FixedMatrix tmp2(mr,mc);
	    for (int i=0;i<mr;i++)
	      for (int j=0;j<mc;j++)
		tmp2(i,j) = tmp1(i+j*mr);
	    retval = new octave_fixed_matrix(tmp2);
	  }
	} else {
	  gripe_wrong_type_arg ("freshape", args(0));
	  return retval;
	}
      }
    }
  }
  return retval;
}

static octave_value
make_fdiag (const octave_value& a, const octave_value& b)
{
  octave_value retval;

  if (fixed_type_loaded) {
    if (a.is_complex_type() && ((a.type_id () == 
	 octave_fixed_complex::static_type_id ()) ||
	(a.type_id () == octave_fixed_complex_matrix::static_type_id ()))) {
      FixedComplexMatrix m;
      if (a.type_id () == octave_fixed_complex_matrix::static_type_id ())
	m = ((const octave_fixed_complex_matrix&) a.get_rep())
	  .fixed_complex_matrix_value();
      else
	m = ((const octave_fixed_complex&) a.get_rep())
	  .fixed_complex_matrix_value();

      int k = b.nint_value(true);

      if (! error_state) {
	int nr = m.rows ();
	int nc = m.columns ();
	
	if (nr == 0 || nc == 0)
	  retval = new octave_fixed_complex_matrix (m);
	else if (nr == 1 || nc == 1) {
	  int roff = 0;
	  int coff = 0;
	  if (k > 0) {
	    roff = 0;
	    coff = k;
	  } else if (k < 0) {
	    k = -k;
	    roff = k;
	    coff = 0;
	  }

	  // Try to be a bit intelligent about the representation of the zeros
	  bool same = true;
	  Complex is = m(0,0).getintsize();
	  Complex ds = m(0,0).getdecsize();
	  for (int j = 0; j < nc; j++) {
	    for (int i = 0; i < nr; i++) {
	      if ((is != m(i,j).getintsize()) || (ds != m(i,j).getdecsize())) {
		same = false;
		break;
	      }
	    }
	    if (!same) break;
	  }


	  if (nr == 1) {
	    int n = nc + k;
	    FixedComplexMatrix r;
	    if (same)
	      r.resize(dim_vector (n,n), FixedPointComplex(is,ds));
	    else
	      r.resize(dim_vector (n,n));
	    for (int i = 0; i < nc; i++)
	      r (i+roff, i+coff) = m (0, i);
	    retval = new octave_fixed_complex_matrix (r);
	  } else {
	    int n = nr + k;
	    FixedComplexMatrix r;
	    if (same)
	      r.resize(dim_vector (n,n), FixedPointComplex(is,ds));
	    else
	      r.resize(dim_vector (n,n));
	    for (int i = 0; i < nr; i++)
	      r (i+roff, i+coff) = m (i, 0);
	    retval = new octave_fixed_complex_matrix (r);
	  }
	} else {
	  FixedComplexColumnVector r = m.diag (k);
	  if (r.capacity () > 0)
	    retval = new octave_fixed_complex_matrix (r);
	}
      }
    } else if ((a.type_id () == octave_fixed::static_type_id ()) ||
	       (a.type_id () == octave_fixed_matrix::static_type_id ())) {
      FixedMatrix m;
      if (a.type_id () == octave_fixed_matrix::static_type_id ())
	m = ((const octave_fixed_matrix&) a.get_rep()).fixed_matrix_value();
      else
	m = ((const octave_fixed&) a.get_rep()).fixed_matrix_value();

      int k = b.nint_value(true);

      if (! error_state) {
	int nr = m.rows ();
	int nc = m.columns ();
	
	if (nr == 0 || nc == 0)
	  retval = new octave_fixed_matrix (m);
	else if (nr == 1 || nc == 1) {
	  int roff = 0;
	  int coff = 0;
	  if (k > 0) {
	    roff = 0;
	    coff = k;
	  } else if (k < 0) {
	    k = -k;
	    roff = k;
	    coff = 0;
	  }

	  // Try to be a bit intelligent about the representation of the zeros
	  bool same = true;
	  int is = m(0,0).getintsize();
	  int ds = m(0,0).getdecsize();
	  for (int j = 0; j < nc; j++) {
	    for (int i = 0; i < nr; i++) {
	      if ((is != m(i,j).getintsize()) || (ds != m(i,j).getdecsize())) {
		same = false;
		break;
	      }
	    }
	    if (!same) break;
	  }

	  if (nr == 1) {
	    int n = nc + k;
	    FixedMatrix r;
	    if (same)
	      r.resize(n,n, FixedPoint(is,ds));
	    else
	      r.resize(n,n);
	    for (int i = 0; i < nc; i++)
	      r (i+roff, i+coff) = m (0, i);
	    retval = new octave_fixed_matrix (r);
	  } else {
	    int n = nr + k;
	    FixedMatrix r;
	    if (same)
	      r.resize(n,n,FixedPoint(is,ds));
	    else
	      r.resize(n,n);
	    for (int i = 0; i < nr; i++)
	      r (i+roff, i+coff) = m (i, 0);
	    retval = new octave_fixed_matrix (r);
	  }
	} else {
	  FixedColumnVector r = m.diag (k);
	  if (r.capacity () > 0)
	    retval = new octave_fixed_matrix (r);
	}
      }
    } else
      gripe_wrong_type_arg ("fdiag", a);
  } else
      gripe_wrong_type_arg ("fdiag", a);
  retval.maybe_mutate();
  return retval;
}

// PKG_ADD: autoload ("fdiag", "fixed.oct");
// PKG_ADD: dispatch ("diag", "fdiag", "fixed scalar");
// PKG_ADD: dispatch ("diag", "fdiag", "fixed matrix");
// PKG_ADD: dispatch ("diag", "fdiag", "fixed complex");
// PKG_ADD: dispatch ("diag", "fdiag", "fixed complex matrix");
DEFUN_DLD (fdiag, args, ,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} fdiag (@var{v}, @var{k})\n"
"Return a diagonal matrix with fixed point vector @var{v} on diagonal\n"
"@var{k}. The second argument is optional. If it is positive, the vector is\n"
"placed on the @var{k}-th super-diagonal. If it is negative, it is placed\n"
"on the @var{-k}-th sub-diagonal.  The default value of @var{k} is 0, and\n"
"the vector is placed on the main diagonal.  For example,\n"
"\n"
"@example\n"
"fdiag (fixed(3,2,[1, 2, 3]), 1)\n"
"ans =\n"
"\n"
"  0.00  1.00  0.00  0.00\n"
"  0.00  0.00  2.00  0.00\n"
"  0.00  0.00  0.00  3.00\n"
"  0.00  0.00  0.00  0.00\n"
"@end example\n"
"\n"
"Note that if all of the elements of the original vector have the same fixed\n"
"point representation, then the zero elements in the matrix are created with\n"
"the same representation. Otherwise the zero elements are created with the\n"
"equivalent of the fixed point value @code{fixed(0,0,0)}.\n"
"@end deftypefn\n"
"@seealso{diag}")
{
  octave_value retval;

  int nargin = args.length ();

  if (nargin == 1 && args(0).is_defined ())
    retval = make_fdiag (args(0), octave_value(0.));
  else if (nargin == 2 && args(0).is_defined () && args(1).is_defined ())
    retval = make_fdiag (args(0), args(1));
  else
    print_usage ();

  return retval;
}

// PKG_ADD: autoload ("fatan2", "fixed.oct");
// PKG_ADD: dispatch ("atan2", "fatan2", "fixed scalar");
// PKG_ADD: dispatch ("atan2", "fatan2", "fixed matrix");
// PKG_ADD: dispatch ("atan2", "fatan2", "fixed complex");
// PKG_ADD: dispatch ("atan2", "fatan2", "fixed complex matrix");
DEFUN_DLD (fatan2, args, ,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} fatan2 (@var{y}, @var{x})\n"
"Compute atan (Y / X) for corresponding fixed point elements of Y and X.\n"
"The result is in range -pi to pi.\n"
"@end deftypefn\n")
{
  octave_value retval;
  int nargin = args.length ();
  if (nargin == 2) {  
    FixedMatrix a, b;
    if (args(0).type_id () == octave_fixed::static_type_id ())
      a = ((const octave_fixed&)args(0).get_rep()).fixed_matrix_value();
    else if (args(0).type_id () == octave_fixed_matrix::static_type_id ())
      a = ((const octave_fixed_matrix&)args(0).get_rep()).fixed_matrix_value();
    else if (args(0).type_id () == octave_fixed_complex::static_type_id ())
      a = ((const octave_fixed_complex&)args(0).get_rep())
	.fixed_matrix_value();
    else if (args(0).type_id () == 
	     octave_fixed_complex_matrix::static_type_id ())
      a = ((const octave_fixed_complex_matrix&)args(0).get_rep())
	.fixed_matrix_value();
    else {
      print_usage ();
      return retval;
    }
    if (args(1).type_id () == octave_fixed::static_type_id ())
      b = ((const octave_fixed&)args(1).get_rep()).fixed_matrix_value();
    else if (args(1).type_id () == octave_fixed_matrix::static_type_id ())
      b = ((const octave_fixed_matrix&)args(1).get_rep()).fixed_matrix_value();
    else if (args(1).type_id () == octave_fixed_complex::static_type_id ())
      b = ((const octave_fixed_complex&)args(1).get_rep())
	.fixed_matrix_value();
    else if (args(1).type_id () == 
	     octave_fixed_complex_matrix::static_type_id ())
      b = ((const octave_fixed_complex_matrix&)args(1).get_rep())
	.fixed_matrix_value();
    else {
      print_usage ();
      return retval;
    }
    retval = new octave_fixed_matrix(atan2(a, b));
    retval.maybe_mutate();
  } else
    print_usage ();

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
