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

// Get values out of struct by specifying the struct (1st arg) and the
// fields (following args).

DEFUN_DLD (getfields, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Built-in Function} {} [@var{v1},...] = \
getfields (@var{s}, 'k1',...) = [@var{s}.k1,...]\n\n\
Return selected values from a struct. Provides some compatibility \n\
and some flexibility.\n\
@end deftypefn\n\
@seealso{setfields,rmfield,isfield,isstruct,fields,cmpstruct,struct}")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin >= 1 && args (0).is_map ())  {

    for (int i = 1; i<nargin; i++) {

      if (args(i).is_string ()) {
#if defined(HAVE_SLLIST_H)
        octave_value tmp = args(0).subsref (".", args(i));
#else
	std::list<octave_value_list> idx;
	idx.push_back ( octave_value_list(args(i)) );
	octave_value tmp = args(0).subsref (".", idx);
#endif

	if (tmp.is_defined ())	  retval(i-1) = tmp;

	else {
          std::string s = args(i).string_value ();
          error ("structure has no member `%s'", s.c_str ());
        }


      } else
	error ("argument number %i is not a string",i+1);
    }

  } else
    print_usage ("getfields");

  return retval;
}
