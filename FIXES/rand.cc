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

// Based on John Eaton's rand.cc and Dirk Eddelbuettel's randmt.cc and the Mersenne Twister
// Copyright (C) 1996, 1997 John W. Eaton
// Copyright (C) 1998, 1999 Dirk Eddelbuettel <edd@debian.org>
// Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
//
// $Id$

*/

#include <octave/oct.h>
#include <octave/lo-mappers.h>
#include <cmath>
#ifdef HAVE_GETTIMEOFDAY
#include <sys/time.h>
#endif

/* 
   A C-program for MT19937, with initialization improved 2002/2/10.
   Coded by Takuji Nishimura and Makoto Matsumoto.
   This is a faster version by taking Shawn Cokus's optimization,
   Matthe Bellew's simplification, Isaku Wada's real version.

   Before using, initialize the state by using init_genrand(seed) 
   or init_by_array(init_key, key_length).

   Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
   All rights reserved.                          

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

     1. Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.

     2. Redistributions in binary form must reproduce the above copyright
        notice, this list of conditions and the following disclaimer in the
        documentation and/or other materials provided with the distribution.

     3. The names of its contributors may not be used to endorse or promote 
        products derived from this software without specific prior written 
        permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


   Any feedback is very welcome.
   http://www.math.keio.ac.jp/matumoto/emt.html
   email: matumoto@math.keio.ac.jp

* 2004-01-19 Paul Kienzle
* * comment out main
* * add init_by_entropy, get_state, set_state
* * converted to allow compiling by C++ compiler
*
* 2004-01-25 David Bateman
* * Add Marsaglia and Tsang Ziggurat code
*/

/* Period parameters */  
#define N 624
#define M 397
#define MATRIX_A 0x9908b0dfUL   /* constant vector a */
#define UMASK 0x80000000UL /* most significant w-r bits */
#define LMASK 0x7fffffffUL /* least significant r bits */
#define MIXBITS(u,v) ( ((u) & UMASK) | ((v) & LMASK) )
#define TWIST(u,v) ((MIXBITS(u,v) >> 1) ^ ((v)&1UL ? MATRIX_A : 0UL))

/* Ziggurat parameters */
#define ZIGGURAT_TABLE_SIZE 256

#define ZIGGURAT_NOR_R 3.6541528853610088
#define ZIGGURAT_NOR_INV_R 0.27366123732975828
#define TWO_TO_POWER_31 2147483648.0
#define NOR_SECTION_AREA 0.00492867323399

#define ZIGGURAT_EXP_R 7.69711747013104972
#define ZIGGURAT_EXP_INV_R 0.129918765548341586
#define TWO_TO_POWER_32 4294967296.0
#define EXP_SECTION_AREA 0.0039496598225815571993

static unsigned long state[N]; /* the array for the state vector  */
static int left = 1;
static int initf = 0;
static int initt = 1;
static unsigned long *next;
static unsigned long ki[ZIGGURAT_TABLE_SIZE];
static double wi[ZIGGURAT_TABLE_SIZE], fi[ZIGGURAT_TABLE_SIZE];
static unsigned long ke[ZIGGURAT_TABLE_SIZE];
static double we[ZIGGURAT_TABLE_SIZE], fe[ZIGGURAT_TABLE_SIZE];

/* initializes state[N] with a seed */
void init_genrand(unsigned long s)
{
    int j;
    state[0]= s & 0xffffffffUL;
    for (j=1; j<N; j++) {
        state[j] = (1812433253UL * (state[j-1] ^ (state[j-1] >> 30)) + j); 
        /* See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier. */
        /* In the previous versions, MSBs of the seed affect   */
        /* only MSBs of the array state[].                        */
        /* 2002/01/09 modified by Makoto Matsumoto             */
        state[j] &= 0xffffffffUL;  /* for >32 bit machines */
    }
    left = 1; initf = 1;
}

