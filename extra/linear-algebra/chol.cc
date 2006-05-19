/*

Copyright (C) 1996, 1997 John W. Eaton

This file is part of Octave.

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include "ov-re-tri.h"

#include "CmplxCHOL.h"
#include "dbleCHOL.h"

#include "defun-dld.h"
#include "error.h"
#include "gripes.h"
#include "oct-obj.h"
#include "utils.h"

extern void  install_tri_ops(void);
static bool type_loaded = false;

DEFUN_DLD (chol, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} chol (@var{a})\n\
@cindex Cholesky factorization\n\
Compute the Cholesky factor, @var{r}, of the symmetric positive definite\n\
matrix @var{a}, where\n\
@iftex\n\
@tex\n\
$ R^T R = A $.\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
\n\
@example\n\
r' * r = a.\n\
@end example\n\
@end ifinfo\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin != 1 || nargout > 2)
    {
      print_usage ();
      return retval;
    }

  octave_value arg = args(0);
    
  int nr = arg.rows ();
  int nc = arg.columns ();

  int arg_is_empty = empty_arg ("chol", nr, nc);

  if (arg_is_empty < 0)
    return retval;
  if (arg_is_empty > 0)
    return octave_value (Matrix ());

  if (arg.is_real_type ())
    {
      Matrix m = arg.matrix_value ();

      if (! error_state)
	{
	  octave_idx_type info;
	  CHOL fact (m, info);
	  if (nargout == 2 || info == 0)
	    {
	      if (! type_loaded) {       
		octave_tri::register_type ();
		install_tri_ops();
		type_loaded = true;
	      }

	      retval(1) = static_cast<double> (info);
	      retval(0) = new octave_tri(fact.chol_matrix (), octave_tri::Upper);
	      retval(0).maybe_mutate();
	    }
	  else
	    error ("chol: matrix not positive definite");
	}
    }
  else if (arg.is_complex_type ())
    {
      ComplexMatrix m = arg.complex_matrix_value ();

      if (! error_state)
	{
	  octave_idx_type info;
	  ComplexCHOL fact (m, info);
	  if (nargout == 2 || info == 0)
	    {
	      if (! type_loaded) {       
		octave_tri::register_type ();
		install_tri_ops();
		type_loaded = true;
	      }

	      retval(1) = static_cast<double> (info);
	      retval(0) = fact.chol_matrix ();
	    }
	  else
	    error ("chol: matrix not positive definite");
	}
    }
  else
    {
      gripe_wrong_type_arg ("chol", arg);
    }

  return retval;
}

/*
%!shared c
%! c=chol([2,1;1,1]);
%!assert(c,sqrt([2,1/2;0,1/2]),10*eps);
%!assert(c\(c'\[1;1]),[0;1],10*eps); 
%!assert(typeinfo(c),"triangular matrix");
%!assert(c+1,sqrt([2,1/2;0,1/2])+1,10*eps);
%!assert(typeinfo(c+1),"matrix");
*/

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

