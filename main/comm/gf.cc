/*

Copyright (C) 2003 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA
02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

Part of the function rsenc and the function decode_rs are Copyrighted
by Phil Karn and originally bore the copyright

 Reed-Solomon encoder
 Copyright 2002, Phil Karn, KA9Q
 May be used under the terms of the GNU General Public License (GPL)

See the website http://www.ka9q.net/code/fec for more details.

*/

#include <octave/utils.h>
#include "galois.h"
#include "ov-galois.h"

static bool galois_type_loaded = false;

DEFUN_DLD (isgalois, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} isgalois (@var{expr})\n\
Return 1 if the value of the expression @var{expr} is a Galois Field.\n\
@end deftypefn") 
{
   if (args.length() != 1) 
     print_usage("isgalois");
   else if (!galois_type_loaded)
     // Can be of Galois type if the type isn't load :-/
     return octave_value(0);
   else 
     return octave_value(args(0).type_id () ==
			    octave_galois::static_type_id ());
   return octave_value();
}

DEFUN_DLD (gf, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =} gf (@var{x})\n\
@deftypefnx {Loadable Function} {@var{y} =} gf (@var{x}, @var{m})\n\
@deftypefnx {Loadable Function} {@var{y} =} gf (@var{x}, @var{m}, @var{primpoly})\n\
Creates a Galois field array GF(2^@var{m}) from the matrix @var{x}. The\n\
Galois field has 2^@var{m} elements, where @var{m} must be between 1 and 16.\n\
The elements of @var{x} must be between 0 and 2^@var{m} - 1. If @var{m} is\n\
undefined it defaults to the value 1.\n\
\n\
The primitive polynomial to use in the creation of Galois field can be\n\
specified with the @var{primpoly} variable. If this is undefined a default\n\
primitive polynomial is used. It should be noted that the primitive\n\
polynomial must be of the degree @var{m} and it must be irreducible.\n\
\n\
The output of this function is recognized as a Galois field by Octave and\n\
other matrices will be converted to the same Galois field when used in an\n\
arithmetic operation with a Galois field.\n\
\n\
@end deftypefn\n\
@seealso{isprimitive,primpoly}")
{
  Matrix data = args(0).matrix_value();
  octave_value retval;
  int nargin = args.length ();
  int m = 1;
  int primpoly = 0;

  if (!galois_type_loaded) {
      octave_galois::register_type ();
      install_gm_gm_ops ();
      install_m_gm_ops ();
      install_gm_m_ops ();
      install_s_gm_ops ();
      install_gm_s_ops ();
      install_fil_gm_ops ();
      galois_type_loaded = true;
  }

  if ( nargin > 1 )
    m = args(1).int_value();
  if ( nargin > 2 )
    primpoly = args(2).int_value();
  if (nargin > 3) {
    error ("gf: too many arguments");
    return retval;
  }

  retval = new octave_galois(data, m, primpoly);
  return retval;
}

static octave_value
make_gdiag (const octave_value& a, const octave_value& b)
{
  octave_value retval;

  if ((!galois_type_loaded) || (a.type_id () != 
				octave_galois::static_type_id ()))
    gripe_wrong_type_arg ("gdiag", a);
  else {
    galois m = ((const octave_galois&) a.get_rep()).galois_value ();
    int k = b.nint_value();

    if (! error_state)
      {
	int nr = m.rows ();
	int nc = m.columns ();

	if (nr == 0 || nc == 0)
	  retval = new octave_galois (m);
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

	  if (nr == 1) {
	    int n = nc + k;
	    galois r (n, n, 0, m.m(), m.primpoly());
	    for (int i = 0; i < nc; i++)
	      r.elem (i+roff, i+coff) = m.elem (0, i);
	    retval = new octave_galois (r);
	  } else {
	    int n = nr + k;
	    galois r (n, n, 0, m.m(), m.primpoly());
	    for (int i = 0; i < nr; i++)
	      r.elem (i+roff, i+coff) = m.elem (i, 0);
	    retval = new octave_galois (r);
	  }
	} else {
	  galois r = m.diag (k);
	  if (r.capacity () > 0)
	    retval = new octave_galois (r);
	}
      }
    else
      gripe_wrong_type_arg ("gdiag", a);
  }
  return retval;
}

// PKG_ADD: dispatch diag gdiag galois
DEFUN_DLD (gdiag, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} gdiag (@var{v}, @var{k})\n\
Return a diagonal matrix with Galois vector @var{v} on diagonal @var{k}.\n\
The second argument is optional.  If it is positive, the vector is placed on\n\
the @var{k}-th super-diagonal.  If it is negative, it is placed on the\n\
@var{-k}-th sub-diagonal.  The default value of @var{k} is 0, and the\n\
vector is placed on the main diagonal.  For example,\n\
\n\
@example\n\
@group\n\
diag ([1, 2, 3], 1)\n\
     @result{}  0  1  0  0\n\
         0  0  2  0\n\
         0  0  0  3\n\
         0  0  0  0\n\
@end group\n\
@end example\n\
@end deftypefn")
{
  octave_value retval;

  int nargin = args.length ();

  if (nargin == 1 && args(0).is_defined ())
    retval = make_gdiag (args(0), octave_value(0.));
  else if (nargin == 2 && args(0).is_defined () && args(1).is_defined ())
    retval = make_gdiag (args(0), args(1));
  else
    print_usage ("gdiag");

  return retval;
}

// PKG_ADD: dispatch reshape greshape galois
DEFUN_DLD (greshape, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} greshape (@var{a}, @var{m}, @var{n})\n\
Return a matrix with @var{m} rows and @var{n} columns whose elements are\n\
taken from the Galois array @var{a}.  To decide how to order the elements,\n\
Octave pretends that the elements of a matrix are stored in column-major\n\
order (like Fortran arrays are stored).\n\
\n\
For example,\n\
\n\
@example\n\
@group\n\
reshape ([1, 2, 3, 4], 2, 2)\n\
     @result{}  1  3\n\
         2  4\n\
