/*

Copyright (C) 2004 Paul Kienzle

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

// Based on John Eaton's rand.cc and Dirk Eddelbuettel's randmt.cc
// Copyright (C) 1996, 1997 John W. Eaton
// Copyright (C) 1998, 1999 Dirk Eddelbuettel <edd@debian.org>
//
// $Id$

*/

#include <octave/oct.h>
#include <octave/lo-mappers.h>
#include <octave/lo-specfun.h>
#include <octave/lo-ieee.h>

#include "randmtzig.c"

// Octave interface starts here

static octave_value 
do_seed (octave_value_list args)
{
  octave_value retval;

  // Check if they said the magic words
  std::string s_arg = args(0).string_value ();
  if (s_arg == "seed")
    {
      // If they ask for the current "seed", then reseed with the next
      // available random number and return that.
      uint32_t a = randi32();
      init_by_int(a);
      retval = (double)a;
    }
  else if (s_arg == "state")
    {
      uint32_t state[MT_N+1];
      get_state(state);
      RowVector a(MT_N+1);
      for (int i=0; i < MT_N+1; i++)
	a(i) = double(state[i]);
      retval = a;
    }
  else
    {
      error ("rand: unrecognized string argument");
      return retval;
    }

  // Check if just getting state
  if (args.length() == 1)
    return retval;

  // Set the state from either a scalar or a previously returned state vector
  octave_value tmp = args(1);
  if (tmp.is_scalar_type ())
    {
      uint32_t n = (uint32_t)(tmp.double_value());
      if (! error_state)
	init_by_int(n);
    }
  else if (tmp.is_matrix_type () && (tmp.rows() == 1 || tmp.columns() == 1))
    {
      Array<double> a(tmp.vector_value ());
      if (! error_state)
	{
          const int input_len = a.length();
	  const int n = input_len < MT_N+1 ? input_len : MT_N+1;
	  uint32_t state[MT_N+1];
	  for (int i = 0; i < n; i++) 
	    state[i] = (uint32_t)a(i);
          if (input_len == MT_N+1 && state[MT_N] <= MT_N && state[MT_N] > 0)
            set_state (state);
          else
            init_by_array (state, n);
	}
    }
  else
    error ("rand: not a state vector");
  
  return retval;
}

#ifdef HAVE_ND_ARRAYS
static void
do_size(const char *fcn, octave_value_list args, dim_vector& dims)
{
  int nargin = args.length();
  if (nargin == 1)
    {
      get_dimensions(args(0),fcn,dims);
    }
  else
    {
      dims.resize (nargin);
      for (int i = 0; i < nargin; i++)
        {
          dims(i) = args(i).is_empty () ? 0 : args(i).nint_value ();
          if (error_state) return;
        }
    }
    
  int ndim = dims.length();
  while (ndim > 2 && dims(ndim-1) == 1) ndim--;
  dims.resize (ndim);
  check_dimensions (dims, fcn);
}
#else
static void
do_size(octave_value_list args, int& nr, int& nc)
{
  int nargin = args.length();

  if (nargin == 0)
    {
      nr = nc = 1;
    }
  else if (nargin == 1)
    {
      octave_value tmp = args(0);

      if (tmp.is_scalar_type ())
	{
	  double dval = tmp.double_value ();
	  
	  if (xisnan (dval))
	    {
	      error ("rand: NaN is invalid a matrix dimension");
	    }
	  else
	    {
	      nr = nc = NINT (tmp.double_value ());
	    }
	}
      else if (tmp.is_range ())
	{
	  Range rng = tmp.range_value ();
	  nr = 1;
	  nc = rng.nelem ();
	}
      else if (tmp.is_matrix_type ())
	{
	  // XXX FIXME XXX -- this should probably use the function
	  // from data.cc.

	  Matrix a = args(0).matrix_value ();

	  if (error_state)
	    return;
	  
	  nr = a.rows ();
	  nc = a.columns ();
	  
	  if (nr == 1 && nc == 2)
	    {
	      nr = NINT (a (0, 0));
	      nc = NINT (a (0, 1));
	    }
	  else if (nr == 2 && nc == 1)
	    {
	      nr = NINT (a (0, 0));
	      nc = NINT (a (1, 0));
	    }
	  else
	    warning ("rand (A): use rand (size (A)) instead");
	}
      else
	{
	  gripe_wrong_type_arg ("rand", tmp);
	}
    }
  else if (nargin == 2)
    {
      double rval = args(0).double_value ();
      double cval = args(1).double_value ();
      if (! error_state)
	{
	  if (xisnan (rval) || xisnan (cval))
	    {
	      error ("rand: NaN is invalid as a matrix dimension");
	    }
	  else
	    {
	      nr = NINT (rval);
	      nc = NINT (cval);
	    }
	}
    }
}
#endif

