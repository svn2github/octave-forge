// Copyright (C) 2002 Etienne Grossmann.  All rights reserved.
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 2, or (at your option) any
// later version.
//
// This is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for more details.


#include "config.h"
#include <oct.h>
#include <octave/parse.h>


DEFUN_DLD (leval, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Built-in Function} {} leval (@var{name}, @var{list})\n\
Evaluate the function named @var{name}.  All the elements in @var{list}\n\
are passed on to the named function.  For example,\n\
\n\
@example\n\
leval (\"acos\", list (-1))\n\
     @result{} 3.1416\n\
@end example\n\
\n\
@noindent\n\
calls the function @code{acos} with the argument @samp{-1}.\n\
\n\
The function @code{leval} provides provides more flexibility than\n\
@code{feval} since arguments need not be hard-wired in the calling \n\
code. @seealso{feval and eval}\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin == 2) 
    {
      std::string name = args(0).string_value ();
      if (error_state) 
	error ("leval: first argument must be a string");

      octave_value_list lst = args(1).list_value ();
      if (error_state) 
	error ("leval: second argument must be a list");

      retval = feval (name, lst, nargout);

    } 
  else
    print_usage ("leval");

  return retval;
}

/*
%!assert(leval("acos", list(-1)), pi, 100*eps);
 */
