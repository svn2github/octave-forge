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

*/

#include <iostream>
#include <iomanip>
#include <sstream>
#include <octave/oct.h>
#include <octave/pager.h>

static bool
do_is_cyclic_polynomial (const unsigned long long& a, const int& n, const int& m)
{
  // Fast return since polynomial can't be even
  if (!(a & 1))
    return false;

  unsigned long long mask = 1;

  for (int i=0; i<n; i++) {
    mask <<= 1;
    if (mask & ((unsigned long long)1<<m))
      mask ^= a;
  }

  if (mask != 1) {
    return false;
  }

  return true;
}

DEFUN_DLD (cyclgen, args, nargout,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {@var{h} =} cyclgen (@var{n},@var{p})\n"
"@deftypefnx {Loadable Function} {@var{h} =} cyclgen (@var{n},@var{p},@var{typ})\n"
"@deftypefnx {Loadable Function} {[@var{h}, @var{g}] =} cyclgen (@var{...})\n"
"@deftypefnx {Loadable Function} {[@var{h}, @var{g}, @var{k}] =} cyclgen (@var{...})\n"
"\n"
"Produce the parity check and generator matrix of a cyclic code. The parity\n"
"check matrix is returned as a @var{m} by @var{n} matrix, representing the\n"
"[@var{n},@var{k}] cyclic code. @var{m} is the order of the generator\n"
"polynomial @var{p} and the message length @var{k} is given by\n"
"@code{@var{n} - @var{m}}.\n"
"\n"
"The generator polynomial can either be a vector of ones and zeros,\n"
"and length @var{m} representing,\n"
"@iftex\n"
"@tex\n"
"$$ p_0 + p_1 x + p_2 x^2 + \\cdots + p_m x^{m-1} $$\n"
"@end tex\n"
"@end iftex\n"
"@ifinfo\n"
"\n"
"@example\n"
" @var{p}(1) + @var{p}(2) * x + @var{p}(3) * x^2 + ... + @var{p}(@var{m}) * x^(m-1)\n"
"@end example\n"
"@end ifinfo\n"
"\n"
"The terms of the polynomial are stored least-significant term first.\n"
"Alternatively, @var{p} can be an integer representation of the same\n"
"polynomial.\n"
"\n"
"The form of the parity check matrix is determined by @var{typ}. If\n"
" @var{typ} is 'system', a systematic parity check matrix is produced. If\n"
" @var{typ} is 'nosys' and non-systematic parity check matrix is produced.\n"
"\n"
"If requested @dfn{cyclgen} also returns the @var{k} by @var{n} generator\n"
"matrix @var{g}."
"\n"
"@end deftypefn\n"
"@seealso{hammgen,gen2par,cyclpoly}") 
{
  octave_value_list retval;
  int nargin = args.length ();
  int n = args(0).int_value ();
  unsigned long long p = 0;
  int m, k, mm;
  bool system = true;

  if ((nargin < 2) || (nargin > 3)) {
    error ("cyclgen: incorrect number of arguments");
    return retval;
  }

  m = 1;
  while (n > (1<<(m+1)))
    m++;

  if (n > (int)(sizeof(unsigned long long) << 3)) {
    error("cyclgen: codeword length must be less than %d", 
	  (sizeof(unsigned long long) << 3));
    return retval;
  }
  
  if (args(1).is_scalar_type ()) {
    p = (unsigned long long)(args(1).int_value());
    mm = 1;
    while (p > ((unsigned long long)1<<(mm+1)))
      mm++;
  } else {
    Matrix tmp = args(1).matrix_value ();
    if ((tmp.rows() != 1) && (tmp.columns() != 1)) {
      error ("cyclgen: generator polynomial must be a vector");
      return retval;
    }
    for (int i=0; i < tmp.rows(); i++)
      for (int j=0; j < tmp.columns(); j++) {
	if (tmp(i,j) == 1)
	  p |= ((unsigned long long)1 << (i+j));
	else if (tmp(i,j) != 0) {
	  error ("cyclgen: illegal generator polynomial");
	  return retval;
	}
      }
    mm = (tmp.rows() > tmp.columns() ? tmp.rows() : tmp.columns()) - 1;
  }
  k = n - mm;

  if (nargin > 2)
    if (args(2).is_string ()) {
      std::string s_arg = args(2).string_value ();

      if (s_arg == "system")
	system = true;
      else if (s_arg == "nosys")
	system = false;
      else {
	error ("cyclgen: illegal argument");
	return retval;
      }
    } else {
      error ("cyclgen: illegal argument");
      return retval;
    }

  // Haven't implemented this since I'm not sure what matlab wants here
  if (!system) {
    error ("cyclgen: non-systematic generator matrices not implemented");
    return retval;
  }

  if (!do_is_cyclic_polynomial(p, n, mm)) {
    error ("cyclgen: generator polynomial does not produce cyclic code");
    return retval;
  }

  unsigned long long mask = 1;
  unsigned long long *alpha_to = 
    (unsigned long long *)malloc(sizeof(unsigned long long) * n);
  for (int i = 0; i < n; i++) {
    alpha_to[i] = mask;
    mask <<= 1;
    if (mask & ((unsigned long long)1<<mm))
      mask ^= p;
  }

  Matrix parity(mm,n,0);
  for (int i = 0; i < n; i++) 
    for (int j = 0; j < mm; j++) 
      if (alpha_to[i] & ((unsigned long long)1<<j))
	parity(j,i) = 1;

  free(alpha_to);
  retval(0) = octave_value (parity);

  if (nargout > 1) {
    Matrix generator(k,n,0);

    for (int i = 0; i < (int)k; i++) 
      for (int j = 0; j < (int)mm; j++) 
	generator(i,j) = parity(j,i+mm);
    for (int i = 0; i < (int)k; i++) 
      generator(i,i+mm) = 1;

    retval(1) = octave_value(generator);
    retval(2) = octave_value((double)k);
  }
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