/* initialize by an array with array-length */
/* init_key is the array for initializing keys */
/* key_length is its length */
void init_by_array(unsigned long init_key[], int key_length)
{
    int i, j, k;
    init_genrand(19650218UL);
    i=1; j=0;
    k = (N>key_length ? N : key_length);
    for (; k; k--) {
        state[i] = (state[i] ^ ((state[i-1] ^ (state[i-1] >> 30)) * 1664525UL))
          + init_key[j] + j; /* non linear */
        state[i] &= 0xffffffffUL; /* for WORDSIZE > 32 machines */
        i++; j++;
        if (i>=N) { state[0] = state[N-1]; i=1; }
        if (j>=key_length) j=0;
    }
    for (k=N-1; k; k--) {
        state[i] = (state[i] ^ ((state[i-1] ^ (state[i-1] >> 30)) * 1566083941UL))
          - i; /* non linear */
        state[i] &= 0xffffffffUL; /* for WORDSIZE > 32 machines */
        i++;
        if (i>=N) { state[0] = state[N-1]; i=1; }
    }

    state[0] = 0x80000000UL; /* MSB is 1; assuring non-zero initial array */ 
    left = 1; initf = 1;
}

void init_by_entropy(void)
{
    unsigned long entropy[N];
    int n = 0;

    /* Look for entropy in /dev/urandom */
    FILE* urandom =fopen("/dev/urandom", "rb");
    if (urandom) {
	while (n<N) {
	    unsigned char word[4];
	    if (fread(word, 4, 1, urandom) != 1) break;
	    entropy[n++] = word[0]+word[1]<<8+word[2]<<16+word[3]<<24;
	}
	fclose(urandom);
    }

    /* If there isn't enough entropy, gather some from various sources */
    if (n < N) entropy[n++] = time(NULL); /* Current time in seconds */
    if (n < N) entropy[n++] = clock();    /* CPU time used (usec) */
#ifdef HAVE_GETTIMEOFDAY
    if (n < N) {
	struct timeval tv;
	if (gettimeofday(&tv, NULL) != -1) {
	    entropy[n++] = tv.tv_usec;   /* Fractional part of current time */
	}
    }
#endif
    /* Other possibilities include 
     *     getrusage, getpid, getppid, getuid, getgid 
     * though the latter two clearly won't contribute much entropy.
     */

    /* Send all the entropy into the initial state vector */
    init_by_array(entropy,n);
}

void set_state(unsigned long save[])
{
    int i;
    for (i=0; i < N; i++) state[i] = save[i];
    left = save[N];
    next = state + (N-left+1);
}

void get_state(unsigned long save[])
{
    int i;
    for (i=0; i < N; i++) save[i] = state[i];
    save[N] = left;
}

static void next_state(void)
{
    unsigned long *p=state;
    int j;

    /* if init_genrand() has not been called, */
    /* a default initial seed is used         */
    /* if (initf==0) init_genrand(5489UL); */
    /* Or better yet, a random seed! */
    if (initf==0) init_by_entropy();

    left = N;
    next = state;
    
    for (j=N-M+1; --j; p++) 
        *p = p[M] ^ TWIST(p[0], p[1]);

    for (j=M; --j; p++) 
        *p = p[M-N] ^ TWIST(p[0], p[1]);

    *p = p[M-N] ^ TWIST(p[0], state[0]);
}

/* generates a random number on [0,0xffffffff]-interval */
inline unsigned long randi(void)
{
    unsigned long y;

    if (--left == 0) next_state();
    y = *next++;

    /* Tempering */
    y ^= (y >> 11);
    y ^= (y << 7) & 0x9d2c5680UL;
    y ^= (y << 15) & 0xefc60000UL;
    y ^= (y >> 18);

    return y;
}

/* generates a random number on (0,1)-real-interval */
inline double randu(void)
{
    return ((double)randi() + 0.5) * (1.0/4294967296.0); 
    /* divided by 2^32 */
}

/* generates a random number on [0,1) with 53-bit resolution*/
inline double rand53(void) 
{ 
    unsigned long a=randi()>>5, b=randi()>>6; 
    return(a*67108864.0+b)*(1.0/9007199254740992.0); 
} 


