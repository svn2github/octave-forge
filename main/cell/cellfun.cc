// Copyright (C) 2005 Mohamed Kamoun
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

#include "config.h"
#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-mappers.h>
#include <ctype.h>
#include <cassert>
#include <cstddef>
#include <cctype>
#include <string>

DEFUN_DLD (cellfun, args, nargout," -*- texinfo -*- \n\
@deftypefn {Lodable Function} {} cellfun (@var{name}, @var{c})\n\
@deftypefnx {Lodable Function} {} cellfun ('isclass', @var{c}, @var{class})\n\
@deftypefnx {Lodable Function} {} cellfun ('size', @var{c}, @var{k})\n\
@deftypefnx {Lodable Function} {} cellfun (@var{func}, @var{c})\n\
\n\
Evaluate the function named @var{name} on the elements of the cell array\n\
@var{c}. Elements in cell_array are passed on to the named function\n\
individually. @var{name} can be one of the functions\n\
\n\
@table @asis\n\
@item isempty\n\
returns 1 when for non empty elements and 0 for others\n\
@item islogical\n\
returns 1 for logical elements.\n\
@item isreal\n\
returns 1 for real elements\n\
@item length\n\
returns a vector of the lengths of cell elements\n\
@item dims\n\
returns the number of dims of each element\n\
@item prodofsize\n\
returns the product of dims of each element\n\
@item size\n\
Requires a third parameter @var{k}, and returns the size along the\n\
@var{k}-th dimension\n\
@item isclass\n\
Requires a third parameter @var{class} and returns 1 for elements\n\
of this class.\n\
@end table\n\
\n\
Additionally, @dfn{cellfun} accepts an arbitrary function @var{func}\n\
in the form of an inline function, function handle, or a string. This\n\
function should take a single argument and return a single argument, and\n\
in the case of a string argument, the argument must be @var{x}. An example\n\
is\n\
\n\
@example\n\
@group\n\
cellfun ('tolower(x)',@{'Foo','Bar','FooBar'@})\n\
@result{} ans = @{'foo', 'bar', 'foobar'@}\n\
@end group\n\
@end example\n\
\n\
@end deftypefn")
{
  octave_value retval;
  std::string name = "function";
  octave_function *func = 0;

  int nargin = args.length ();
  if (nargin < 2)
    {
      error("cellfun: you must supply at least 2 arguments");
      print_usage("cellfun");
      return octave_value_list();
    }

  if (args(0).is_function_handle () || args(0).is_inline_function ())
    {
      func = args(0).function_value ();

      if (error_state)
	return octave_value ();
    }
  else if (args(0).is_string ())
    name = args(0).string_value ();
  else
    {
      error ("cellfun: first argument must be a string");

      return octave_value();
    }	
  if (!args(1).is_cell())
    {
      error ("cellfun: second argument must be a cell");

      return octave_value();
    }
  
  Cell f_args = args(1).cell_value ();
  
  int k = f_args.numel();
  
  if (name == "isempty")
    { 
      boolNDArray _retval(f_args.dims());
      for(int  count=0; count<k ; count++)
        _retval(count)=f_args.elem(count).is_empty();
      retval=_retval;
    }
  else if (name == "islogical")
    {
      boolNDArray _retval(f_args.dims());
      for(int  count=0; count<k ; count++)
        _retval(count)=f_args.elem(count).is_bool_type();
      retval=_retval;
    }
  else if (name == "isreal")
    {
      boolNDArray _retval(f_args.dims());
      for(int  count=0; count<k ; count++)
        _retval(count)=f_args.elem(count).is_real_type();
      retval=_retval;
    }
  else if (name == "length")
    {
      NDArray _retval(f_args.dims());
      for(int  count=0; count<k ; count++)
        _retval(count)=double(f_args.elem(count).numel());
      retval=_retval;
    }
  else if (name == "ndims")
    {
      NDArray _retval(f_args.dims());
      for(int  count=0; count<k ; count++)
        _retval(count)=double((f_args.elem(count).dims()).numel());
      retval=_retval;
    }
  else if (name == "prodofsize")
    {
      NDArray _retval(f_args.dims());
      for(int  count=0; count<k ; count++)
        _retval(count)=double((f_args.elem(count).dims()).numel());
      retval=_retval;
    }
  else if (name == "size")
    {
      if (nargin == 3)
        {
          int d = args(2).nint_value() - 1;

          if (d < 0)
	    error ("cellfun: third argument must be a postive integer");

	  if (!error_state)
            {
              NDArray _retval(f_args.dims());
              for(int  count=0; count<k ; count++)
                {
                  dim_vector dv = f_args.elem(count).dims();
                  if (d < dv.length())
	            _retval(count)=double(dv(d));
                  else
	            _retval(count)=1.0;
                }
              retval=_retval;
            }
        }
      else
        error("Not enough argument for size");
    }
  else if (name == "isclass")
    {
      if (nargin == 3)
        {
          std::string class_name = args(2).string_value();
          boolNDArray _retval(f_args.dims());
          for(int count=0; count<k ; count++)
            _retval(count) = (f_args.elem(count).class_name() == class_name);
          
          retval=_retval;
        }
      else
        error("Not enough argument for isclass");
    }
  else 
    {
      std::string fcn_name;
      
      if (!func)
	{
	  fcn_name = unique_symbol_name ("__cellfun_fcn_");
	  std::string fname = "function y = ";
	  fname.append (fcn_name);
	  fname.append ("(x) y = ");
	  func = extract_function (args(0), "cellfun", fcn_name, fname,
				       "; endfunction");
	}

      if (!func)
	error("unknown function");
      else
	{
	  Cell _retval (f_args.dims());

          for(int count=0; count<k ; count++)
	    {
	      octave_value_list tmp = 
		func->do_multi_index_op (1, f_args.elem(count));
	      _retval(count) = tmp(0); 

	      if (error_state)
		break;
	    }

	  if (!error_state)
	    retval = _retval;

	  if (fcn_name.length())
	    clear_function (fcn_name);
	}
    }
  
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
