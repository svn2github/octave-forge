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
Read the matrix @var{data} from a text file\n\
The @var{range} parameter must be a 4 element vector containing  the upper left and lower right corner\n\
[@var{R0},@var{C0},@var{R1},@var{C1}]\n\
The lowest index value is zero.\n\
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
  ComplexMatrix data;
  size_t pos1, pos2;

  // take a subset if a range was given
  unsigned long r0 = 0, c0 = 0, r1 = ULONG_MAX-1, c1 = ULONG_MAX-1;
  if (nargin > 2)
    {
      if (nargin == 3)
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
      else if (nargin == 4) 
	{
	  r0 = args(2).ulong_value();
	  c0 = args(3).ulong_value();
	  // if r1 and c1 are not given, use what was found to be the maximum
	  r1 = r - 1;
	  c1 = c - 1;
	}
    }

  // Skip tge r0 leading lines as these might be a header
  for (unsigned long i = 0; i < r0; i++)
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
	    data.resize_and_fill (r, c, 0);
	    rmax = r;
	    cmax = c;
	  }

	std::istringstream tmp_stream (str);
	double x = octave_read_double (tmp_stream);
	if (tmp_stream)
	  {
	    if (tmp_stream.eof())
	      data (i, j++) = x;
	    else
	      data (i, j++) = Complex (x, octave_read_double (tmp_stream));
	  }
	else
	  data (i, j++) = 0.;

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
      data = data.extract (0, c0, r1, c1);
      data.resize (r1 + 1, c1 - c0 + 1);
    }
  
  retval(0) = octave_value(data);
  return retval;
}