/*
%!test # 'state' can be a scalar
%! rand('state',12); x = rand(1,4);
%! rand('state',12); y = rand(1,4);
%! assert(x,y);
%!test # 'state' can be a vector
%! rand('state',[12,13]); x=rand(1,4);
%! rand('state',[12;13]); y=rand(1,4);
%! assert(x,y);
%!test # querying 'state' returns current state, not new state
%! s=rand('state');
%! t=rand('state',12);
%! assert(s,t);
%!test # querying 'state' doesn't disturb sequence
%! rand('state',12); rand(1,2); x=rand(1,2);
%! rand('state',12); rand(1,2);
%! s=rand('state'); y=rand(1,2);
%! assert(x,y);
%! rand('state',s); z=rand(1,2);
%! assert(x,z);
%!test # querying 'seed' returns a value which can be used later
%! s=rand('seed'); x=rand(1,2);
%! rand('seed',s); y=rand(1,2);
%! assert(x,y);
%!# querying 'seed' disturbs the sequence, so don't test that it doesn't
%!# XXX FIXME XXX tests of uniformity
*/

DEFUN_DLD (rand, args, nargout, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} rand (@var{x})\n\
@deftypefnx {Loadable Function} {} rand (@var{n}, @var{m})\n\
@deftypefnx {Loadable Function} {@var{v} =} rand (\"state\", @var{x})\n\
@deftypefnx {Loadable Function} {@var{s} =} rand (\"seed\", @var{x})\n\
Return a matrix with random elements uniformly distributed on the\n\
semi-open interval [0, 1).  The arguments are handled the same as the\n\
arguments for @code{eye}.\n\
\n\
You can query the state of the random number generator using the\n\
form\n\
\n\
@example\n\
v = rand (\"state\")\n\
@end example\n\
\n\
This returns a column vector @var{v} of length 625. Later, you can\n\
restore the random number generator to the state @var{v}\n\
using the form\n\
\n\
@example\n\
rand (\"state\", v)\n\
@end example\n\
\n\
@noindent\n\
You may also initialize the state vector from an arbitrary vector of\n\
length <= 624 for @var{v}.  This new state will be a hash based on the\n\
the value of @var{v}, not @var{v} itself.  The old state is returned.\n\
\n\
By default, the generator is initialized from /dev/urandom if it is\n\
available,otherwise from cpu time, wall clock time and the current\n\
fraction of a second.\n\
\n\
If instead of \"state\" you use \"seed\" to query the random\n\
number generator, then the state will be collapsed from roughly\n\
20000 bits down to 32 bits.  Unlike rand(\"state\") a call to rand(\"seed\")\n\
changes the state, so if you are trying to reproduce a simulation\n\
from a particular seed, be sure to include the same calls to\n\
rand(\"seed\") at the same point in the simulation.\n\
\n\
@code{rand} uses the Mersenne Twister, with a period of 2^19937-1.\n\
Do NOT use for CRYPTOGRAPHY without securely hashing several returned\n\
values together, otherwise the generator state can be learned after\n\
reading 624 consecutive values.\n\
\n\
M. Matsumoto and T. Nishimura, ``Mersenne Twister: A 623-dimensionally\n\
equidistributed uniform pseudorandom number generator'', ACM Trans. on\n\
Modeling and Computer Simulation Vol. 8, No. 1, Januray pp.3-30 1998\n\
\n\
http://www.math.keio.ac.jp/~matumoto/emt.html\n\
@end deftypefn\n\
@seealso{randn}\n")
{
  octave_value_list retval;	// list of return values

  int nargin = args.length ();	// number of arguments supplied

  if (nargin > 0 && args(0).is_string())
    retval(0) = do_seed (args);

  else
    {
#ifdef HAVE_ND_ARRAYS
      dim_vector dims;
      do_size ("rand", args, dims);
      if (error_state) return retval;
      int ndim = dims.length();
      switch (ndim)
        {
        case 0:
	  {
	    double v;
            fill_randu(1,&v);
            retval(0) = v;
	  }
	  break;
          
        case 1: case 2:
	  {
            Matrix X(dims(0),dims(ndim==1?0:1));
            fill_randu(X.capacity(),X.fortran_vec());
            retval(0) = X;
	  }
          break;
          
        default:
	  {
            NDArray Xn(dims);
            fill_randu(Xn.capacity(),Xn.fortran_vec());
            retval(0) = Xn;
	  }
          break;
        }
#else
      int nr=0, nc=0;
      do_size (args, nr, nc);

      if (! error_state)
	{
	  Matrix X(nr, nc);
          fill_randu(nr*nc,X.fortran_vec());
	  retval(0) = X;
        }
#endif
    }

  return retval;
}

