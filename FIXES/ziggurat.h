/*
Copyright (C) 2004 David Bateman

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

This code is based on the paper Marsaglia and Tsang, "The ziggurat method
for generating random variables", Journ. Statistical Software. Code was
presented in this paper for a Ziggurat of 127 levels and using a 32 bit
integer random number generator. This version of the code, uses the Mersenne
Twister as the integer generator and uses 256 levels in the Ziggurat. This
has several advantages.

  1) As Marsaglia and Tsand themselves states, the more levels the few times
    the expensive tail algorithm must be called
  2) The cycle time of the generator is determined by the integer generator,
    thus the use of a Mersenne Twister for the core random generator makes
    this cycle extremely long.
  3) The license on the original code was unclear, thus rewriting the code 
    from the article means we are free of copyright issues.

It should be stated that the authors made my life easier, by the fact that
the algorithm developed in the text of the article is for a 256 level
ziggurat, even if the code itself isn't...

One modification to the algorithm developed in the article, is that it is
assumed that 0 <= x < Inf, and "unsigned long"s are used, thus resulting in
terms like 2^31 in the code. As the normal distribution is defined between
-Inf < x < Inf, we effectively only have 31 bit integers plus a sign. Thus
in Marsaglia and Tsang, 2^32 becomes 2^31. 

It appears that I'm about a fact of two slower than the code in the article,
this is partial due to a better generator of random integers than they use.
But might also be that the case of rapid return was optimized by inlining the
relevant code with a #define. As the basic Mersenne Twister is only 25% 
faster than this code I suspect that the main reason is just the use of
the Mersenne Twister and not the inline, so I'm not going to try and optimize
further.
*/

#ifndef ZIGGURAT_H
#define ZIGGURAT_H

#include "MersenneTwister.h"

#define ZIGGURAT_TABLE_SIZE 256
#define ZIGGURAT_R 3.6541528853610088
#define ZIGGURAT_INV_R 0.27366123732975828
#define TWO_TO_POWER_31 2147483648.0
#define SECTION_AREA 0.00492867323399

class Ziggurat 
{
 public:
  Ziggurat (void);
  Ziggurat (const MTRand::uint32& oneSeed);
  Ziggurat (MTRand::uint32 *const oneSeed);
  
  void seed (MTRand::uint32 oneSeed);
  void seed (MTRand::uint32 *const bigSeed);
  void seed (void);
  
  void save (MTRand::uint32 *saveArray) const;

  double operator () (void) { randExc(); };
  double randExc (void);
  
  // This should be private, but makes my life easier in do_seed
  MTRand Twist;

 private:
  void create_tables (void);

  // The tables describing the ziggurat, ki is stored as an integer and the
  // function evaluations are stored as suggested in the article
  MTRand::uint32 ki[ZIGGURAT_TABLE_SIZE];
  double wi[ZIGGURAT_TABLE_SIZE];
  double fi[ZIGGURAT_TABLE_SIZE];

};

inline Ziggurat::Ziggurat (void)
{
  create_tables ();
}

inline Ziggurat::Ziggurat (const MTRand::uint32 &oneSeed)
{
  Twist.seed (oneSeed);
  create_tables ();
}

inline Ziggurat::Ziggurat (MTRand::uint32 *const bigSeed)
{
  Twist.seed (bigSeed);
  create_tables ();
}

inline void Ziggurat::seed (MTRand::uint32 oneSeed)
{
  Twist.seed (oneSeed);
}

inline void Ziggurat::seed (MTRand::uint32 *const bigSeed)
{
  Twist.seed (bigSeed);
}

inline void Ziggurat::save (MTRand::uint32 *saveArray) const
{
  Twist.save (saveArray);
}

inline void Ziggurat::create_tables (void)
{
  double x, x1;
  
  x1 = ZIGGURAT_R;
  wi[255] = x1 / TWO_TO_POWER_31;
  fi[255] = exp (-0.5 * x1 * x1);

  /* Index zero is special for tail strip, where Marsaglia and Tsang defines
   * this as 
   * k_0 = 2^31 * r * f(r) / v, w_0 = 0.5^31 * v / f(r), f_0 = 1,
   * where v is the area of each strip of the ziggurat. 
   */
  ki[0] = (MTRand::uint32) (x1 * fi[255] / SECTION_AREA * TWO_TO_POWER_31);
  wi[0] = SECTION_AREA / fi[255] / TWO_TO_POWER_31;
  fi[0] = 1.;

  for (int i = 254; i > 0; i--)
    {
      /* New x is given by x = f^{-1}(v/x_{i+1} + f(x_{i+1})), thus
       * need inverse operator of y = exp(-0.5*x*x) -> x = sqrt(-2 ln(y))
       */
      x = sqrt(-2. * log(SECTION_AREA / x1 + fi[i+1]));
      ki[i+1] = (MTRand::uint32)(x / x1 * TWO_TO_POWER_31);
      wi[i] = x / TWO_TO_POWER_31;
      fi[i] = exp (-0.5 * x * x);
      x1 = x;
    }

  ki[1] = 0;
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

inline double Ziggurat::randExc (void)
{
  while (1)
    {
      long ri = (long) Twist.randInt();
      int idx = ri & 0xFF;
      double x = ri * wi[idx];
      if (abs(ri) < ki[idx])
	return x;		// 99.33% of the time we return here 1st try
      else if (idx == 0)
	{
	  /* As stated in Marsaglia and Tsang
	   * 
	   * For the normal tail, the method of Marsaglia[5] provides:
	   * generate x = -ln(U_1)/r, y = -ln(U_2), until y+y > x*x,
	   * the return r+x. Except that r+x is always in the positive 
	   * tail!!!! Any thing random might be used to determine the
	   * sign, but as we already have ri we might as well use it
	   */
	  double xx, yy;
	  do
	    {
	      xx = - ZIGGURAT_INV_R * log (Twist.randExc());
	      yy = - log (Twist.randExc());
	    } 
	  while ( yy+yy <= xx*xx);
	  return (ri < 0 ? -ZIGGURAT_R-xx : ZIGGURAT_R+xx);
	}
      else if ((fi[idx-1] - fi[idx]) * Twist.randExc() + fi[idx] < 
	       exp(-0.5*x*x))
	return x;
    }
}

#endif // ZIGGURAT_H

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