@end group\n\
@end example\n\
\n\
If the variable @code{do_fortran_indexing} is nonzero, the\n\
@code{reshape} function is equivalent to\n\
\n\
@example\n\
@group\n\
retval = zeros (m, n);\n\
retval (:) = a;\n\
@end group\n\
@end example\n\
\n\
@noindent\n\
but it is somewhat less cryptic to use @code{reshape} instead of the\n\
colon operator.  Note that the total number of elements in the original\n\
matrix must match the total number of elements in the new matrix.\n\
@end deftypefn\n\
@seealso{`:' and do_fortran_indexing}") 
{
  octave_value retval;
  int nargin = args.length ();
  int mr = 0, mc = 0;

  if ((!galois_type_loaded) || (args(0).type_id () != 
				octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("greshape", args(0));
    return retval;
  }
  galois a = ((const octave_galois&) args(0).get_rep()).galois_value ();

  if (nargin == 2) {
    RowVector tmp = args(1).row_vector_value();
    mr = (int)tmp(0);
    mc = (int)tmp(1);
  } else if (nargin == 3) {
    mr = args(1).nint_value ();
    mc = args(2).nint_value ();
  } 

  if (nargin != 2 && nargin !=3) {
    error("greshape (a, m, m) or greshape (a, size(b))");
    print_usage("greshape");
  } else {
    int nr = a.rows();
    int nc = a.cols();
    if ((nr * nc) != (mr * mc))
      error("greshape: sizes must match");
    else {
      RowVector tmp1(mr*mc);
      for (int i=0;i<nr;i++)
	for (int j=0;j<nc;j++)
	  tmp1(i+j*nr) = (double)a.elem(i,j);
      galois tmp2(mr,mc,0,a.m(),a.primpoly());
      for (int i=0;i<mr;i++)
	for (int j=0;j<mc;j++)
	  tmp2.elem(i,j) = (int)tmp1(i+j*mr);
      retval = new octave_galois(tmp2);
    }
  }
  return retval;
}

#define DATA_REDUCTION(FCN) \
 \
  octave_value_list retval; \
 \
  int nargin = args.length (); \
 \
  if (nargin == 1 || nargin == 2) \
    { \
      octave_value arg = args(0); \
 \
      int dim = (nargin == 1 ? -1 : args(1).int_value (true) - 1); \
 \
      if (! error_state) \
	{ \
	  if (dim <= 1 && dim >= -1) \
	    { \
              if (galois_type_loaded && (arg.type_id () == \
                                     octave_galois::static_type_id ())) \
		{ \
		  galois tmp = ((const octave_galois&)arg.get_rep()).galois_value (); \
 \
		  if (! error_state) \
		    retval(0) = new octave_galois (tmp.FCN (dim)); \
		} \
	      else \
		{ \
		  gripe_wrong_type_arg (#FCN, arg); \
		  return retval; \
		} \
	    } \
	  else \
	    error (#FCN ": invalid dimension argument = %d", dim + 1); \
	} \
    } \
  else \
    print_usage (#FCN); \
 \
  return retval

// PKG_ADD: dispatch prod gprod galois
DEFUN_DLD (gprod, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} gprod (@var{x}, @var{dim})\n\
Product of elements along dimension @var{dim} of Galois array.  If\n\
@var{dim} is omitted, it defaults to 1 (column-wise products).\n\
@end deftypefn")
{
  DATA_REDUCTION (prod);
}

// PKG_ADD: dispatch sum gsum galois
DEFUN_DLD (gsum, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} gsum (@var{x}, @var{dim})\n\
Sum of elements along dimension @var{dim} of Galois array.  If @var{dim}\n\
is omitted, it defaults to 1 (column-wise sum).\n\
@end deftypefn")
{
  DATA_REDUCTION (sum);
}

// PKG_ADD: dispatch sumsq gsumsq galois
DEFUN_DLD (gsumsq, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} gsumsq (@var{x}, @var{dim})\n\
Sum of squares of elements along dimension @var{dim} of Galois array.\n\
If @var{dim} is omitted, it defaults to 1 (column-wise sum of squares).\n\
\n\
This function is equivalent to computing\n\
@example\n\
gsum (x .* conj (x), dim)\n\
@end example\n\
but it uses less memory.\n\
@end deftypefn")
{
  DATA_REDUCTION (sumsq);
}

// PKG_ADD: dispatch log glog galois
DEFUN_DLD (glog, args, ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} glog (@var{x})\n\
Compute the natural logarithm for each element of @var{x} for a Galois\n\
array.\n\
@end deftypefn")
{
  octave_value retval;
  int nargin = args.length ();

  if (!galois_type_loaded || (args(0).type_id () != 
			      octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("glog", args(0));
    return retval;
  }

  if (nargin != 1) {
    print_usage("glog");
    return retval;
  }

  galois a = ((const octave_galois&) args(0).get_rep()).galois_value ();

  retval = new octave_galois(a.log());

  return retval;
}

// PKG_ADD: dispatch exp gexp galois
DEFUN_DLD (gexp, args, ,
    "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} gexp (@var{x})\n\
Compute the anti-logarithm for each element of @var{x} for a Galois\n\
array.\n\
@end deftypefn")
{
  octave_value retval;
  int nargin = args.length ();

  if (!galois_type_loaded || (args(0).type_id () != 
			      octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("gexp", args(0));
    return retval;
  }

  if (nargin != 1) {
    print_usage("exp");
    return retval;
  }

  galois a = ((const octave_galois&) args(0).get_rep()).galois_value ();

  retval = new octave_galois(a.exp());

  return retval;
}

static inline int modn(int x, int m, int n)
{
  while (x >= n) {
    x -= n;
    x = (x >> m) + (x & n);
  }
  return x;
}

galois filter(galois& b, galois& a, galois& x, galois& si) {
  int ab_len = (a.length() > b.length() ? a.length() : b.length());
  b.resize(ab_len, 1, 0);
  galois retval(x.length(), 1, 0, b.m(), b.primpoly());
  int norm = a.elem(0,0);

  if (norm == 0) {
    error("gfilter: the first element of a must be non-zero");
    return galois();
  }
  if (si.length() != ab_len - 1) {
    error("gfilter: si must be a vector of length max(length(a), length(b)) - 1");
    return galois ();
  }
  if (norm != 1) {
    int idx_norm = b.index_of(norm);
    for (int i=0; i < b.length(); i++) {
      if (b.elem(i,0) != 0)
	b.elem(i,0) = b.alpha_to(modn(b.index_of(b.elem(i,0))-idx_norm+b.n(),
		b.m(),b.n()));
    }
  }
  if (a.length() > 1) {
    a.resize(ab_len, 1, 0);

    if (norm != 1) {
      int idx_norm = a.index_of(norm);
      for (int i=0; i < a.length(); i++)
	if (a.elem(i,0) != 0)
	  a.elem(i,0) = a.alpha_to(modn(a.index_of(a.elem(i,0))-idx_norm+a.n(),
				 a.m(),a.n()));
    }

    for (int i=0; i < x.length(); i++) {
      retval.elem(i,0) = si.elem(0,0);
      if ((b.elem(0,0) != 0) && (x.elem(i,0) != 0))
	retval.elem(i,0) ^= b.alpha_to(modn(b.index_of(b.elem(0,0)) + 
		b.index_of(x.elem(i,0)),b.m(),b.n()));
      if (si.length() > 1) {
	for (int j = 0; j < si.length() - 1; j++) {
	  si.elem(j,0) = si.elem(j+1,0);
	  if ((a.elem(j+1,0) != 0) && (retval.elem(i,0) != 0))
	    si.elem(j,0) ^= a.alpha_to(modn(a.index_of(a.elem(j+1,0)) + 
		a.index_of(retval.elem(i,0)),a.m(),a.n()));
	  if ((b.elem(j+1,0) != 0) && (x.elem(i,0) != 0))
	    si.elem(j,0) ^= b.alpha_to(modn(b.index_of(b.elem(j+1,0)) + 
		b.index_of(x.elem(i,0)),b.m(),b.n()));
	}
	si.elem(si.length()-1,0) = 0;
	if ((a.elem(si.length(),0) != 0) && (retval.elem(si.length(),0) != 0))
	  si.elem(si.length()-1,0) ^= a.alpha_to(modn(a.index_of(
		a.elem(si.length(),0))+a.index_of(retval.elem(i,0)),
		a.m(),a.n()));
	if ((b.elem(si.length(),0) != 0) && (x.elem(i,0) != 0))
	  si.elem(si.length()-1,0) ^= b.alpha_to(modn(b.index_of(
		b.elem(si.length(),0))+ b.index_of(x.elem(i,0)),
		b.m(),b.n()));
      } else {
	si.elem(0,0) = 0;
	if ((a.elem(1,0) != 0) && (retval.elem(i,0) != 0))
	  si.elem(0,0) ^=  a.alpha_to(modn(a.index_of(a.elem(1,0))+ 
		a.index_of(retval.elem(i,0)),a.m(),a.n()));
	if ((b.elem(1,0) != 0) && (x.elem(i,0) != 0))
	  si.elem(0,0) ^= b.alpha_to(modn(b.index_of(b.elem(1,0))+
		b.index_of(x.elem(i,0)),b.m(),b.n()));
      }
    }
  } else if (si.length() > 0) {
    for (int i = 0; i < x.length(); i++) {
      retval.elem(i,0) = si.elem(0,0);
      if ((b.elem(0,0) != 0) && (x.elem(i,0) != 0))
	retval.elem(i,0) ^= b.alpha_to(modn(b.index_of(b.elem(0,0)) + 
		b.index_of(x.elem(i,0)),b.m(),b.n()));
      if (si.length() > 1) {
	for (int j = 0; j < si.length() - 1; j++) {
	  si.elem(j,0) = si.elem(j+1,0);
	  if ((b.elem(j+1,0) != 0) && (x.elem(i,0) != 0))
	    si.elem(j,0) ^= b.alpha_to(modn(b.index_of(b.elem(j+1,0)) + 
		b.index_of(x.elem(i,0)),b.m(),b.n()));
	}
	si.elem(si.length()-1,0) = 0;
	if ((b.elem(si.length(),0) != 0) && (x.elem(i,0) != 0))
	  si.elem(si.length()-1,0) ^= b.alpha_to(modn(b.index_of(
		b.elem(si.length(),0)) + b.index_of(x.elem(i,0)),b.m(),b.n()));
      } else {
	si.elem(0,0) = 0;
	if ((b.elem(1,0) != 0) && (x.elem(i,0) != 0))
	  si.elem(0,0) ^= b.alpha_to(modn(b.index_of(b.elem(1,0)) + 
		b.index_of(x.elem(i,0)), b.m(), b.n()));
      }
    }
  } else
    for (int i=0; i<x.length(); i++)
      if ((b.elem(0,0) != 0) && (x.elem(i,0) != 0))
	retval.elem(i,0) = b.alpha_to(modn(b.index_of(b.elem(0,0)) + 
		b.index_of(x.elem(i,0)), b.m(),b.n()));

  return retval;
}


// PKG_ADD: dispatch filter gfilter galois
DEFUN_DLD (gfilter, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {y =} gfilter (@var{b}, @var{a}, @var{x})\n\
@deftypefnx {Loadable Function} {[@var{y}, @var{sf}] =} gfilter (@var{b}, @var{a}, @var{x}, @var{si})\n\
Return the solution to the following linear, time-invariant difference\n\
equation over a Galois Field:\n\
@iftex\n\
@tex\n\
$$\n\
\\sum_{k=0}^N a_{k+1} y_{n-k} = \\sum_{k=0}^M b_{k+1} x_{n-k}, \\qquad\n\
 1 \\le n \\le P\n\
$$\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
\n\
@smallexample\n\
   N                   M\n\
  SUM a(k+1) y(n-k) = SUM b(k+1) x(n-k)      for 1<=n<=length(x)\n\
  k=0                 k=0\n\
@end smallexample\n\
@end ifinfo\n\
\n\
@noindent\n\
where\n\
@ifinfo\n\
 N=length(a)-1 and M=length(b)-1.\n\
@end ifinfo\n\
@iftex\n\
@tex\n\
 $a \\in \\Re^{N-1}$, $b \\in \\Re^{M-1}$, and $x \\in \\Re^P$.\n\
@end tex\n\
@end iftex\n\
An equivalent form of this equation is:\n\
@iftex\n\
@tex\n\
$$\n\
y_n = -\\sum_{k=1}^N c_{k+1} y_{n-k} + \\sum_{k=0}^M d_{k+1} x_{n-k}, \\qquad\n\
 1 \\le n \\le P\n\
$$\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
\n\
@smallexample\n\
            N                   M\n\
  y(n) = - SUM c(k+1) y(n-k) + SUM d(k+1) x(n-k)  for 1<=n<=length(x)\n\
           k=1                 k=0\n\
@end smallexample\n\
@end ifinfo\n\
\n\
@noindent\n\
where\n\
@ifinfo\n\
 c = a/a(1) and d = b/a(1).\n\
@end ifinfo\n\
@iftex\n\
@tex\n\
$c = a/a_1$ and $d = b/a_1$.\n\
@end tex\n\
@end iftex\n\
\n\
If the fourth argument @var{si} is provided, it is taken as the\n\
initial state of the system and the final state is returned as\n\
@var{sf}.  The state vector is a column vector whose length is\n\
equal to the length of the longest coefficient vector minus one.\n\
If @var{si} is not supplied, the initial state vector is set to all\n\
zeros.\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin  = args.length ();

  if (nargin < 3 || nargin > 4) {
    print_usage ("gfilter");
    return retval;
  }

  if (!galois_type_loaded) {
    error ("gfilter: wrong argument types");
    return retval;
  }

  bool x_is_row_vector = (args(2).rows () == 1);
  bool si_is_row_vector = (nargin == 4 && args(3).rows () == 1);
  galois b, a, x, si;
  bool ib=false, ia=false, ix = false, isi=false;

  if (args(0).type_id () == octave_galois::static_type_id ()) {
    b = ((const octave_galois&) args(0).get_rep()).galois_value ();
    ib = true;
  }
  if (args(1).type_id () == octave_galois::static_type_id ()) {
    a = ((const octave_galois&) args(1).get_rep()).galois_value ();
    ia = true;
  }
  if (args(2).type_id () == octave_galois::static_type_id ()) {
    x = ((const octave_galois&) args(2).get_rep()).galois_value ();
    ix = true;
  }
  if (nargin == 4) {
    if (args(3).type_id () == octave_galois::static_type_id ()) {
      si = ((const octave_galois&) args(3).get_rep()).galois_value ();
      isi = true;
    }
  }

  if (!ib && !ia && !ix && !isi) {
    error ("gfilter: wrong argument types");
    return retval;
  }

  if (!ib) {
    if (ia)
      b = galois(args(0).matrix_value(), a.m(), a.primpoly());
     else if (ix)
      b = galois(args(0).matrix_value(), x.m(), x.primpoly());
    else if (isi)
      b = galois(args(0).matrix_value(), si.m(), si.primpoly());
  }
  if (!ia)
    a =  galois(args(1).matrix_value(), b.m(), b.primpoly());
  if (!ix)
    x =  galois(args(2).matrix_value(), b.m(), b.primpoly());
  
  if (nargin == 4) {
    if (!isi)
      si =  galois(args(3).matrix_value(), b.m(), b.primpoly());
  } else {
    int a_len = a.length ();
    int b_len = b.length ();

    int si_len = (a_len > b_len ? a_len : b_len) - 1;
	  
    si = galois(si_len, 1, 0, b.m(), b.primpoly());
  }

  if ((b.m() != a.m()) || (b.m() != x.m()) || (b.m() != si.m()) ||
      (b.primpoly() != a.primpoly()) || (b.primpoly() != x.primpoly()) || 
      (b.primpoly() != si.primpoly())) {
    error("gfilter: arguments must be in same galois field");
    return retval;
  }

  if (b.cols() > 1)
    b = b.transpose();
  if (a.cols() > 1)
    a = a.transpose();
  if (x.cols() > 1)
    x = x.transpose();
  if (si.cols() > 1)
    si = si.transpose();

  if (b.cols() > 1 || a.cols() > 1 || x.cols() > 1 || si.cols() > 1) {
    error ("gfilter: arguments must be vectors");
    return retval;
  }

  galois y (filter (b, a, x, si));
  if (nargout == 2) {
    if (si_is_row_vector)
      retval(1) = new octave_galois (si.transpose ());
    else
      retval(1) = new octave_galois (si);
  }
	  
  if (x_is_row_vector)
    retval(0) = new octave_galois (y.transpose ());
  else
    retval(0) = new octave_galois (y);

  return retval;
}

// PKG_ADD: dispatch lu glu galois
DEFUN_DLD (glu, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{l}, @var{u}, @var{p}] =} glu (@var{a})\n\
@cindex LU decomposition of Galois matrix\n\
Compute the LU decomposition of @var{a}, The result is returned in a\n\
permuted form, according to the optional return value @var{p}.  For\n\
example, given the matrix\n\
@code{a = gf([1, 2; 3, 4],3)},\n\
\n\
@example\n\
[l, u, p] = lu (a)\n\
@end example\n\
\n\
@noindent\n\
returns\n\
\n\
@example\n\
l =\n\
\n\
  1  0\n\
  6  1\n\
\n\
u =\n\
\n\
  3  4\n\
  0  7\n\
\n\
p =\n\
\n\
  0  1\n\
  1  0\n\
@end example\n\
\n\
Such that @code{@var{p} * @var{a} = @var{l} * @var{u}}. If the argument\n\
@var{p} is not included then the permutations are applied to @var{l}\n\
so that @code{@var{a} = @var{l} * @var{u}}. @var{l} is then a pseudo-\n\
lower triangular matrix. The matrix @var{a} can be rectangular.\n\
@end deftypefn")
{
  octave_value_list retval;
  

  int nargin = args.length ();

  if (nargin != 1 || nargout > 3)
    {
      print_usage ("glu");
      return retval;
    }

  octave_value arg = args(0);

  if (!galois_type_loaded || (arg.type_id () != 
			      octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("glu", arg);
    return retval;
  }

  galois m = ((const octave_galois&) arg.get_rep()).galois_value ();

  int nr = arg.rows ();
  int nc = arg.columns ();

  int arg_is_empty = empty_arg ("glu", nr, nc);

  if (arg_is_empty < 0)
    return retval;
  else if (arg_is_empty > 0) {
    retval(0) = new octave_galois (galois(0, 0, 0, m.m(), m.primpoly()));
    retval(1) = new octave_galois (galois(0, 0, 0, m.m(), m.primpoly()));
    retval(2) = new octave_galois (galois(0, 0, 0, m.m(), m.primpoly()));
    return retval;
  }

  if (! error_state) {
    LU fact (m);

    switch (nargout) {
    case 0:
    case 1:
    case 2:
      {
	Matrix P = fact.P ();
	galois L = P.transpose () * fact.L ();
	retval(1) = new octave_galois (fact.U ());
	retval(0) = new octave_galois (L);
      }
      break;
	    
    case 3:
    default:
      retval(2) = fact.P ();
      retval(1) = new octave_galois (fact.U ());
      retval(0) = new octave_galois (fact.L ());
      break;
    }
  }
  
  return retval;
}

// PKG_ADD: dispatch inv ginv galois
DEFUN_DLD (ginv, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{x}, @var{rcond}] = } ginv (@var{a})\n\
Compute the inverse of the square matrix @var{a}.  Return an estimate\n\
of the reciprocal condition number if requested, otherwise warn of an\n\
ill-conditioned matrix if the reciprocal condition number is small.\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin != 1)
    {
      print_usage ("ginv");
      return retval;
    }

  octave_value arg = args(0);

  int nr = arg.rows ();
  int nc = arg.columns ();

  if (!galois_type_loaded || (arg.type_id () != 
			      octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("ginverse", arg);
    return retval;
  }

  galois m = ((const octave_galois&) arg.get_rep()).galois_value ();

  int arg_is_empty = empty_arg ("ginverse", nr, nc);

  if (arg_is_empty < 0)
    return retval;
  else if (arg_is_empty > 0) {
    retval(0) = new octave_galois (galois(0, 0, 0, m.m(), m.primpoly())); 
    return retval;
  }
  if (nr != nc)
    {
      gripe_square_matrix_required ("ginverse");
      return retval;
    }

  if (! error_state)
    {
      int info;
      double rcond = 0.0;

      galois result = m.inverse (info, 1);

      if (nargout > 1)
	retval(1) = rcond;

      retval(0) = new octave_galois (result);

      if (nargout < 2 && info == -1)
	warning ("inverse: matrix singular to machine precision, rcond = %g", rcond);
    }

  return retval;
}

// XXX FIXME XXX -- this should really be done with an alias, but
// alias_builtin() won't do the right thing if we are actually using
// dynamic linking.

// PKG_ADD: dispatch inverse ginverse galois
DEFUN_DLD (ginverse, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} ginverse (@var{a})\n\
See ginv.\n\
@end deftypefn")
{
  return Fginv (args, nargout);
}

// PKG_ADD: dispatch det gdet galois
DEFUN_DLD (gdet, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{d} = } gdet (@var{a})\n\
Compute the determinant of the Galois array @var{a}.\n\
@end deftypefn")
{
  octave_value retval;

  int nargin = args.length ();

  if (nargin != 1) {
    print_usage ("gdet");
    return retval;
  }

  octave_value arg = args(0);

  if (!galois_type_loaded || (arg.type_id () != 
			      octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("gdet", arg);
    return retval;
  }

  int nr = arg.rows ();
  int nc = arg.columns ();

  galois m = ((const octave_galois&) arg.get_rep()).galois_value ();

  int arg_is_empty = empty_arg ("gdet", nr, nc);

  if (arg_is_empty < 0)
    return retval;
  else if (arg_is_empty > 0) {
    retval = new octave_galois (galois(1, 1, 1, m.m(), m.primpoly())); 
    return retval;
  }

  if (nr != nc) {
    gripe_square_matrix_required ("det");
    return retval;
  }

  retval = new octave_galois (m.determinant ());
  return retval;
}

// PKG_ADD: dispatch rank grank galois
DEFUN_DLD (grank, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{d} = } grank (@var{a})\n\
Compute the rank of the Galois array @var{a} using the LU factorization.\n\
@end deftypefn")
{
  octave_value retval;

  int nargin = args.length ();

  if (nargin != 1) {
    print_usage ("grank");
    return retval;
  }

  octave_value arg = args(0);

  if (!galois_type_loaded || (arg.type_id () != 
			      octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("grank", arg);
    return retval;
  }

  int nr = arg.rows ();
  int nc = arg.columns ();

  galois m = ((const octave_galois&) arg.get_rep()).galois_value ();

  int arg_is_empty = empty_arg ("grank", nr, nc);

  if (arg_is_empty > 0)
    retval = 0.0;
  else if (arg_is_empty == 0) {
    if (m.rows() < m.cols()) {
      // In under-determined systems use column pivoting in LU
      // factorization, so that rank is correctly calculated
      LU fact (m, LU::COL);
      retval = (double)fact.rank();
    } else {
      LU fact (m);
      retval = (double)fact.rank();
    }
  }
  return retval;
}

DEFUN_DLD (rsenc, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{code} = } rsenc (@var{msg},@var{n},@var{k})\n\
@deftypefnx {Loadable Function} {@var{code} =} rsenc (@var{msg},@var{n},@var{k},@var{g})\n\
@deftypefnx {Loadable Function} {@var{code} =} rsenc (@var{msg},@var{n},@var{k},@var{fcr},@var{prim})\n\
@deftypefnx {Loadable Function} {@var{code} =} rsenc (@var{...},@var{parpos})\n\
\n\
Encodes the message @var{msg} using a [@var{n},@var{k}] Reed-Solomon coding.\n\
The variable @var{msg} is a Galois array with @var{k} columns and an arbitrary\n\
number of rows. Each row of @var{msg} represents a single block to be coded\n\
by the Reed-Solomon coder. The coded message is returned in the Galois\n\
array @var{code} containing @var{n} columns and the same number of rows as\n\
@var{msg}.\n\
\n\
The use of @dfn{rsenc} can be seen in the following short example.\n\
\n\
@example\n\
m = 3; n = 2^m -1; k = 3;\n\
msg = gf([1 2 3; 4 5 6], m);\n\
code = rsenc(msg, n, k);\n\
@end example\n\
\n\
If @var{n} does not equal @code{2^@var{m}-1}, where m is an integer, then a\n\
shorten Reed-Solomon coding is used where zeros are added to the start of\n\
each row to obtain an allowable codeword length. The returned @var{code}\n\
has these prepending zeros stripped.\n\
\n\
By default the generator polynomial used in the Reed-Solomon coding is based\n\
on the properties of the Galois Field in which @var{msg} is given. This\n\
default generator polynomial can be overridden by a polynomial in @var{g}.\n\
Suitable generator polynomials can be constructed with @dfn{rsgenpoly}.\n\
@var{fcr} is an integer value, and it is taken to be the first consecutive\n\
root of the generator polynomial. The variable @var{prim} is then the\n\
primitive element used to construct the generator polynomial, such that\n\
@ifinfo\n\
\n\
@var{g} = (@var{x} - A^@var{b}) * (@var{x} - A^(@var{b}+@var{prim})) * ... * (@var{x} - A^(@var{b}+2*@var{t}*@var{prim}-1)).\n\
@end ifinfo\n\
@iftex\n\
@tex\n\
$g = (x - A^b) (x - A^{b+p})  \\cdots (x - A ^{b+2tp-1})$.\n\
@end tex\n\
@end iftex\n\
\n\
where @var{b} is equal to @code{@var{fcr} * @var{prim}}. By default @var{fcr}\n\
and @var{prim} are both 1.\n\
\n\
By default the parity symbols are placed at the end of the coded message.\n\
The variable @var{parpos} controls this positioning and can take the values\n\
'beginning' or 'end'.\n\
@end deftypefn\n\
@seealso{gf,rsdec,rsgenpoly}")
{
  octave_value retval;
  int nargin = args.length ();
  
  if ((nargin < 3) || (nargin > 5)) {
    print_usage ("rsenc");
    return retval;
  }

  if (!galois_type_loaded || (args(0).type_id () != 
			      octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("rsenc", args(0));
    return retval;
  }

  galois msg = ((const octave_galois&) args(0).get_rep()).galois_value ();
  int nsym = msg.rows();
  int primpoly = msg.primpoly();
  int n = args(1).nint_value();
  int k = args(2).nint_value();

  int m = 1;
  while (n > (1<<m))
    m++;
  int nn = (1<<m) - 1;

  if (msg.cols() != k) {
    error ("rsenc: message contains incorrect number of symbols");
    return retval;
  }

  if (msg.m() != m) {
    error ("rsenc: message in incorrect galois field for codeword length");
    return retval;
  }

  if ((n < 3) || (n < k) || (m > 16)) {
    error ("rsenc: invalid values of message and codeword length");
    return retval;
  }

  if ((n-k) & 1) {
    error ("rsenc: difference of message and codeword length must be even");
    return retval;
  }

  int nroots = n-k;
  galois genpoly;
  bool have_genpoly = false;
  bool parity_at_end = true;
  int fcr = 0;
  int prim = 0;

  for (int i = 3; i < 6; i++) {
    if (nargin > i) {
      if (args(i).is_string()) {
	std::string parstr = args(i).string_value();
	for (int j=0;j<(int)parstr.length();j++)
	  parstr[j] = toupper(parstr[j]);
	
	if (!parstr.compare("END")) {
	  parity_at_end = true;
        } else if (!parstr.compare("BEGINNING")) {
	  parity_at_end = false;
	} else {
	  error ("rsenc: unrecoginized parity position");
	  return retval;
	}
      } else {
	if (args(i).type_id () == octave_galois::static_type_id ()) {
	  if (have_genpoly) {
	    print_usage ("rsenc");
	    return retval;
	  }
	  genpoly = ((const octave_galois&) args(i).get_rep()).galois_value ();

	  if (genpoly.cols() > genpoly.rows())
	    genpoly = genpoly.transpose();
	} else {
	  if (have_genpoly) {
	    if (prim != 0) {
	      print_usage ("rsenc");
	      return retval;
	    }
	    prim = args(i).nint_value();
	  } else
	    fcr = args(i).nint_value();
	}
	have_genpoly = true;
      }
    }
  }

  if ((genpoly.rows() == 0) || (genpoly.cols() == 0)) {
    if (fcr == 0)
      fcr = 1;
    if (prim == 0)
      prim = 1;

    // Create polynomial of right length.
    genpoly = galois(nroots+1,1,0,m,primpoly);

    genpoly.elem(nroots,0) = 1;
    int i,root;
    for (i = 0,root=fcr*prim; i < nroots; i++,root += prim) {
      genpoly.elem(nroots-i-1,0) = 1;

      // Multiply genpoly by  @**(root + x)
      for (int j = i; j > 0; j--){
	int k = nroots - j;
	if (genpoly.elem(k,0) != 0)
	  genpoly.elem(k,0) = genpoly.elem(k+1,0) ^ genpoly.alpha_to(
		modn(genpoly.index_of(genpoly.elem(k,0)) + root, m, n));
	else
	  genpoly.elem(k,0) = genpoly.elem(k+1,0);
      }
      // genpoly(nroots,0) can never be zero
      genpoly.elem(nroots,0) = genpoly.alpha_to(modn(genpoly.index_of(
			genpoly.elem(nroots,0)) + root, m, n));
    }

  } else {
    if (genpoly.cols() != 1) {
      error ("rsenc: the generator polynomial must be a vector");
      return retval;
    }

    if (genpoly.primpoly() != primpoly) {
      error ("rsenc: the generator polynomial must be same galois field as the message");
      return retval;
    }

    if (genpoly.rows() != nroots+1) {
      error ("rsenc: generator polynomial has incorrect order");
      return retval;
    }
  }

  int norm = genpoly.elem(0,0);

  // Take logarithm of generator polynomial, for faster coding
  for (int i = 0; i < nroots+1; i++)
    genpoly.elem(i,0) = genpoly.index_of(genpoly.elem(i,0));

  // Add space for parity block
  msg.resize(nsym,n,0);

  // The code below basically finds the parity bits by treating the 
  // message as a polynomial and dividing it by the generator polynomial.
  // The parity bits are then the remainder of this division. If the parity
  // is at the end the polynomial is treat MSB first, otherwise it is 
  // treated LSB first
  //
  // This code could just as easily be written as 
  //    [ignore par] = gdeconv(msg, genpoly);
  // But the code below has the advantage of being 20 times faster :-)

  if (parity_at_end) {
    for (int l = 0; l < nsym; l++) {
      galois par(nroots,1,0,m,primpoly);
      for (int i = 0; i < k; i++) { 
	int feedback = par.index_of(par.elem(0,0) ^ msg.elem(l,i));
	if (feedback != nn) {
	  if (norm != 1)
	    feedback = modn(nn-genpoly.elem(0,0)+feedback, m, nn);
	  for (int j = 1; j < nroots; j++)
	    par.elem(j,0) ^= par.alpha_to(modn(feedback +
					       genpoly.elem(j,0), m, nn)); 
	}
	for (int j = 1; j < nroots; j++)
	  par.elem(j-1,0) = par.elem(j,0);
	if (feedback != nn)
	  par.elem(nroots-1,0) = par.alpha_to(modn(feedback+
					genpoly.elem(nroots,0), m, nn));
	else
	  par.elem(nroots-1,0) = 0;
      }
      for (int j = 0; j < nroots; j++)
	msg.elem(l,k+j) = par.elem(j,0);
    }
  } else {
    for (int l = 0; l < nsym; l++) {
      for (int i=k; i > 0; i--)
	msg(l,i+nroots-1) = msg(l,i-1);
      for (int i=0; i<nroots; i++)
	msg(l,i) = 0;
    }
    for (int l = 0; l < nsym; l++) {
      galois par(nroots,1,0,m,primpoly);
      for (int i = n; i > nroots; i--) { 
	int feedback = par.index_of(par.elem(0,0) ^ msg.elem(l,i-1));
	if (feedback != nn) {
	  if (norm != 1)
	    feedback = modn(nn-genpoly.elem(0,0)+feedback, m, nn);
	  for (int j = 1; j < nroots; j++)
	    par.elem(j,0) ^= par.alpha_to(modn(feedback +
					       genpoly.elem(j,0), m, nn)); 
	}
	for (int j = 1; j < nroots; j++)
	  par.elem(j-1,0) = par.elem(j,0);
	if (feedback != nn)
	  par.elem(nroots-1,0) = par.alpha_to(modn(feedback+
					genpoly.elem(nroots,0), m, nn));
	else
	  par.elem(nroots-1,0) = 0;
      }
      for (int j = 0; j < nroots; j++)
	msg.elem(l,j) = par.elem(nroots-j-1,0);
    }
  }

  retval = new octave_galois (msg);

  return retval;
}

/* A modified version of code bearing the copyright
 *
 * Reed-Solomon encoder
 * Copyright 2002, Phil Karn, KA9Q
 * May be used under the terms of the GNU General Public License (GPL)
 *
 * is included below.
 */
int decode_rs(galois& data, const int prim, const int iprim, const int nroots,
	      const int fcr, const int drow, const bool msb_first)
{
  int deg_lambda, el, deg_omega;
  int i, j, r, k;
  int q,tmp,num1,num2,den,discr_r;
  int lambda[nroots+1], s[nroots];	/* Err Locator and syndrome poly */
  int b[nroots+1], t[nroots+1], omega[nroots+1];
  int root[nroots], reg[nroots+1], loc[nroots];
  int syn_error, count;
  int m = data.m();
  int n = data.n();
  int A0 = n;

  /* form the syndromes; i.e., evaluate data(x) at roots of g(x) */
  if (msb_first) {
    for(i=0;i<nroots;i++)
      s[i] = data.elem(drow,0);

    for(j=1;j<n;j++)
      for(i=0;i<nroots;i++)
	if(s[i] == 0)
	  s[i] = data.elem(drow,j);
	else
	  s[i] = data.elem(drow,j) ^ data.alpha_to(modn(data.index_of(s[i]) + 
					(fcr+i)*prim, m, n));
  } else {
    for(i=0;i<nroots;i++)
      s[i] = data.elem(drow,n-1);

    for(j=n-1;j>0;j--)
      for(i=0;i<nroots;i++)
	if(s[i] == 0)
	  s[i] = data.elem(drow,j-1);
	else 
	  s[i] = data.elem(drow,j-1) ^ data.alpha_to(modn(data.index_of(s[i]) +
					(fcr+i)*prim, m, n));
  }

  /* Convert syndromes to index form, checking for nonzero condition */
  syn_error = 0;
  for(i=0;i<nroots;i++){
    syn_error |= s[i];
    s[i] = data.index_of(s[i]);
  }

  if (!syn_error)
    /* if syndrome is zero, data(drow,:) is a codeword and there are no
     * errors to correct. So return data(drow,:) unmodified
     */
    return 0;

  memset(&lambda[1],0,nroots*sizeof(lambda[0]));
  lambda[0] = 1;

  for(i=0;i<nroots+1;i++)
    b[i] = data.index_of(lambda[i]);
  
  /*
   * Begin Berlekamp-Massey algorithm to determine error locator polynomial
   */
  r = 0;
  el = 0;
  while (++r <= nroots) {	/* r is the step number */
    /* Compute discrepancy at the r-th step in poly-form */
    discr_r = 0;
    for (i = 0; i < r; i++){
      if ((lambda[i] != 0) && (s[r-i-1] != A0)) {
	discr_r ^= data.alpha_to(modn(data.index_of(lambda[i]) + 
				      s[r-i-1], m, n));
      }
    }
    discr_r = data.index_of(discr_r);	/* Index form */
    if (discr_r == A0) {
      /* 2 lines below: B(x) <-- x*B(x) */
      memmove(&b[1],b,nroots*sizeof(b[0]));
      b[0] = A0;
    } else {
      /* 7 lines below: T(x) <-- lambda(x) - discr_r*x*b(x) */
      t[0] = lambda[0];
      for (i = 0 ; i < nroots; i++) {
	if(b[i] != A0)
	  t[i+1] = lambda[i+1] ^ data.alpha_to(modn(discr_r + b[i], m, n));
	else
	  t[i+1] = lambda[i+1];
      }
      if (2 * el <= r - 1) {
	el = r - el;
	/*
	 * 2 lines below: B(x) <-- inv(discr_r) *
	 * lambda(x)
	 */
	for (i = 0; i <= nroots; i++)
	  b[i] = (lambda[i] == 0) ? A0 : modn(data.index_of(lambda[i]) - 
					      discr_r + n, m, n);
      } else {
	/* 2 lines below: B(x) <-- x*B(x) */
	memmove(&b[1],b,nroots*sizeof(b[0]));
	b[0] = A0;
      }
      memcpy(lambda,t,(nroots+1)*sizeof(t[0]));
    }
  }

  /* Convert lambda to index form and compute deg(lambda(x)) */
  deg_lambda = 0;
  for(i=0;i<nroots+1;i++){
    lambda[i] = data.index_of(lambda[i]);
    if(lambda[i] != A0)
      deg_lambda = i;
  }

  /* Find roots of the error locator polynomial by Chien search */
  memcpy(&reg[1],&lambda[1],nroots*sizeof(reg[0]));
  count = 0;		/* Number of roots of lambda(x) */
  for (i = 1,k=iprim-1; i <= n; i++,k = modn(k+iprim, m, n)) {
    q = 1; /* lambda[0] is always 0 */
    for (j = deg_lambda; j > 0; j--){
      if (reg[j] != A0) {
	reg[j] = modn(reg[j] + j, m, n);
	q ^= data.alpha_to(reg[j]);
      }
    }
    if (q != 0)
      continue; /* Not a root */
    /* store root (index-form) and error location number */
    root[count] = i;
    loc[count] = k;
    /* If we've already found max possible roots,
     * abort the search to save time
     */
    if(++count == deg_lambda)
      break;
  }
  if (deg_lambda != count) {
    /*
     * deg(lambda) unequal to number of roots => uncorrectable
     * error detected
     */
    return -1;
  }
  /*
   * Compute err evaluator poly omega(x) = s(x)*lambda(x) (modulo
   * x**nroots). in index form. Also find deg(omega).
   */
  deg_omega = 0;
  for (i = 0; i < nroots;i++){
    tmp = 0;
    j = (deg_lambda < i) ? deg_lambda : i;
    for(;j >= 0; j--){
      if ((s[i - j] != A0) && (lambda[j] != A0))
	tmp ^= data.alpha_to(modn(s[i - j] + lambda[j], m, n));
    }
    if(tmp != 0)
      deg_omega = i;
    omega[i] = data.index_of(tmp);
  }
  omega[nroots] = A0;
  
  /*
   * Compute error values in poly-form. num1 = omega(inv(X(l))), num2 =
   * inv(X(l))**(fcr-1) and den = lambda_pr(inv(X(l))) all in poly-form
   */
  for (j = count-1; j >=0; j--) {
    num1 = 0;
    for (i = deg_omega; i >= 0; i--) {
      if (omega[i] != A0)
	num1  ^= data.alpha_to(modn(omega[i] + i * root[j], m, n));
    }
    num2 = data.alpha_to(modn(root[j] * (fcr - 1) + n, m, n));
    den = 0;
    
    /* lambda[i+1] for i even is the formal deriv lambda_pr of lambda[i] */
    for (i = (deg_lambda < nroots-1 ? deg_lambda : nroots-1) & ~1; i >= 0; 
	 i -=2) {
      if(lambda[i+1] != A0)
	den ^= data.alpha_to(modn(lambda[i+1] + i * root[j], m, n));
    }
    if (den == 0) {
      count = -1;
      break;
    }
    /* Apply error to data */
    if (num1 != 0) {
      if (msb_first)
	data(drow,loc[j]) ^= data.alpha_to(modn(data.index_of(num1) + 
			data.index_of(num2) + n - data.index_of(den), m, n));
      else
	data(drow,n-loc[j]-1) ^= data.alpha_to(modn(data.index_of(num1) + 
			data.index_of(num2) + n - data.index_of(den), m, n));
    }
  }

  return count;
}

DEFUN_DLD (rsdec, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{msg} = } rsdec (@var{code},@var{n},@var{k})\n\
@deftypefnx {Loadable Function} {@var{msg} =} rsdec (@var{code},@var{n},@var{k},@var{g})\n\
@deftypefnx {Loadable Function} {@var{msg} =} rsdec (@var{code},@var{n},@var{k},@var{fcr},@var{prim})\n\
@deftypefnx {Loadable Function} {@var{msg} =} rsdec (@var{...},@var{parpos})\n\
@deftypefnx {Loadable Function} {[@var{msg},@var{nerr}]=} rsdec (@var{...})\n\
@deftypefnx {Loadable Function} {[@var{msg},@var{nerr},@var{ccode}]=} rsdec (@var{...})\n\
\n\
Decodes the message contained in @var{code} using a [@var{n},@var{k}]\n\
Reed-Solomon code. The variable @var{code} must be a Galois array with\n\
@var{n} columns and an arbitrary number of rows. Each row of @var{code}\n\
represents a single block to be decoded by the Reed-Solomon coder. The\n\
decoded message is returned in the variable @var{msg} containing @var{k}\n\
columns and the same number of rows as @var{code}.\n\
\n\
If @var{n} does not equal @code{2^@var{m}-1}, where m is an integer, then a\n\
shorten Reed-Solomon decoding is used where zeros are added to the start of\n\
each row to obtain an allowable codeword length. The returned @var{msg}\n\
has these prepending zeros stripped.\n\
\n\
By default the generator polynomial used in the Reed-Solomon coding is based\n\
on the properties of the Galois Field in which @var{msg} is given. This\n\
default generator polynomial can be overridden by a polynomial in @var{g}.\n\
Suitable generator polynomials can be constructed with @dfn{rsgenpoly}.\n\
@var{fcr} is an integer value, and it is taken to be the first consecutive\n\
root of the generator polynomial. The variable @var{prim} is then the\n\
primitive element used to construct the generator polynomial. By default\n\
@var{fcr} and @var{prim} are both 1. It is significantly faster to specify\n\
the generator polynomial in terms of @var{fcr} and @var{prim}, since @var{g}\n\
is converted to this form in any case.\n\
\n\
By default the parity symbols are placed at the end of the coded message.\n\
The variable @var{parpos} controls this positioning and can take the values\n\
'beginning' or 'end'. If the parity symbols are at the end, the message is\n\
treated with the most-significant symbol first, otherwise the message is\n\
treated with the least-significant symbol first.\n\
@end deftypefn\n\
@seealso{gf,rsenc,rsgenpoly}")
{
  octave_value_list retval;

  int nargin = args.length ();
  
  if ((nargin < 3) || (nargin > 5)) {
    print_usage ("rsdec");
    return retval;
  }

  if (!galois_type_loaded || (args(0).type_id () != 
			      octave_galois::static_type_id ())) {
    gripe_wrong_type_arg ("rsdec", args(0));
    return retval;
  }

  galois code = ((const octave_galois&) args(0).get_rep()).galois_value ();
  int nsym = code.rows();
  int primpoly = code.primpoly();
  int n = args(1).nint_value();
  int k = args(2).nint_value();

  int m = 1;
  while (n > (1<<m))
    m++;
  int nn = (1<<m) - 1;

  if (code.cols() != n) {
    error ("rsdec: coded message contains incorrect number of symbols");
    return retval;
  }

  if (code.m() != m) {
    error ("rsdec: coded message in incorrect galois field for codeword length");
    return retval;
  }

  if ((n < 3) || (n < k) || (m > 16)) {
    error ("rsdec: invalid values of message and codeword length");
    return retval;
  }

  if ((n-k) & 1) {
    error ("rsdec: difference of message and codeword length must be even");
    return retval;
  }

  int nroots = n-k;
  galois genpoly;
  bool have_genpoly = false;
  bool parity_at_end = true;
  int fcr = 0;
  int prim = 0;
  int iprim;

  for (int i = 3; i < 6; i++) {
    if (nargin > i) {
      if (args(i).is_string()) {
	std::string parstr = args(i).string_value();
	for (int j=0;j<(int)parstr.length();j++)
	  parstr[j] = toupper(parstr[j]);
	
	if (!parstr.compare("END")) {
	  parity_at_end = true;
        } else if (!parstr.compare("BEGINNING")) {
	  parity_at_end = false;
	} else {
	  error ("rsdec: unrecoginized parrity position");
	  return retval;
	}
      } else {
	if (args(i).type_id () == octave_galois::static_type_id ()) {
	  if (have_genpoly) {
	    print_usage ("rsdec");
	    return retval;
	  }
	  genpoly = ((const octave_galois&) args(i).get_rep()).galois_value ();
	} else {
	  if (have_genpoly) {
	    if (prim != 0) {
	      print_usage ("rsdec");
	      return retval;
	    }
	    prim = args(i).nint_value();
	  } else
	    fcr = args(i).nint_value();
	}
	have_genpoly = true;
      }
    }
  }

  if (have_genpoly) {
    if (fcr != 0) {
      if ((fcr < 1) || (fcr > nn)) {
	error("rsdec: invalid first consecutive root of generator polynomial");
	return retval;
      }
      if ((prim < 1) || (prim > nn)) {
	error("rsdec: invalid primitive element of generator polynomial");
	return retval;
      }
    } else {
      if (genpoly.cols() > genpoly.rows())
	genpoly = genpoly.transpose();

      if (genpoly.cols() != 1) {
	error ("rsdec: the generator polynomial must be a vector");
	return retval;
      }

      if (genpoly.primpoly() != primpoly) {
	error ("rsdec: the generator polynomial must be same galois field as the message");
	return retval;
      }
      
      if (genpoly.rows() != nroots+1) {
	error ("rsdec: generator polynomial has incorrect order");
	return retval;
      }

      // Find the roots of the generator polynomial
      int roots[nroots], count = 0;
      for (int j=0; j <=nn; j++) {
	// Evaluate generator polynomial at j
	int val = genpoly.elem(0,0);
	int indx = genpoly.index_of(j);
	for (int i=0; i<nroots; i++) {
	  if (val == 0)
	    val = genpoly.elem(i+1,0);
	  else
	    val = genpoly.elem(i+1,0) ^ genpoly.alpha_to(modn(indx +
				genpoly.index_of(val), m, nn));
	}
	if (val == 0) {
	  roots[count] = j;
	  count++;
	  if (count == nroots)
	    break;
	}
      }

      if (count != nroots) {
	error ("rsenc: generator polynomial can not have repeated roots");
	return retval;
      }

      // Logarithm of roots wrt primitive element
      for (int i=0; i < count; i++)
	roots[i] = genpoly.index_of(roots[i]);

      // Find a corresponding fcr and prim that coincide with the roots.
      // XXX FIXME XXX. This is a naive algorithm and should be improved !!!
      bool found = true;
      for (fcr=1; fcr<n+1; fcr++) {
	for (prim=1; prim<n+1; prim++) {
	  found = true;
	  for (int i=0; i<nroots; i++) {
	    int tmp = modn((fcr + i)*prim, m, n);
	    for (int j=0; j<count; j++) {
	      if (tmp == roots[j]) {
		tmp = -1;
		break;
	      }
	    }
	    if (tmp != -1) {
	      found = false;
	      break;
	    }
	  }
	  if (found)
	    break;
	}
	if (found)
	  break;
      }
    }
  } else {
    fcr = 1;
    prim = 1;
  }
  
  /* Find prim-th root of 1, used in decoding */
  for(iprim=1;(iprim % prim) != 0;iprim += n)
    ;
  iprim = iprim / prim;
  
  galois msg(nsym,k,0,m,primpoly);
  ColumnVector nerr(nsym,0);

  if (nn != n) {
    code.resize(nsym,nn,0);
    if (parity_at_end) 
      for (int l = 0; l < nsym; l++)
	for (int i=n; i > 0; i--)
	  code.elem(l,i+nn-n-1) = code.elem(l,i-1);
  }

  for (int l = 0; l < nsym; l++)
    nerr(l) = decode_rs(code, prim, iprim, nroots, fcr, l, parity_at_end);

  if (nn != n) {
    if (parity_at_end) 
      for (int l = 0; l < nsym; l++)
	for (int i=0; i > n; i--)
	  code.elem(l,i) = code.elem(l,i+nn-n);
    code.resize(nsym,n,0);
  }

  if (parity_at_end) {
    for (int l = 0; l < nsym; l++)
      for (int i=0; i < k; i++)
	msg.elem(l,i) = code.elem(l,i);
  } else {
    for (int l = 0; l < nsym; l++)
      for (int i=0; i < k; i++)
	msg.elem(l,i) = code.elem(l,nroots+i);
  }

  retval(0) = new octave_galois (msg);
  retval(1) = octave_value(nerr);
  retval(2) = new octave_galois (code);

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
