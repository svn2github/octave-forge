/*

Copyright (C) 1996, 1997 John W. Eaton

This file is part of Octave.

Octave is free software; you can redistribute it and/or modify it
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

*/

// Octave modules for the Mersenne Twister (MT199337) Random Number Generator
// using Richard J. Wagner's C++ implementaion MersenneTwister.h
//
// This file provides two Octave functions:
//    rand		for Uniform random number
//    randn		for Normal random number
//
// Based on John Eaton's rand.cc and Dirk Eddelbuettel's randmt.cc
// Copyright (C) 1996, 1997 John W. Eaton
// Copyright (C) 1998, 1999 Dirk Eddelbuettel <edd@debian.org>
//
// 2001-02-10 Paul Kienzle
//   * use Richard J. Wagner's MersenneTwister.h
//   * use John Eaton's rand.cc for similar interface
//   * add rand("state") to obtain complete state
//   * renamed snorm to randn, and removed the `static' keyword from 
//     the variables in randu after thoroughly checking that they were
//     reset each time the function is entered.
//
// 2004-01-24 David Bateman
//   * The previous randn code was too costly. Replace with a simplier
//     and faster algorithm. The should be replaced with a Marsaglia 
//     Ziggurat algorithm eventually
// $Id$

#include <octave/oct.h>
#include <octave/lo-mappers.h>
#include "MersenneTwister.h"
#include "ziggurat.h"

static MTRand randu;
static Ziggurat randn;

static octave_value 
do_seed (octave_value_list args, MTRand rng)
{
  octave_value retval;

  // Check if they said the magic words
  std::string s_arg = args(0).string_value ();
  if (s_arg == "seed")
    {
      // If they ask for the current "seed", then reseed with the next
      // available random number
      MTRand::uint32 a = rng.randInt();
      rng.seed(a);
      retval = (double)a;
    }
  else if (s_arg == "state")
    {
      MTRand::uint32 state[rng.SAVE];
      rng.save(state);
      RowVector a(rng.SAVE);
      for (int i=0; i < rng.SAVE; i++)
	a(i) = state[i];
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
      MTRand::uint32 n = MTRand::uint32(tmp.double_value());
      if (! error_state)
	rng.seed(n);
    }
  else if (tmp.is_matrix_type () 
	   && tmp.rows() == rng.SAVE && tmp.columns() == 1)
    {
      Array<double> a(tmp.vector_value ());
      if (! error_state)
	{
	  MTRand::uint32 state[rng.SAVE];
	  for (int i = 0; i < rng.SAVE; i++)
	    state[i] = MTRand::uint32(a(i));
	  rng.load(state);
	}
    }
  else
    error ("rand: not a state vector");
  
  return retval;
}

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
You can reset the state of the random number generator using the\n\
form\n\
\n\
@example\n\
v = rand (\"state\", x)\n\
@end example\n\
\n\
where @var{x} is a scalar value.  This returns the current state\n\
of the random number generator in the column vector @var{v}.  If\n\
@var{x} is not given, then the state is returned but not changed.\n\
Later, you can restore the random number generator to the state @var{v}\n\
using the form\n\
\n\
@example\n\
u = rand (\"state\", v)\n\
@end example\n\
\n\
@noindent\n\
If instead of \"state\" you use \"seed\" to query the random\n\
number generator, then the state will be collapsed from roughly\n\
20000 bits down to 32 bits.\n\
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
  if (nargin > 2) 
    print_usage("rand");

  else if (nargin > 0 && args(0).is_string())
    retval(0) = do_seed (args, randu);

  else
    {
      int nr=0, nc=0;
      do_size (args, nr, nc);

      if (! error_state)
	{
	  Matrix X(nr, nc);

	  for (int c=0; c < nc; c++)
	    for (int r=0; r < nr; r++)
	      X(r,c) = randu.randExc();
	  retval(0) = X;
	}
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
@code{randn} uses a Marsaglia and Tsang[1] Ziggurat technique to
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
  if (nargin > 2) 
    print_usage("randn");

  else if (nargin > 0 && args(0).is_string())
    retval(0) = do_seed (args, randn.Twist);

  else
    {
      int nr=0, nc=0;
      do_size (args, nr, nc);

      if (! error_state)
	{
	  Matrix X(nr, nc);

	  for (int c=0; c < nc; c++)
	    for (int r=0; r < nr; r++)
	      X(r,c) = randn.randExc();
	  retval(0) = X;
	}
    }

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
