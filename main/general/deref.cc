#include <octave/oct.h>
#include <octave/ov-cell.h>

DEFUN_DLD (deref, args,,
"-*- texinfo -*-\n\
@deftypefn {Built-in Function} {} deref (@var{cell}, @var{n})\n\
Return the @var{n}-th element of @var{cell}.\n\
@deftypefnx {Built-in Function} {} deref (@var{cell}, @var{i}, @var{j})\n\
Return the @var{i,j}-th element of @var{cell}.\n\
@end deftypefn")
{
  octave_value retval;
  int i=-1,j=-1;
  
  if (args.length() < 2 
      || (args(0).is_list() && args.length() > 2)
      || args.length() > 3)
    {
      print_usage ("deref");
      return retval;
    }
  
  i = args(1).int_value (true);
  if (error_state || i < 1)
    {
      error ("deref: second argument must be a positive integer");
      return retval;
    }
  
  if (args.length() == 3) 
    {
      j = args(2).int_value (true);
      if (error_state || j < 1)
	{
	  error ("deref: third argument must be a positive integer");
	  return retval;
	}
    }
  
  Cell cell = args(0).cell_value ();
      
  if (! error_state)
    {
      int nr = cell.rows();
      int nc = cell.columns();
      
      if (j == -1) 
	if (nr == 1)
	  if (i <= nc)
	    retval = cell(0,i-1);
	  else
	    error ("deref: index = %d out of range", i);
	else if (nc == 1)
	  if (i <= nr)
	    retval = cell(i-1,0);
	  else
	    error ("deref: index = %d out of range", i);
	else
	  error ("deref: single index not valid for 2-D cell array");
      else if (i <= nr && j <= nc)
	retval = cell(i-1, j-1);
      else
	error ("deref: index = %d,%d out of range", i, j);
    }

  return retval;
}