DEFUN_DLD (randn, args, nargout, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} randn (@var{x})\n\
@deftypefnx {Loadable Function} {} randn (@var{n}, @var{m})\n\
@deftypefnx {Loadable Function} {@var{v} =} randn (\"state\", @var{x})\n\
@deftypefnx {Loadable Function} {@var{s} =} randn (\"seed\", @var{x})\n\
Return a matrix with normally distributed random elements.  The\n\
arguments are handled the same as the arguments for @code{rand}.\n\
\n\
@code{randn} uses a Marsaglia and Tsang[1] Ziggurat technique to\n\
transform from U to N(0,1). The technique uses a 256 level Ziggurat\n\
with the Mersenne Twister from @code{rand} used to generate U.\n\
\n\
[1] G. Marsaglia and W.W. Tsang, 'Ziggurat method for generating random\n\
variables', J. Statistical Software, vol 5, 2000\n\
(http://www.jstatsoft.org/v05/i08/)\n\
@end deftypefn\n\
@seealso{rand}\n")
{
  octave_value_list retval;	// list of return values

  int nargin = args.length ();	// number of arguments supplied

  if (nargin > 0 && args(0).is_string())
    retval(0) = do_seed (args);

  else
    {
#ifdef HAVE_ND_ARRAYS
      dim_vector dims;
      do_size ("randn", args, dims);
      if (error_state) return retval;
      int ndim = dims.length();
      switch (ndim)
        {
        case 0:
	  {
	    double v;
            fill_randn(1,&v);
            retval(0) = v;
	  }
          break;
          
        case 1: case 2:
	  {
            Matrix X(dims(0),dims(ndim==1?0:1));
            fill_randn(X.capacity(),X.fortran_vec());
            retval(0) = X;
	  }
          break;
          
        default:
	  {
            NDArray Xn(dims);
            fill_randn(Xn.capacity(),Xn.fortran_vec());
            retval(0) = Xn;
	  }
          break;
        }
#else
      int nr=0, nc=0;
      do_size (args, nr, nc);

      if (! error_state)
	{
	  Matrix X(nr, nc);
          fill_randn(nr*nc,X.fortran_vec());
	  retval(0) = X;
	}
#endif
    }

  return retval;
}

