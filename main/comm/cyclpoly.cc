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

enum cyclic_poly_type
{
  CYCLIC_POLY_MIN=0,
  CYCLIC_POLY_MAX,
  CYCLIC_POLY_ALL,
  CYCLIC_POLY_L
};

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
    mask &= n;
  }

  if (mask != 1) {
    return false;
  }

  return true;
}


DEFUN_DLD (cyclpoly, args, nargout,
  "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {@var{y} =} cyclpoly (@var{n},@var{k})\n"
"@deftypefnx {Loadable Function} {@var{y} =} cyclpoly (@var{n},@var{k},@var{opt})\n"
"@deftypefnx {Loadable Function} {@var{y} =} cyclpoly (@var{n},@var{k},@var{opt},@var{rep})\n"
"\n"
"This function returns the cyclic generator polynomials of the code\n"
"[@var{n},@var{k}]. By default the the polynomial with the smallest\n"
"weight is returned. However this behavior can be overridden with the\n"
"@var{opt} flag. Valid values of @var{opt} are:\n"
"\n"
"@table @asis\n"
"@item 'all'\n"
"Returns all of the polynomials of the code [@var{n},@var{k}]\n"
"@item 'min'\n"
"Returns the polynomial of minimum weight of the code [@var{n},@var{k}]\n"
"@item 'max'\n"
"Returns the polynomial of the maximum weight of the code [@var{n},@var{k}]\n"
"@item @var{l}\n"
"Returns the polynomials having exactly the weight @var{l}\n"
"@end table\n"
"\n"
"The polynomials are returns as row-vectors in the variable @var{y}. Each\n"
"row of @var{y} represents a polynomial with the least-significant term\n"
"first. The polynomials can be returned with an integer representation\n"
"if @var{rep} is 'integer'. The default behaviour is given if @var{rep}\n"
"is 'polynomial'.\n"
"@end deftypefn\n"
"@seealso{gf,isprimitive}")
{
  octave_value retval;
  int nargin = args.length ();
  bool polyrep = true;
  enum cyclic_poly_type type = CYCLIC_POLY_MIN;
  RowVector cyclic_polys;
  int l=0;

  if ((nargin < 2) || (nargin > 4)) {
    error("cyclpoly: incorrect number of arguments");
    return retval;
  }

  int n = args(0).int_value();
  int k = args(1).int_value();;

  if (n < 1) {
    error("cyclpoly: n must be 1 or greater");
    return retval;
  }

  if (n <= k) {
    error("cyclpoly: k must be less than n");
    return retval;
  }

  for (int i = 2; i < nargin; i++) {
    if (args(i).is_scalar_type ()) {
      l = args(i).int_value();
      type = CYCLIC_POLY_L;
    } else if (args(i).is_string ()) {
      std::string s_arg = args(i).string_value ();

      if (s_arg == "integer")
	polyrep = false;
      else if (s_arg == "polynomial")
	polyrep = true;
      else if (s_arg == "min")
	type = CYCLIC_POLY_MIN;
      else if (s_arg == "max")
	type = CYCLIC_POLY_MAX;
      else if (s_arg == "all")
	type = CYCLIC_POLY_ALL;
      else {
	error ("cyclpoly: invalid argument");
	return retval;
      }
    } else {
      error ("cyclpoly: incorrect argument type");
      return retval;
    }
  }

  int m = n - k;

  // Matlab code seems to think that 1+x+x^3 is of larger weight than
  // 1+x^2+x^3. So for matlab compatiability the list of polynomials
  // should be reversed by replacing "i+=2" with "i-=2" and visa-versa. 
  // Thats not going to happen!!!

  switch (type) {
  case CYCLIC_POLY_MIN:
    cyclic_polys.resize(1);
    for (unsigned long long i = ((unsigned long long)1<<m)+1; i < ((unsigned long long)1<<(1+m)); i+=2)
      if (do_is_cyclic_polynomial(i, n, m)) {
	cyclic_polys(0) = (double)i;
	break;
      }
    break;
  case CYCLIC_POLY_MAX:
    cyclic_polys.resize(1);
    for (unsigned long long i = ((unsigned long long)1<<(m+1))-1; i > ((unsigned long long)1<<m); i-=2)
      if (do_is_cyclic_polynomial(i, n, m)) {
	cyclic_polys(0) = (double)i;
	break;
      }
    break;
  case CYCLIC_POLY_ALL:
    for (unsigned long long i = ((unsigned long long)1<<m)+1; i < ((unsigned long long)1<<(1+m)); i+=2)
      if (do_is_cyclic_polynomial(i, n, m)) {
	cyclic_polys.resize(cyclic_polys.length()+1);
	cyclic_polys(cyclic_polys.length()-1) = (double)i;
      }
    break;
  case CYCLIC_POLY_L:
    for (unsigned long long i = ((unsigned long long)1<<m)+1; i < ((unsigned long long)1<<(1+m)); i+=2) {
      int li = 0;
      for (int j=0; j < m+1; j++)
	if (i & ((unsigned long long)1 << j))
	  li++;
      if (li == l) {
	if (do_is_cyclic_polynomial(i, n, m)) {
	  cyclic_polys.resize(cyclic_polys.length()+1);
	  cyclic_polys(cyclic_polys.length()-1) = (double)i;
	}
      }
    }
    break;
  default:
    error("cyclpoly: impossible");
    break;
  }

  if (cyclic_polys.length() == 0) {
    octave_stdout << 
      "cyclpoly: no generator polynomial statifies constraints" << std::endl;
    retval = octave_value(Matrix(0,0));
  } else {
    if (polyrep) {
      Matrix polys(cyclic_polys.length(),m+1, 0);
      for (int i = 0 ; i < cyclic_polys.length(); i++)
	for (int j = 0; j < m+1; j++)
	  if ((unsigned long long)cyclic_polys(i) & (1<<j))
	    polys(i,j) = 1;
      retval = octave_value (polys);
    } else
      retval = octave_value (cyclic_polys);
  }

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
