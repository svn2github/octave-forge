/*

Copyright (C) 2005 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#include <octave/config.h>
#include <octave/oct.h>
#include <octave/Cell.h>

DEFUN_DLD (num2cell, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{c} =} num2cell (@var{m})\n\
@deftypefnx {Loadable Function} {@var{c} =} num2cell (@var{m}, @var{d})\n\
Convert to matrix @var{m} into a cell array. If @var{d} is defined the\n\
value @var{c} is of dimension 1 in this dimension and the elements of\n\
@var{m} are placed in slices in @var{c}.\n\
@end deftypefn\n\
@seealso{mat2cell}") 
{
  int nargin =  args.length();
  octave_value retval;

  if (nargin < 1 || nargin > 2)
    usage ("num2cell");
  else
    {
      dim_vector dv = args(0).dims ();
      Array<int> sings;

      if (nargin == 2)
	{
	  ColumnVector dsings = ColumnVector (args(1).vector_value 
						  (false, true));
	  sings.resize (dsings.length());

	  if (!error_state)
	    for (int i = 0; i < dsings.length(); i++)
	      if (dsings(i) > dv.length() || dsings(i) < 1 ||
		  D_NINT(dsings(i)) != dsings(i))
		{
		  error ("invalid dimension specified");
		  break;
		}
	      else
		sings(i) = NINT(dsings(i)) - 1;
	}

      if (! error_state)
	{
	  Array<idx_vector> idx(dv.length());
	  dim_vector new_dv (dv);

	  // Create new dim_vector placing all singular elements at start
	  for (int i = 0; i < dv.length(); i++)
	    {
	      bool found = false;
	      for (int j = 0; j < sings.length(); j++)
		if (sings(j) == i)
		  {
		    found = true;
		    break;
		  }
	      if (found)
		{
		  idx(i) = idx_vector(':');
		  new_dv(i) = 1;
		}
	    }

	  Cell ret (new_dv);
	  octave_idx_type nel = new_dv.numel();
	  octave_idx_type ntot = 1;

	  for (int j = 0; j < new_dv.length()-1; j++)
	    ntot *= new_dv(j);

#define DOIT(TYP1,TYP2) \
	  { \
	    TYP1 ## NDArray m = args(0). TYP2 ## array_value(); \
	    for (octave_idx_type i = 0; i <  nel; i++) \
	      { \
		octave_idx_type n = ntot; \
		octave_idx_type ii = i; \
		for (int j = new_dv.length() - 1; j >= 0 ; j--) \
		  { \
		    if (! idx(j).is_colon()) \
		      idx(j) = idx_vector (ii / n + 1); \
		    ii = ii % n; \
		    if (j != 0) \
		      n /= new_dv(j-1); \
		  } \
		ret(i) = TYP1 ## NDArray (m.index (idx, 0)); \
	      } \
	  }

	  std::string cname = args(0).class_name ();

	  if (cname == "double")
	    {
	      if (args(0).is_complex_type())
		DOIT (Complex, complex_)
	      else
		DOIT ( , )
	    }
	  else if (cname == "uint8")
	    DOIT (uint8, uint8_)
	  else if (cname == "uint16")
	    DOIT (uint16, uint16_)
	  else if (cname == "uint32")
	    DOIT (uint32, uint32_)
	  else if (cname == "uint64")
	    DOIT (uint64, uint64_)
	  else if (cname == "int8")
	    {
	      if (args(0).is_char_matrix())
		DOIT (char, char_)
	      else
		DOIT (int8, int8_)
	    }
	  else if (cname == "int16")
	    DOIT (int16, int16_)
	  else if (cname == "int32")
	    DOIT (int32, int32_)
	  else if (cname == "int64")
	    DOIT (int64, int64_)

	  retval = ret;
	}
    }

  return retval;
}
	  
/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
