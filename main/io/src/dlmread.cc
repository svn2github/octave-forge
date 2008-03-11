/* Copyright (C) 2008 Jonathan Stickel
** Adapted from previous version of dlmread.oct as authored by Kai Habel,
** but core code has been completely re-written.
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; If not, see <http://www.gnu.org/licenses/>. 
*/


#include "config.h"
#include <fstream>
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#include <octave/oct.h>
#include <octave/lo-ieee.h>

DEFUN_DLD (dlmread, args, ,
        "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{data} =} dlmread (@var{file})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file},@var{sep})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file},@var{sep},@var{R0},@var{C0})\n\
@deftypefnx {Loadable Function} {@var{data} =} dlmread (@var{file},@var{sep},@var{range})\n\
Read the matrix @var{data} from a text file. If not defined the separator\n\
between fields is assumed to be a whitespace character. Otherwise the\n\
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
  int nargin = args.length();
  bool sepflag = 0;
  if (nargin < 1 || nargin > 4) 
    {
      print_usage ();
      return retval;
    }

  if ( !args (0).is_string() ) 
    {
      error ("dlmread: 1st argument must be a string");
      return retval;
    }
  
  std::string fname (args(0).string_value());
  std::ifstream file (fname.c_str());
  if (!file)
    {
      error("dlmread: could not open file");
      return retval;
    }
  
  // set default separator
  std::string sep;
  if (nargin > 1)
    {
      if (args(1).is_sq_string ())
	sep = do_string_escapes (args(1).string_value());
      else
	sep = args(1).string_value();
    }

  //to be compatible with matlab, blank separator should correspond
  //to whitespace as delimter;
  if (!sep.length())
    {
      sep = " \t";
      sepflag = 1;
    }
  
  int i = 0, j = 0, r = 1, c = 1, rmax = 0, cmax = 0;
  std::string line;
  std::string str;
  Matrix rdata;
  ComplexMatrix cdata;
  bool iscmplx = false;
  size_t pos1, pos2;

  // take a subset if a range was given
  unsigned long r0 = 0, c0 = 0, r1 = ULONG_MAX-1, c1 = ULONG_MAX-1;
  if (nargin > 2)
    {
      if (nargin == 3)
	{
	  if (args(2).is_string ())
	    {
	      std::string str = args(2).string_value ();
	      size_t n = str.find_first_not_of("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
	      size_t m = 0;
	      if (n == NPOS)
		error ("dlmread: error parsing range");
	      else
		{
		  c0 = 0;
		  while (m < n)
		    {
		      c0 = c0 * 26;
		      char ch = str.at (m++);
		      if (ch >= 'a')
			ch -= 'a';
		      else
			ch -= 'A';
		      c0 += ch;
		    }

		  str = str.substr (n);
		  std::istringstream tmp_stream (str);
		  r0 = static_cast <unsigned long> 
		    (octave_read_double (tmp_stream)) - 1;

		  str = str.substr (str.find_first_not_of("0123456789."));
		  n = str.find_first_not_of("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
		  m = 0;
		  if (n == NPOS)
		    error ("dlmread: error parsing range");
		  else
		    {
		      c1 = 0;
		      while (m < n)
			{
			  c1 = c1 * 26;
			  char ch = str.at (m++);
			  if (ch >= 'a')
			    ch -= 'a';
			  else
			    ch -= 'A';
			  c1 += ch;
			}

		      str = str.substr (n);
		      std::istringstream tmp_stream2 (str);
		      r1 = static_cast <unsigned long> 
			(octave_read_double (tmp_stream2)) - 1;
		    }
		}
	    }
	  else
	    {
	      ColumnVector range(args(2).vector_value());
	      if (range.length() == 4)
		{
		  // double --> unsigned int     
		  r0 = static_cast<unsigned long> (range(0));
		  c0 = static_cast<unsigned long> (range(1));
		  r1 = static_cast<unsigned long> (range(2));
		  c1 = static_cast<unsigned long> (range(3));
		} 
	      else 
		{
		  error("dlmread: range must include [R0 C0 R1 C1]");
		}
	    }
	} 
      else if (nargin == 4) 
	{
	  r0 = args(2).ulong_value();
	  c0 = args(3).ulong_value();
	  // if r1 and c1 are not given, use what was found to be the maximum
	  r1 = r - 1;
	  c1 = c - 1;
	}
    }

  if (!error_state)
    {
      // Skip tge r0 leading lines as these might be a header
      for (unsigned long m = 0; m < r0; m++)
	getline (file, line);

      // read in the data one field at a time, growing the data matrix as needed
      while (getline (file, line))
	{
	  // skip blank lines for compatibility
	  if (line.find_first_not_of (" \t") == NPOS)
	    continue;

	  r = (r > i + 1 ? r : i + 1);
	  j = 0;
	  pos1 = 0;
	  do {
	    pos2 = line.find_first_of (sep, pos1);
	    str = line.substr (pos1, pos2 - pos1);

	    if (sepflag && pos2 != NPOS)
	      // treat consecutive separators as one
	      pos2 = line.find_first_not_of (sep, pos2) - 1;

	    c = (c > j + 1 ? c : j + 1);
	    if (r > rmax || c > cmax)
	      { 
		// use resize_and_fill for the case of not-equal length rows
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
		if (tmp_stream.eof())
		  if (iscmplx)
		    cdata (i, j++) = x;
		  else
		    rdata (i, j++) = x;
		else
		  {
		    double y = octave_read_double (tmp_stream);

		    if (!iscmplx && y != 0.)
		      {
			iscmplx = true;
			cdata = ComplexMatrix (rdata);
		      }
		    
		    if (iscmplx)
		      cdata (i, j++) = Complex (x, y);
		    else
		      rdata (i, j++) = x;
		  }
	      }
	    else if (iscmplx)
	      cdata (i, j++) = 0.;
	    else
	      rdata (i, j++) = 0.;

	    if (pos2 != NPOS)
	      pos1 = pos2 + 1;
	    else
	      pos1 = NPOS;

	  } while ( pos1 != NPOS );
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
	      // if r1 and c1 are not given, use what was found to be the maximum
	      r1 = r - 1;
	      c1 = c - 1;
	    }

	  // now take the subset of the matrix
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
	retval(0) = octave_value(cdata);
      else
	retval(0) = octave_value(rdata);
    }

  return retval;
}

/*

%!shared file
%! file = tmpnam (); 
%! fid = fopen (file, "wt");
%! fwrite (fid, "1, 2, 3\n4, 5, 6\n7, 8, 9");
%! fclose (fid);

%!assert (dlmread (file), [1, 2, 3; 4, 5, 6; 7, 8, 9]);
%!assert (dlmread (file, ","), [1, 2, 3; 4, 5, 6; 7, 8, 9]);
%!assert (dlmread (file, ",", [1, 0, 2, 1]), [4, 5; 7, 8]);
%!assert (dlmread (file, ",", "B1..C2"), [2, 3; 5, 6]);
%!test
%! unlink (file);

%!shared file
%! file = tmpnam (); 
%! fid = fopen (file, "wt");
%! fwrite (fid, "1, 2, 3\n4+4i, 5, 6\n7, 8, 9");
%! fclose (fid);

%!assert (dlmread (file), [1, 2, 3; 4 + 4i, 5, 6; 7, 8, 9]);
%!assert (dlmread (file, ","), [1, 2, 3; 4 + 4i, 5, 6; 7, 8, 9]);
%!assert (dlmread (file, ",", [1, 0, 2, 1]), [4 + 4i, 5; 7, 8]);
%!assert (dlmread (file, ",", "A2..B3"), [4 + 4i, 5; 7, 8]);
%!test
%! unlink (file);

*/
