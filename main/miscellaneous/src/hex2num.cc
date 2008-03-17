/*

Copyright (C) 2008 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

#include <config.h>
#include <algorithm>

#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/gripes.h>
#include <octave/oct-obj.h>
#include <octave/utils.h>

DEFUN_DLD (hex2num, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{n} =} hex2num (@var{s})\n\
Typecast the 16 character hexadecimal character matrix to an IEEE 754\n\
double precision number. If fewer than 16 characters are given the\n\
strings are right padded with '0' characters.\n\
\n\
Given a string matrix, @code{hex2num} treats each row as a separate\n\
number.\n\
\n\
@example\n\
hex2num ([\"4005bf0a8b145769\";\"4024000000000000\"])\n\
@result{} [2.7183; 10.000]\n\
@end example\n\
@seealso{num2hex, hex2dec, dec2hex}\n\
@end deftypefn")
{
  int nargin = args.length ();
  octave_value retval;

  if (nargin != 1)
    print_usage ();
  else
    {
      const charMatrix cmat = args(0).char_matrix_value ();

      if (cmat.columns () > 16)
	error ("hex2num: expecting no more than a 16 character string");
      else if (! error_state)
	{
	  octave_idx_type nr = cmat.rows ();
	  octave_idx_type nc = cmat.columns ();
	  ColumnVector m (nr);

	  for (octave_idx_type i = 0; i < nr; i++)
	    {
	      uint64_t num = 0;
	      for (octave_idx_type j = 0; j < nc; j++)
		{
		  unsigned char ch = cmat.elem (i, j);

		  if (isxdigit (ch))
		    {
		      num <<= 4;
		      if (ch >= 'a')
			num += static_cast<uint64_t> (ch - 'a' + 10);
		      else if (ch >= 'A')
			num += static_cast<uint64_t> (ch - 'A' + 10);
		      else
			num += static_cast<uint64_t> (ch - '0');
		    }
		  else
		    {
		      error ("hex2num: illegal character found in string");
		      break;
		    }
		}

	      if (error_state)
		break;
	      else
		{
		  if (nc < 16)
		    num <<= (16 - nc) * 4;

		  m (i) = *reinterpret_cast<double *>(&num);

		}
	    }

	  if (! error_state)
	    retval =  m;
	}
    }

  return retval;
}

/*

%!assert (hex2num(['c00';'bff';'000';'3ff';'400']),[-2:2]')

 */



DEFUN_DLD (num2hex, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{s} =} num2hex (@var{n})\n\
Typecast a double precision number or vector to a 16 character hexadecimal\n\
string of the IEEE 754 representation of the number. For example\n\
\n\
@example\n\
num2hex ([-1, 1, e, Inf, NaN, NA]);\n\
@result{} \"bff0000000000000\n\
    3ff0000000000000\n\
    4005bf0a8b145769\n\
    7ff0000000000000\n\
    fff8000000000000\n\
    7ff00000000007a2\"\n\
@end example\n\
@seealso{hex2num, hex2dec, dec2hex}\n\
@end deftypefn")
{
  int nargin = args.length ();
  octave_value retval;

  if (nargin != 1)
    print_usage ();
  else
    {
      const ColumnVector v (args(0).vector_value ());

      if (! error_state)
	{
	  octave_idx_type nr = v.length ();
	  charMatrix m (nr, 16);
	  const double *pv = v.fortran_vec ();

	  for (octave_idx_type i = 0; i < nr; i++)
	    {
	      const uint64_t num = *reinterpret_cast<const uint64_t *> (pv++);
	      for (octave_idx_type j = 0; j < 16; j++)
		{
		  unsigned char ch = 
		    static_cast<char> (num >> ((15 - j) * 4) & 0xF);
		  if (ch >= 10)
		    ch += 'a' - 10;
		  else
		    ch += '0';

		  m.elem (i, j) = ch;
		}
	    }
	  
	  retval = octave_value (m, true);
	}
    }

  return retval;
}

/*

%!assert (num2hex (-2:2),['c000000000000000';'bff0000000000000';'0000000000000000';'3ff0000000000000';'4000000000000000'])

 */


