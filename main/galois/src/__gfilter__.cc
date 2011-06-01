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

DEFUN_DLD (__gfilter__, args, nargout,
  "-*- texinfo -*-\n"
"@deftypefnx {Loadable Function} {[@var{y}, @var{sf}] =} __gfilter__ (@var{b}, @var{a}, @var{x}, @var{si}, @var{m}, @var{alpha_to}, @var{index_of})\n"
"\n"
"Undocumented internal function\n"
"@end deftypefn")
{
  octave_value_list retval;

  int nargin  = args.length ();

  if (nargin != 7)
    {
      print_usage ();
      return retval;
    }

  Array<octave_idx_type> b = args(0).octave_idx_type_vector_value();
  Array<octave_idx_type> a = args(1).octave_idx_type_vector_value();
  Array<octave_idx_type> x = args(2).octave_idx_type_vector_value();
  Array<octave_idx_type> si = args(3).octave_idx_type_vector_value();
  octave_idx_type m = args(4).idx_type_value();
  octave_idx_type n = (static_cast<octave_idx_type>(1) << m) - static_cast<octave_idx_type>(1); 
  Array<octave_idx_type> alpha_to = args(5).octave_idx_type_vector_value();
  Array<octave_idx_type> index_of = args(6).octave_idx_type_vector_value();
  octave_idx_type ab_len = (a.length() > b.length() ? a.length() : b.length());
  Array<octave_idx_type> y (x.dims ());
  octave_idx_type norm = a(0);

  if (norm == 0) 
    {
      error("filter: the first element of a must be non-zero");
    }
  if (si.length() != ab_len - 1)
    {
      error("filter: si must be a vector of length max(length(a), length(b)) - 1");
    }

  if (!error_state)
    {
      if (norm != 1)
	{
	  octave_idx_type idx_norm = index_of(norm);
	  for (octave_idx_type i = 0; i < b.length(); i++) {
	    if (b(i) != 0)
	      b(i) = alpha_to (modn (index_of (b(i)) - idx_norm + n, m, n));
	  }
	}
      if (a.length() > 1)
	{
	  if (norm != 1)
	    {
	      octave_idx_type idx_norm = index_of(norm);
	      for (octave_idx_type i = 0; i < a.length(); i++)
		if (a(i) != 0)
		  a(i) = alpha_to (modn (index_of(a(i)) - idx_norm + n, m, n));
	    }

	  for (octave_idx_type i = 0; i < x.length(); i++)
	    {
	      y(i) = si(0);
	      if ((b(0) != 0) && (x(i) != 0))
		y(i) ^= alpha_to (modn (index_of(b(0)) + 
					     index_of(x(i)), m, n));
	      if (si.length() > 1)
		{
		  for (octave_idx_type j = 0; j < si.length() - 1; j++)
		    {
		      si(j) = si(j+1);
		      if ((a(j+1) != 0) && (y(i) != 0))
			si(j) ^= alpha_to (modn (index_of(a(j+1)) + 
						 index_of(y(i)), m, n));
		      if ((b(j+1) != 0) && (x(i) != 0))
			si(j) ^= alpha_to (modn (index_of(b(j+1)) + 
						 index_of(x(i)), m, n));
		    }
		  si(si.length()-1) = 0;
		  if ((a(si.length()) != 0) && (y(i) != 0))
		    si(si.length()-1) ^= alpha_to (modn (index_of(
		        a(si.length())) + index_of(y(i)), m, n));
		  if ((b(si.length()) != 0) && (x(i) != 0))
		    si(si.length()-1) ^= alpha_to (modn (index_of(
		        b(si.length()))+ index_of(x(i)), m, n));
		} 
	      else 
		{
		  si(0) = 0;
		  if ((a(1) != 0) && (y(i) != 0))
		    si(0) ^=  alpha_to (modn (index_of(a(1)) + 
					      index_of(y(i)), m, n));
		  if ((b(1) != 0) && (x(i) != 0))
		    si(0) ^= alpha_to (modn (index_of(b(1)) +
					     index_of(x(i)), m, n));
		}
	    }
	}
      else if (si.length() > 0) 
	{
	  for (octave_idx_type i = 0; i < x.length(); i++)
	    {
	      y(i) = si(0);
	      if ((b(0) != 0) && (x(i) != 0))
		y(i) ^= alpha_to (modn (index_of (b(0)) + 
					     index_of(x(i)), m, n ));
	      if (si.length() > 1)
		{
		  for (octave_idx_type j = 0; j < si.length() - 1; j++)
		    {
		      si(j) = si(j+1);
		      if ((b(j+1) != 0) && (x(i) != 0))
			si(j) ^= alpha_to (modn (index_of (b(j+1)) + 
						 index_of(x(i)), m, n));
		    }
		  si(si.length()-1) = 0;
		  if ((b(si.length()) != 0) && (x(i) != 0))
		    si(si.length()-1) ^= alpha_to (modn (index_of(
		        b(si.length())) + index_of (x(i)), m, n));
		} 
	      else 
		{
		  si(0) = 0;
		  if ((b(1) != 0) && (x(i) != 0))
		    si(0) ^= alpha_to (modn (index_of(b(1)) + 
					     index_of(x(i)), m, n));
		}
	    }
	} 
      else
	{
	  for (octave_idx_type i = 0; i < x.length(); i++)
	    {
	    if ((b(0) != 0) && (x(i) != 0))
	      {
		y(i) = alpha_to (modn (index_of (b(0)) + 
				       index_of(x(i)), m, n));
	      }
	    }
	}

      retval (1) = si;
      retval (0) = y;
    }

  return retval;
}
