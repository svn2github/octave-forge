/*

Copyright (C) 2011 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this software; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#include <iostream>
#include <iomanip>
#include <sstream>
#include <octave/oct.h>
#include <octave/pager.h>
#include <octave/quit.h>

static inline octave_idx_type 
modn(octave_idx_type x, octave_idx_type m, octave_idx_type n)
{
  while (x >= n)
    {
      x -= n;
      x = (x >> m) + (x & n);
    }
  return x;
}

DEFUN_DLD (__gmtimes__, args, nargout,
  "-*- texinfo -*-\n"
"@deftypefnx {Loadable Function} {@var{y} =} __mtimes__ (@var{a}, @var{b}, @var{m}, @var{alpha_to}, @var{index_of})\n"
"\n"
"Undocumented internal function\n"
"@end deftypefn")
{
  octave_value retval;

  int nargin  = args.length ();

  if (nargin != 5)
    {
      print_usage ();
      return retval;
    }

  const NDArray a = args(0).array_value();
  const NDArray b = args(1).array_value();
  octave_idx_type m = args(2).idx_type_value();
  octave_idx_type n =
    (static_cast<octave_idx_type>(1) << m) - static_cast<octave_idx_type>(1); 
  const Array<octave_idx_type> alpha_to =
    args(3).octave_idx_type_vector_value();
  const Array<octave_idx_type> index_of = 
    args(4).octave_idx_type_vector_value();

  octave_idx_type a_nr = a.rows();
  octave_idx_type a_nc = a.cols();
  octave_idx_type b_nr = b.rows();
  octave_idx_type b_nc = b.cols();

  if (a_nc != b_nr)
    {
      gripe_nonconformant ("operator *", a_nr, a_nc, b_nr, b_nc);
    }
  else
    {
      NDArray y(dim_vector(a_nr, b_nc), 0.0);
      if (a_nr != 0 && a_nc != 0 && b_nc != 0)
	{
	  // This is not optimum for referencing b, but can use vector
	  // to represent index(a(k,j)). Seems to be the fastest.
	  Array<octave_idx_type> c(dim_vector(a_nr, 1));
	  for (octave_idx_type j = 0; j < b_nr; j++) {
	    for (octave_idx_type k = 0; k < a_nr; k++) 
	      c.xelem(k) = index_of(static_cast<octave_idx_type>(a.xelem(k,j)));

	    for (octave_idx_type i = 0; i < b_nc; i++)
	      if (static_cast<octave_idx_type>(b(j,i)) != 0) 
		{
		  octave_idx_type tmp = index_of(static_cast<octave_idx_type>(b.xelem(j,i)));
		  for (octave_idx_type k = 0; k < a_nr; k++)
		    {
		      if (static_cast<octave_idx_type>(a.xelem(k,j)) != 0)
			y.xelem(k,i) = static_cast<octave_idx_type>(y.xelem(k,i)) ^ alpha_to(modn(tmp + c.xelem(k), m, n));
		    }
		}
	  }
	}
      retval = y;
    }

  return retval;
}
