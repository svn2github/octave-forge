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

#include "error.h"
#include "oct-lvalue.h"
#include "ov-struct.h"
// #include "unwind-prot.h"
#include "variables.h"


DEFUN_DLD (setfield, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Built-in Function} {} \
@var{s2} = setfield (@var{s1}, 'k1',@var{v1},...) or \
@ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ @ \
@var{s2} = setfield ('k1',@var{v1},...) \n\n\
This function call is equivalent to @code{@var{s1} = @var{s2}; \
@var{s2}.k1 = @var{v1};...}. The first argument @var{s1} may be ommited. \
Provides some compatibility and some flexibility.\n\
@end deftypefn\n\
@seealso{getfield,rmfield,isfield,isstruct,fields,cmpstruct,struct}")
{
  octave_value retval;

  int nargin = args.length ();

  Octave_map tmp;

  if (nargin < 1) return retval = tmp;

  int i = 1;			// Beginning, in args, of key-value pairs

  if 	  (args (0).is_empty ()) {} // empty initial struct
  else if (args (0).is_map ())   tmp = args (0).map_value();
  else if (args (0).is_string()) i-- ;
  else { error ("first argument is neither struct nor string"); return retval = tmp;}

  if ((nargin - i) % 2) {
    error ("arguments do not form key-value pairs");
    return retval = tmp;
  }
  
  for (; i<nargin; i+= 2) {
    
    if (args(i).is_string ()) {
      std::string s = args(i).string_value ();
      tmp.assign (s, args(i+1));
    } else 
      error ("argument number %i is not a string",i+1);
  }
  retval = tmp;

  return retval;
}