/*
This code is based on the paper Marsaglia and Tsang, "The ziggurat method
for generating random variables", Journ. Statistical Software. Code was
presented in this paper for a Ziggurat of 127 levels and using a 32 bit
integer random number generator. This version of the code, uses the 
Mersenne Twister as the integer generator and uses 256 levels in the 
Ziggurat. This has several advantages.

  1) As Marsaglia and Tsang themselves states, the more levels the few 
    times the expensive tail algorithm must be called
  2) The cycle time of the generator is determined by the integer 
    generator, thus the use of a Mersenne Twister for the core random 
    generator makes this cycle extremely long.
  3) The license on the original code was unclear, thus rewriting the code 
    from the article means we are free of copyright issues.

It should be stated that the authors made my life easier, by the fact that
the algorithm developed in the text of the article is for a 256 level
ziggurat, even if the code itself isn't...

One modification to the algorithm developed in the article, is that it is
assumed that 0 <= x < Inf, and "unsigned long"s are used, thus resulting in
terms like 2^32 in the code. As the normal distribution is defined between
-Inf < x < Inf, we effectively only have 31 bit integers plus a sign. Thus
in Marsaglia and Tsang, terms like 2^32 become 2^31. 

It appears that I'm slightly slower than the code in the article, this
is partially due to a better generator of random integers than they
use. But might also be that the case of rapid return was optimized by
inlining the relevant code with a #define. As the basic Mersenne
Twister is only 25% faster than this code I suspect that the main
reason is just the use of the Mersenne Twister and not the inlining,
so I'm not going to try and optimize further.
*/
inline void create_ziggurat_tables (void)
{
  double x, x1;
 
  // Ziggurat tables for the normal distribution
  x1 = ZIGGURAT_NOR_R;
  wi[255] = x1 / TWO_TO_POWER_31;
  fi[255] = exp (-0.5 * x1 * x1);

  /* Index zero is special for tail strip, where Marsaglia and Tsang 
   * defines this as 
   * k_0 = 2^31 * r * f(r) / v, w_0 = 0.5^31 * v / f(r), f_0 = 1,
   * where v is the area of each strip of the ziggurat. 
   */
  ki[0] = (unsigned long int) (x1 * fi[255] / NOR_SECTION_AREA * 
			       TWO_TO_POWER_31);
  wi[0] = NOR_SECTION_AREA / fi[255] / TWO_TO_POWER_31;
  fi[0] = 1.;

  for (int i = 254; i > 0; i--)
    {
      /* New x is given by x = f^{-1}(v/x_{i+1} + f(x_{i+1})), thus
       * need inverse operator of y = exp(-0.5*x*x) -> x = sqrt(-2*ln(y))
       */
      x = sqrt(-2. * log(NOR_SECTION_AREA / x1 + fi[i+1]));
      ki[i+1] = (unsigned long int)(x / x1 * TWO_TO_POWER_31);
      wi[i] = x / TWO_TO_POWER_31;
      fi[i] = exp (-0.5 * x * x);
      x1 = x;
    }

  ki[1] = 0;

  // Zigurrat tables for the exponential distribution
  x1 = ZIGGURAT_EXP_R;
  we[255] = x1 / TWO_TO_POWER_32;
  fe[255] = exp (-x1);

  /* Index zero is special for tail strip, where Marsaglia and Tsang 
   * defines this as 
   * k_0 = 2^32 * r * f(r) / v, w_0 = 0.5^32 * v / f(r), f_0 = 1,
   * where v is the area of each strip of the ziggurat. 
   */
  ke[0] = (unsigned long int) (x1 * fe[255] / EXP_SECTION_AREA * 
			       TWO_TO_POWER_32);
  we[0] = EXP_SECTION_AREA / fe[255] / TWO_TO_POWER_32;
  fe[0] = 1.;

  for (int i = 254; i > 0; i--)
    {
      /* New x is given by x = f^{-1}(v/x_{i+1} + f(x_{i+1})), thus
       * need inverse operator of y = exp(-x) -> x = -ln(y)
       */
      x = - log(EXP_SECTION_AREA / x1 + fe[i+1]);
      ke[i+1] = (unsigned long int)(x / x1 * TWO_TO_POWER_32);
      we[i] = x / TWO_TO_POWER_32;
      fe[i] = exp (-x);
      x1 = x;
    }
  ke[1] = 0;

  initt = 0;
}

