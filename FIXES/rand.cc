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
// $Id$

#include <octave/oct.h>
#include <octave/lo-mappers.h>
#include "MersenneTwister.h"

static MTRand randu;

// The following routine to transform U(0,UINT_MAX) into N(0,1) is from 
// the GNU GPL'ed randlib library by Brown, Lovato, Russell and Venier 
// which is available from   ftp://odin.mdacc.tmc.edu/pub/source
double randn(void)
/*
**********************************************************************
                                                                      
                                                                      
     (STANDARD-)  N O R M A L  DISTRIBUTION                           
                                                                      
                                                                      
**********************************************************************
**********************************************************************
                                                                      
     FOR DETAILS SEE:                                                 
                                                                      
               AHRENS, J.H. AND DIETER, U.                            
               EXTENSIONS OF FORSYTHE'S METHOD FOR RANDOM             
               SAMPLING FROM THE NORMAL DISTRIBUTION.                 
               MATH. COMPUT., 27,124 (OCT. 1973), 927 - 937.          
                                                                      
     ALL STATEMENT NUMBERS CORRESPOND TO THE STEPS OF ALGORITHM 'FL'  
     (M=5) IN THE ABOVE PAPER     (SLIGHTLY MODIFIED IMPLEMENTATION)  
                                                                      
     Modified by Barry W. Brown, Feb 3, 1988 to use RANF instead of   
     SUNIF.  The argument IR thus goes away.                          

     Modified by Dirk Eddelbuettel <edd@debian.org> on 1 Aug 1999
     to use randu() instead of RANF

**********************************************************************
     THE DEFINITIONS OF THE CONSTANTS A(K), D(K), T(K) AND
     H(K) ARE ACCORDING TO THE ABOVEMENTIONED ARTICLE
*/
{
  const double a[32] = {
    0.0,3.917609E-2,7.841241E-2,0.11777,0.1573107,0.1970991,0.2372021,0.2776904,
    0.3186394,0.36013,0.4022501,0.4450965,0.4887764,0.5334097,0.5791322,
    0.626099,0.6744898,0.7245144,0.7764218,0.8305109,0.8871466,0.9467818,
    1.00999,1.077516,1.150349,1.229859,1.318011,1.417797,1.534121,1.67594,
    1.862732,2.153875
  };
  const double d[31] = {
    0.0,0.0,0.0,0.0,0.0,0.2636843,0.2425085,0.2255674,0.2116342,0.1999243,
    0.1899108,0.1812252,0.1736014,0.1668419,0.1607967,0.1553497,0.1504094,
    0.1459026,0.14177,0.1379632,0.1344418,0.1311722,0.128126,0.1252791,
    0.1226109,0.1201036,0.1177417,0.1155119,0.1134023,0.1114027,0.1095039
  };
  const double t[31] = {
    7.673828E-4,2.30687E-3,3.860618E-3,5.438454E-3,7.0507E-3,8.708396E-3,
    1.042357E-2,1.220953E-2,1.408125E-2,1.605579E-2,1.81529E-2,2.039573E-2,
    2.281177E-2,2.543407E-2,2.830296E-2,3.146822E-2,3.499233E-2,3.895483E-2,
    4.345878E-2,4.864035E-2,5.468334E-2,6.184222E-2,7.047983E-2,8.113195E-2,
    9.462444E-2,0.1123001,0.136498,0.1716886,0.2276241,0.330498,0.5847031
  };
  const double h[31] = {
    3.920617E-2,3.932705E-2,3.951E-2,3.975703E-2,4.007093E-2,4.045533E-2,
    4.091481E-2,4.145507E-2,4.208311E-2,4.280748E-2,4.363863E-2,4.458932E-2,
    4.567523E-2,4.691571E-2,4.833487E-2,4.996298E-2,5.183859E-2,5.401138E-2,
    5.654656E-2,5.95313E-2,6.308489E-2,6.737503E-2,7.264544E-2,7.926471E-2,
    8.781922E-2,9.930398E-2,0.11556,0.1404344,0.1836142,0.2790016,0.7010474
  };
  int i;
  double u, s, snorm, ustar, aa, w, y, tt;
  u = randu();
  s = 0.0;
  if(u > 0.5) s = 1.0;
  u += (u-s);
  u = 32.0*u;
  i = (int) (u);
  if(i == 32) i = 31;
  if(i == 0) goto S100;
  /*
    START CENTER
  */
  ustar = u-(double)i;
  aa = *(a+i-1);
 S40:
  if(ustar <= *(t+i-1)) goto S60;
  w = (ustar-*(t+i-1))**(h+i-1);
 S50:
  /*
    EXIT   (BOTH CASES)
  */
  y = aa+w;
  snorm = y;
  if(s == 1.0) snorm = -y;
  return snorm;
 S60:
  /*
    CENTER CONTINUED
  */
  u = randu();
  w = u*(*(a+i)-aa);
  tt = (0.5*w+aa)*w;
  goto S80;
 S70:
  tt = u;
  ustar = randu();
 S80:
  if(ustar > tt) goto S50;
  u = randu();
  if(ustar >= u) goto S70;
  ustar = randu();
  goto S40;
 S100:
  /*
    START TAIL
  */
  i = 6;
  aa = *(a+31);
  goto S120;
 S110:
  aa += *(d+i-1);
  i += 1;
 S120:
  u += u;
  if(u < 1.0) goto S110;
  u -= 1.0;
 S140:
  w = u**(d+i-1);
  tt = (0.5*w+aa)*w;
  goto S160;
 S150:
  tt = u;
 S160:
  ustar = randu();
  if(ustar > tt) goto S50;
  u = randu();
  if(ustar >= u) goto S150;
  u = randu();
  goto S140;
}


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
      // available random number
      MTRand::uint32 a = randu.randInt();
      randu.seed(a);
      retval = (double)a;
    }
  else if (s_arg == "state")
    {
      MTRand::uint32 state[randu.SAVE];
      randu.save(state);
      RowVector a(randu.SAVE);
      for (int i=0; i < randu.SAVE; i++)
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
	randu.seed(n);
    }
  else if (tmp.is_matrix_type () 
	   && tmp.rows() == randu.SAVE && tmp.columns() == 1)
    {
      Array<double> a(tmp.vector_value ());
      if (! error_state)
	{
	  MTRand::uint32 state[randu.SAVE];
	  for (int i = 0; i < randu.SAVE; i++)
	    state[i] = MTRand::uint32(a(i));
	  randu.load(state);
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
    retval(0) = do_seed (args);

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
@code{randn} uses Ahrens and Dieter (1973) to transform from U to N(0,1).\n\n\
@end deftypefn\n\
@seealso{rand}\n")
{
  octave_value_list retval;	// list of return values

  int nargin = args.length ();	// number of arguments supplied
  if (nargin > 2) 
    print_usage("randn");

  else if (nargin > 0 && args(0).is_string())
    retval(0) = do_seed (args);

  else
    {
      int nr=0, nc=0;
      do_size (args, nr, nc);

      if (! error_state)
	{
	  Matrix X(nr, nc);

	  for (int c=0; c < nc; c++)
	    for (int r=0; r < nr; r++)
	      X(r,c) = randn();
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
