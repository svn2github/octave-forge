#include <octave/oct.h>
#include <octave/oct-map.h>

static bool 
scalar (const dim_vector& dims) 
{
  return dims.length () == 2 && dims (0) == 1 && dims (1) == 1;
}

/*
%!shared x
%! x(1).a=1; x(2).a=2; x(1).b=3; x(2).b=3;
%!assert(struct('a',1,'b',3),x(1))
%!assert(struct('a',{},'b',{}),x([]))
%!assert(struct('a',{1,2},'b',{3,3}),x)
%!assert(struct('a',{1,2},'b',3),x)
%!assert(struct('a',{1,2},'b',{3}),x)
%!assert(struct('b',3,'a',{1,2}),x)
%!assert(struct('b',{3},'a',{1,2}),x) 
 */

DEFUN_DLD (struct, args, , "\
struct('field',value,'field',value,...)\n\n\
  Create a structure and initialize its value.\n\n\
struct('field',{values},'field',{values},...)\n\n\
  Create a structure array and initialize its values.  The dimensions\n\
  of each array of values must match.  Singleton cells and non-cell values\n\
  are repeated so that they fill the entire array.\n\n\
struct('field',{},'field',{},...)\n\n\
  Create an empty structure array.")
{
  octave_value_list retval;
  int nargin = args.length ();

  // Check that there is an even number of args
  if (nargin == 0 || nargin%2 == 1) 
    {
      print_usage ("struct");
      return retval;
    }

  // Check that every second arg is a field name
  for (int i=0; i < nargin; i+=2) 
    {
      if (!args (i).is_string ()) 
	{
	  error ("struct expects alternating 'field',value pairs");
	  return retval;
	}
    }

  // Check that the dimensions of the fields correspond
  dim_vector dims (args (1).is_cell () ? args (1).dims () : dim_vector (1,1));
  // std::cout << "initial dims = " << dims.str() << std::endl;
  for (int i=3; i < nargin; i+=2) 
    {
      if (args (i).is_cell ()) 
	{
	  if (scalar (dims)) 
	    {
	      dims = args (i).dims ();
	      // std::cout << "scalar dims, using " << dims.str() << std::endl;
	    } 
	  else 
	    {
	      dim_vector testdim (args (i).dims ());
	      if (!scalar (testdim) && dims != testdim) 
		{
		  error ("dimensions must match for all fields");
		  return retval;
		}
	      //std::cout<<dims.str()<<" matches "<<testdim.str()<<std::endl;
	    }
	} 
      // else std::cout << dims.str() << " matches scalar" << std::endl;
    }

  // Create the return value
  // Octave_map(dim_vector) doesn't exist, so emulate one using the
  // the first field name and a dummy cell array.
  Octave_map map (args (0).string_value (), Cell (dims));
  // Octave_map map;

  for (int i=0; i < nargin; i+=2) 
    {
      // Get key
      std::string key (args (i).string_value ());
      if (error_state) return retval; // error converting to string

      // Value may be v, { v }, or { v1, v2, ... }
      // In the first two cases, we need to create a cell array of
      // the appropriate dimensions filled with v.  In the last case, 
      // the cell array has already been determined to be of the
      // correct dimensions.
      if (args (i+1).is_cell ()) 
	{
	  const Cell c (args (i+1).cell_value ());
	  if (error_state) return retval; // error converting to cell
	  if (scalar (c.dims ())) 
	    {
	      // std::cout << "struct: assigning {scalar} ";
	      // c(0).print (std::cout);
	      map.assign (key, Cell (dims, c (0)));
	    } 
	  else 
	    {
	      //std::cout << "assigning {vector} "; args(i+1).print(std::cout);
	      map.assign (key, c);
	    }
	}
      else 
	{
	  // std::cout << "assigning scalar "; args(i+1).print(std::cout);
	  map.assign (key, Cell (dims, args (i+1)));
	}

      if (error_state) return retval; // error from assign
    }
  
  return octave_value (map);
}
