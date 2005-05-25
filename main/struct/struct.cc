// Author: Paul Kienzle
// This program is public domain

#include <octave/oct.h>
#include <octave/oct-map.h>
#if !defined(HAVE_OCTAVE_MAP_INDEX) && !defined(_Pix_h)

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
%!test x=struct([]);
%!assert(size(x),[0,0]);
%!assert(isstruct(x));
%!assert(isempty(fieldnames(x)));
%!fail("struct('a',{1,2},'b',{1,2,3})","dimensions of parameter 2 do not match those of parameter 4")
%!fail("struct(1,2,3,4)","struct expects alternating");
%!fail("struct('1',2,'3')","struct expects alternating");

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

  // struct([]) returns an empty struct.
  // XXX FIXME XXX should struct() also create an empty struct?
  if (nargin == 1 && args (0).is_empty () && args (0).is_real_matrix ())
    {
      return octave_value (Octave_map ());
    }
    
  // Check that we have some args
  if (nargin == 0) 
    {
      print_usage ("struct");
      return retval;
    }

  // Check for 'field',value pairs
  for (int i=0; i < nargin; i+=2) 
    {
      if (!args (i).is_string () || i+1 >= nargin)
	{
	  error ("struct expects alternating 'field',value pairs");
	  return retval;
	}
    }

  // Check that the dimensions of the values correspond
  dim_vector dims(1,1);
  int first_dimensioned_value = 0;
  for (int i=1; i < nargin; i+=2) 
    {
      if (args (i).is_cell ()) 
	{
	  dim_vector argdims (args (i).dims ());
	  if (!scalar (argdims))
	    {
	      if (!first_dimensioned_value)
		{
		  dims = argdims;
		  first_dimensioned_value = i+1;
		}
	      else if (dims != argdims)
		{
		  error ("struct: dimensions of parameter %d do not match those of parameter %d",
			 first_dimensioned_value, i+1);
		  return retval;
		}
	    }
	}
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
#endif