/*
 * Here is the guts of the algorithm. As Marsaglia and Tsang state the
 * algorithm in their paper
 *
 * 1) Calculate a 32-bit random signed integer j and let i be the index
 *     provided by the rightmost 8-bits of j
 * 2) Set x = j * w_i. If j < k_i return x
 * 3) If i = 0, then return x from the tail
 * 4) If [f(x_{i-1}) - f(x_i)] * U < f(x) - f(x_i), return x
 * 5) goto step 1
 *
 * Where f is the functional form of the distribution, which for a normal
 * distribution is exp(-0.5*x*x)
 */
inline double randn (void)
{
  if (initt) create_ziggurat_tables();
  while (1)
    {
      long ri = (signed long) randi ();
#if SIZEOF_LONG > 4
      if (ri > 2147483647) ri-=4294967296;
#endif
      const int idx = ri & 0xFF;
      const double x = ri * wi[idx];
      if (abs(ri) < ki[idx])
	return x;		// 99.3% of the time we return here 1st try
      else if (idx == 0)
	{
	  /* As stated in Marsaglia and Tsang
	   * 
	   * For the normal tail, the method of Marsaglia[5] provides:
	   * generate x = -ln(U_1)/r, y = -ln(U_2), until y+y > x*x,
	   * then return r+x. Except that r+x is always in the positive 
	   * tail!!!! Any thing random might be used to determine the
	   * sign, but as we already have ri we might as well use it
	   */
	  double xx, yy;
	  do
	    {
	      xx = - ZIGGURAT_NOR_INV_R * log (randu());
	      yy = - log (randu());
	    } 
	  while ( yy+yy <= xx*xx);
	  return (ri < 0 ? -ZIGGURAT_NOR_R-xx : ZIGGURAT_NOR_R+xx);
	}
      else if ((fi[idx-1] - fi[idx]) * randu() + fi[idx] < 
	       exp(-0.5*x*x))
	return x;
    }
}

inline double rande (void)
{
  if (initt) create_ziggurat_tables();
  while (1)
    {
      unsigned long ri = randi ();
      const int idx = ri & 0xFF;
      const double x = ri * we[idx];
      if (ri < ke[idx])
	return x;		// 98.9% of the time we return here 1st try
      else if (idx == 0)
	{
	  /* As stated in Marsaglia and Tsang
	   * 
	   * For the exponential tail, the method of Marsaglia[5] provides:
           * x = r - ln(U);
	   */
	  return ZIGGURAT_NOR_R - log(randu());
	}
      else if ((fe[idx-1] - fe[idx]) * randu() + fe[idx] < exp(-x))
	return x;
    }
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
      unsigned long a = randi();
      init_genrand(a);
      retval = (double)a;
    }
  else if (s_arg == "state")
    {
      unsigned long state[N+1];
      get_state(state);
      RowVector a(N+1);
      for (int i=0; i < N+1; i++)
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
      unsigned long n = (unsigned long)(tmp.double_value());
      if (! error_state)
	init_genrand(n);
    }
  else if (tmp.is_matrix_type () && (tmp.rows() == 1 || tmp.columns() == 1))
    {
      Array<double> a(tmp.vector_value ());
      if (! error_state)
	{
          const int input_len = a.length();
	  const int n = input_len < N+1 ? input_len : N+1;
	  unsigned long state[N+1];
	  for (int i = 0; i < n; i++)
            {
	      state[i] = (unsigned long)a(i);
            }
          if (input_len == N+1 && state[N] <= N && state[N] > 0)
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

void fill_randu(int n, double *p)
{
  for (int i=0; i < n; i++) p[i] = randu();
}

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
%!# querying 'seed' disturbs the sequence, so don't try it
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

void fill_randn(int n, double *p)
{
  for (int i=0; i < n; i++) p[i] = randn();
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

void fill_rande(int n, double *p)
{
  for (int i=0; i < n; i++) p[i] = rande();
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

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
