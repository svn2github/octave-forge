/*
2000-04-30: Paul Kienzle

Based on functions from Octave with the following copyright:

Copyright (C) 1996, 1997 John W. Eaton

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301  USA
*/

#include <octave/oct.h>
#include <octave/oct-strstrm.h>

DEFUN_DLD (pretty, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{str} =} pretty (@var{v})\n\
\n\
Equivalent to @code{str=disp(v)}.\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin == 1) 
    {
      octave_ostrstream *ostr = new octave_ostrstream();
      std::ostream& os = *(ostr->output_stream());
      args(0).print (os, false);
      retval(0) = octave_value(ostr->str());
    }
  else
    print_usage ("pretty");

  return retval;
}
