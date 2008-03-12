/*

Copyright (C) 2008  Jonathan Stickel

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with ; see s programthe file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

// Adapted from previous version of dlmread.occ as authored by Kai
// Habel, but core code has been completely re-written.

#include "config.h"

#include <cctype>
#include <fstream>

#include <octave/lo-ieee.h>

#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/oct-obj.h>
#include <octave/utils.h>

static bool
read_cell_spec (std::istream& is, unsigned long& row, unsigned long& col)
{
  bool stat = false;

  if (is.peek () == std::istream::traits_type::eof ())
    stat = true;
  else
    {
      if (::isalpha (is.peek ()))
	{
	  col = 0;
	  while (is && ::isalpha (is.peek ()))
	    {
	      char ch = is.get ();
	      col *= 26;
	      if (ch >= 'a')
		col += ch - 'a';
	      else
		col += ch - 'A';
	    }

	  if (is)
	    {
	      is >> row;
	      row --;
	      if (is)
		stat = true;
	    }
	}
    }

  return stat;
}

static bool
parse_range_spec (const octave_value& range_spec,
		  unsigned long& rlo, unsigned long& clo,
		  unsigned long& rup, unsigned long& cup)
{
  bool stat = true;

  if (range_spec.is_string ())
    {
      std::istringstream is (range_spec.string_value ());
      char ch = is.peek ();

      if (ch == '.' || ch == ':')
	{
	  rlo = 0;
	  clo = 0;
	  ch = is.get ();
	  if (ch == '.')
	    {
	      ch = is.get ();
	      if (ch != '.')
		stat = false;
	    }
	}
      else
	{
	  stat = read_cell_spec (is, rlo, clo);

	  if (stat)
	    {
	      ch = is.peek ();
	  
	      if (ch == '.' || ch == ':')
		{
		  ch = is.get ();
		  if (ch == '.')
		    {
		      ch = is.get ();
		      if (!is || ch != '.')
			stat = false;
		    }

		  rup = ULONG_MAX - 1;
		  cup = ULONG_MAX - 1;
		}
	      else
		{
		  rup = rlo;
		  cup = clo;
		  if (!is || !is.eof ())
		    stat = false;
		}
	    }
	}

      if (stat && is && !is.eof ())
	stat = read_cell_spec (is, rup, cup);

      if (!is || !is.eof ())
	stat = false;
    }
  else if (range_spec.is_real_matrix () && range_spec.numel () == 4)
    {
      ColumnVector range(range_spec.vector_value ());
      // double --> unsigned int     
      rlo = static_cast<unsigned long> (range(0));
      clo = static_cast<unsigned long> (range(1));
      rup = static_cast<unsigned long> (range(2));
      cup = static_cast<unsigned long> (range(3));
    }
  else 
    stat = false;

  return stat;
}

DEFUN_DLD (dlmread, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{data} =} dlmread (@var{file})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file}, @var{sep})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file}, @var{sep}, @var{r0}, @var{c0})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file}, @var{sep}, @var{range})\n\
Read the matrix @var{data} from a text file. If not defined the separator\n\
between fields is determined from the file itself. Otherwise the\n\
separation character is defined by @var{sep}.\n\
\n\
Given two scalar arguments @var{r0} and @var{c0}, these define the starting\n\
row and column of the data to be read. These values are indexed from zero,\n\
such that the first row corresponds to an index of zero.\n\
\n\
The @var{range} parameter must be a 4 element vector containing  the upper\n\
left and lower right corner @code{[@var{R0},@var{C0},@var{R1},@var{C1}]} or\n\
a spreadsheet style range such as 'A2..Q15'. The lowest index value is zero.\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin < 1 || nargin > 4) 
    {
      print_usage ();
      return retval;
    }

  if (!args(0).is_string ())
    {
      error ("dlmread: 1st argument must be a string");
      return retval;
    }
  
  std::string fname (args(0).string_value ());
  if (error_state)
    return retval;

  std::ifstream file (fname.c_str ());
  if (!file)
    {
      error ("dlmread: unable to open file `%s'", fname.c_str ());
      return retval;
    }
  
  // Set default separator.
  std::string sep;
  if (nargin > 1)
    {
      if (args(1).is_sq_string ())
	sep = do_string_escapes (args(1).string_value ());
      else
	sep = args(1).string_value ();

      if (error_state)
	return retval;
    }
  
  // Take a subset if a range was given.
  unsigned long r0 = 0, c0 = 0, r1 = ULONG_MAX-1, c1 = ULONG_MAX-1;
  if (nargin > 2)
    {
      if (nargin == 3)
	{
	  if (!parse_range_spec (args (2), r0, c0, r1, c1))
	    error ("dlmread: error parsing range");
	} 
      else if (nargin == 4) 
	{
	  r0 = args(2).ulong_value ();
	  c0 = args(3).ulong_value ();

	  if (error_state)
	    return retval;
	}
    }

  if (!error_state)
    {
      unsigned long i = 0, j = 0, r = 1, c = 1, rmax = 0, cmax = 0;

      Matrix rdata;
      ComplexMatrix cdata;

      bool iscmplx = false;
      bool sepflag = false;

      unsigned long maxrows = r1 - r0;

      std::string line;

      // Skip the r0 leading lines as these might be a header.
      for (unsigned long m = 0; m < r0; m++)
	getline (file, line);
      r1 -= r0;

      // Read in the data one field at a time, growing the data matrix
      // as needed.
      while (getline (file, line))
	{
	  // Skip blank lines for compatibility.
	  if (line.find_first_not_of (" \t") == NPOS)
	    continue;

	  // To be compatible with matlab, blank separator should
	  // correspond to whitespace as delimter.
	  if (!sep.length ())
	    {
	      size_t n = line.find_first_of (",:; \t", 
					     line.find_first_of ("0123456789"));
	      if (n == NPOS)
		{
		  sep = " \t";
		  sepflag = true;
		}
	      else
		{
		  char ch = line.at (n);

		  switch (line.at (n))
		    {
		    case ' ':
		    case '\t':
		      sepflag = true;
		      sep = " \t";
		      break;

		    default:
		      sep = ch;
		      break;
		    }
		}
	    }

	  r = (r > i + 1 ? r : i + 1);
	  j = 0;
	  size_t pos1 = 0;
	  do
	    {
	      size_t pos2 = line.find_first_of (sep, pos1);
	      std::string str = line.substr (pos1, pos2 - pos1);

	      if (sepflag && pos2 != NPOS)
		// Treat consecutive separators as one.
		pos2 = line.find_first_not_of (sep, pos2) - 1;

	      c = (c > j + 1 ? c : j + 1);
	      if (r > rmax || c > cmax)
		{ 
		  // Use resize_and_fill for the case of not-equal
		  // length rows.
		  if (iscmplx)
		    cdata.resize_and_fill (r, c, 0);
		  else
		    rdata.resize_and_fill (r, c, 0);
		  rmax = r;
		  cmax = c;
		}

	      std::istringstream tmp_stream (str);
	      double x = octave_read_double (tmp_stream);
	      if (tmp_stream)
		{
		  if (tmp_stream.eof ())
		    if (iscmplx)
		      cdata(i,j++) = x;
		    else
		      rdata(i,j++) = x;
		  else
		    {
		      double y = octave_read_double (tmp_stream);

		      if (!iscmplx && y != 0.)
			{
			  iscmplx = true;
			  cdata = ComplexMatrix (rdata);
			}

		      if (iscmplx)
			cdata(i,j++) = Complex (x, y);
		      else
			rdata(i,j++) = x;
		    }
		}
	      else if (iscmplx)
		cdata(i,j++) = 0.;
	      else
		rdata(i,j++) = 0.;

	      if (pos2 != NPOS)
		pos1 = pos2 + 1;
	      else
		pos1 = NPOS;

	    }
	  while (pos1 != NPOS);

	  if (nargin == 3 && i == maxrows)
	    break;

	  i++;
	}
 
      if (nargin > 2)
	{
	  if (nargin == 3)
	    {
	      if (r1 >= r)
		r1 = r - 1;
	      if (c1 >= c)
		c1 = c - 1;
	    }
	  else if (nargin == 4) 
	    {
	      // If r1 and c1 are not given, use what was found to be
	      // the maximum.
	      r1 = r - 1;
	      c1 = c - 1;
	    }

	  // Now take the subset of the matrix.
	  if (iscmplx)
	    {
	      cdata = cdata.extract (0, c0, r1, c1);
	      cdata.resize (r1 + 1, c1 - c0 + 1);
	    }
	  else
	    {
	      rdata = rdata.extract (0, c0, r1, c1);
	      rdata.resize (r1 + 1, c1 - c0 + 1);
	    }
	}
  
      if (iscmplx)
	retval(0) = cdata;
      else
	retval(0) = rdata;
    }

  return retval;
}

/*

%!shared file
%! file = tmpnam (); 
%! fid = fopen (file, "wt");
%! fwrite (fid, "1, 2, 3\n4, 5, 6\n7, 8, 9\n10, 11, 12");
%! fclose (fid);

%!assert (dlmread (file), [1, 2, 3; 4, 5, 6; 7, 8, 9;10, 11, 12]);
%!assert (dlmread (file, ","), [1, 2, 3; 4, 5, 6; 7, 8, 9; 10, 11, 12]);
%!assert (dlmread (file, ",", [1, 0, 2, 1]), [4, 5; 7, 8]);
%!assert (dlmread (file, ",", "B1..C2"), [2, 3; 5, 6]);
%!assert (dlmread (file, ",", "B1:C2"), [2, 3; 5, 6]);
%!assert (dlmread (file, ",", "..C2"), [1, 2, 3; 4, 5, 6]);
%!assert (dlmread (file, ",", 0, 1), [2, 3; 5, 6; 8, 9; 11, 12]);
%!assert (dlmread (file, ",", "B1.."), [2, 3; 5, 6; 8, 9; 11, 12]);
%!error (dlmread (file, ",", [0 1]))

%!test
%! unlink (file);

%!shared file
%! file = tmpnam (); 
%! fid = fopen (file, "wt");
%! fwrite (fid, "1, 2, 3\n4+4i, 5, 6\n7, 8, 9\n10, 11, 12");
%! fclose (fid);

%!assert (dlmread (file), [1, 2, 3; 4 + 4i, 5, 6; 7, 8, 9; 10, 11, 12]);
%!assert (dlmread (file, ","), [1, 2, 3; 4 + 4i, 5, 6; 7, 8, 9; 10, 11, 12]);
%!assert (dlmread (file, ",", [1, 0, 2, 1]), [4 + 4i, 5; 7, 8]);
%!assert (dlmread (file, ",", "A2..B3"), [4 + 4i, 5; 7, 8]);
%!assert (dlmread (file, ",", "A2:B3"), [4 + 4i, 5; 7, 8]);
%!assert (dlmread (file, ",", "..B3"), [1, 2; 4 + 4i, 5; 7, 8]);
%!assert (dlmread (file, ",", 1, 0), [4 + 4i, 5, 6; 7, 8, 9; 10, 11, 12]);
%!assert (dlmread (file, ",", "A2.."), [4 + 4i, 5, 6; 7, 8, 9; 10, 11, 12]);
%!error (dlmread (file, ",", [0 1]))

%!test
%! unlink (file);

*/