DEFUN_DLD (rande, args, nargout, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} rande (@var{x})\n\
@deftypefnx {Loadable Function} {} rande (@var{n}, @var{m})\n\
@deftypefnx {Loadable Function} {@var{v} =} rande (\"state\", @var{x})\n\
@deftypefnx {Loadable Function} {@var{s} =} rande (\"seed\", @var{x})\n\
Return a matrix with exponentially distributed random elements.  The\n\
arguments are handled the same as the arguments for @code{rand}.\n\
\n\
@code{rande} uses a Marsaglia and Tsang[1] Ziggurat technique to\n\
transform from U to E(0,1). The technique uses a 256 level Ziggurat\n\
with the Mersenne Twister from @code{rand} used to generate U.\n\
Exponential distributions with arbitrary @var{lambda} can be\n\
calculated by multiplying the the values returned by @code{rande}\n\
by @code{1/@var{lambda}}.\n\
\n\
[1] G. Marsaglia and W.W. Tsang, 'Ziggurat method for generating random\n\
variables', J. Statistical Software, vol 5, 2000\n\
(http://www.jstatsoft.org/v05/i08/)\n\
@end deftypefn\n\
@seealso{rand}\n")
{
  octave_value_list retval;	// list of return values

  int nargin = args.length ();	// number of arguments supplied

  if (nargin > 0 && args(0).is_string())
    retval(0) = do_seed (args);

  else
    {
#ifdef HAVE_ND_ARRAYS
      dim_vector dims;
      do_size ("rande", args, dims);
      if (error_state) return retval;
      int ndim = dims.length();
      switch (ndim)
        {
        case 0:
	  {
	    double v;
            fill_rande(1,&v);
            retval(0) = v;
	  }
          break;
          
        case 1: case 2:
	  {
            Matrix X(dims(0),dims(ndim==1?0:1));
            fill_rande(X.capacity(),X.fortran_vec());
            retval(0) = X;
	  }
          break;
          
        default:
	  {
            NDArray Xn(dims);
            fill_rande(Xn.capacity(),Xn.fortran_vec());
            retval(0) = Xn;
	  }
          break;
        }
#else
      int nr=0, nc=0;
      do_size (args, nr, nc);

      if (! error_state)
	{
	  Matrix X(nr, nc);
          fill_rande(nr*nc,X.fortran_vec());
	  retval(0) = X;
	}
#endif
    }

  return retval;
}

#define NAN octave_NaN
#define RUNI randu()
#define RNOR randn()
#define LGAMMA xlgamma
#include "randpoisson.c"

DEFUN_DLD (randp, args, nargout, 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} randp (@var{l})\n\
@deftypefnx {Loadable Function} {} randp (@var{l}, [@var{n}, @var{m}])\n\
@deftypefnx {Loadable Function} {} randp (@var{l}, @var{n}, @var{m})\n\
Return a matrix with Poisson distributed random elements.\n\
\n\
Five different algorithms are used depending on the range of @var{l}\n\
and whether or not @var{l} is a scalar or a matrix.\n\
\n\
For scalar @var{l} <= 12, use direct method.[1]\n\n\
For scalar @var{l} > 12, use rejection method.[1]\n\n\
For matrix @var{l} <= 10, use inversion method.[2]\n\n\
For matrix @var{l} > 10, use patchwork rejection method.[2,3]\n\n\
For @var{l} > 1e8, use normal approximation.[4]\n\
\n\
[1] Press, et al., 'Numerical Recipes in C', Cambridge University Press, 1992.\n\
\n\
[2] Stadlober E., et al., WinRand source code, available via FTP.\n\
\n\
[3] H. Zechner, 'Efficient sampling from continuous and discrete\n\
unimodal distributions', Doctoral Dissertaion, 156pp., Technical\n\
University Graz, Austria, 1994.\n\
\n\
[4] L. Montanet, et al., 'Review of Particle Properties', Physical Review\n\
D 50 p1284, 1994\n\
@end deftypefn\n\
@seealso{rand, randn, rande}\n")
{
  octave_value_list retval;	// list of return values

  int nargin = args.length ();	// number of arguments supplied
  if (nargin > 3 || nargin < 1) 
    {
      print_usage("randp");
      return retval;
    }

  Matrix lambda(args(0).matrix_value());
  if (error_state) return retval;

  int nr=0, nc=0;
  switch (nargin) {
  case 1: nr = lambda.rows(); nc = lambda.columns(); break;
  case 2: get_dimensions(args(1), "randp", nr, nc); break;
  case 3: get_dimensions(args(1), args(2), "randp", nr, nc); break;
  }

  if (error_state) return retval;

  if ( (nr != lambda.rows() && lambda.rows() != 1)
       || (nc != lambda.columns() && lambda.columns() != 1) )
    {
      error("randp: dimensions of lambda must match requested matrix size");
      return retval;
    }

  Matrix X(nr, nc);
  double *pX = X.fortran_vec();

  if (nr*nc > 1 && lambda.length()==1)
    {
      fill_randp(lambda(0,0), nr*nc, pX);
    }
  else
    {
      const double *pL = lambda.data();
      for (int i=nr*nc-1; i >= 0; i--) pX[i] = randp(pL[i]);
    }

  retval(0) = X;
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
