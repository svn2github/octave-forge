/*

Copyright (C) 1996, 1997 John W. Eaton
Copyright (C) 2006 Pascal Dupuis

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
Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.

*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include "CmplxGSVD.h"
#include "dbleGSVD.h"

#include "defun-dld.h"
#include "error.h"
#include "gripes.h"
#include "oct-obj.h"
#include "pr-output.h"
#include "utils.h"

DEFUN_DLD (gsvd, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{s} =} gsvd (@var{a}, @var{b})\n\
@deftypefnx {Loadable Function} {[@var{u}, @var{v}, @var{c}, @var{s}, @var{x}] =} gsvd (@var{a}, @var{b})\n\
@cindex generalised singular value decomposition\n\
Compute the generalised singular value decomposition of (@var{a}, @var{b})\n\
@iftex\n\
@tex\n\
$$\n\
 U^H A X = C R\n\
 V^H B X = S R\n\
 C*C + S*S = eye(columns(A))\n\
 R is upper triangular\n\
$$\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
\n\
@example\n\
u' * a * x = c * r\n\
v' * b * x = s * r'\n\
c * c + s * s = eye(columns(a))\n\
r is upper triangular\n\
@end example\n\
@end ifinfo\n\
\n\
The function @code{gsvd} normally returns the vector of singular values.\n\
If asked for three return values, it computes\n\
@iftex\n\
@tex\n\
$U$, $S$, and $V$.\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
U, S, and V.\n\
@end ifinfo\n\
For example,\n\
\n\
@example\n\
svd (hilb (3))\n\
@end example\n\
\n\
@noindent\n\
returns\n\
\n\
@example\n\
ans =\n\
\n\
  1.4083189\n\
  0.1223271\n\
  0.0026873\n\
@end example\n\
\n\
@noindent\n\
and\n\
\n\
@example\n\
[u, s, v] = svd (hilb (3))\n\
@end example\n\
\n\
@noindent\n\
returns\n\
\n\
@example\n\
u =\n\
\n\
  -0.82704   0.54745   0.12766\n\
  -0.45986  -0.52829  -0.71375\n\
  -0.32330  -0.64901   0.68867\n\
\n\
s =\n\
\n\
  1.40832  0.00000  0.00000\n\
  0.00000  0.12233  0.00000\n\
  0.00000  0.00000  0.00269\n\
\n\
v =\n\
\n\
  -0.82704   0.54745   0.12766\n\
  -0.45986  -0.52829  -0.71375\n\
  -0.32330  -0.64901   0.68867\n\
@end example\n\
\n\
If given a second argument, @code{svd} returns an economy-sized\n\
decomposition, eliminating the unnecessary rows or columns of @var{u} or\n\
@var{v}.\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin < 2 || nargin > 2 || (nargout > 1 && (nargout < 5 || nargout > 6)))
    {
      print_usage ("gsvd");
      return retval;
    }

  octave_value argA = args(0), argB = args(1);

  octave_idx_type nr = argA.rows ();
  octave_idx_type nc = argA.columns ();

  octave_idx_type  nn = argB.rows ();
  octave_idx_type  np = argB.columns ();
  
  if (nr == 0 || nc == 0)
    {
      if (nargout >= 5)
	{ 
	  for (int i = 3; i <= nargout; i++)
	    retval(i) = identity_matrix (nr, nr);
	  retval(2) = Matrix (nr, nc);
	  retval(1) = identity_matrix (nc, nc);
	  retval(0) = identity_matrix (nc, nc);
	}
      else
	retval(0) = Matrix (0, 1);
    }
  else
    {
      if ((nc != np) || (nn != np))
	{
	  print_usage ("gsvd");
	  return retval;
	}

      GSVD::type type = ((nargout == 0 || nargout == 1)
			? GSVD::sigma_only
			: GSVD::economy );

      if (argA.is_real_type () && argB.is_real_type ())
	{
	  Matrix tmpA = argA.matrix_value ();
	  Matrix tmpB = argB.matrix_value ();

	  if (! error_state)
	    {
	      if (tmpA.any_element_is_inf_or_nan ())
		{
		  error ("gsvd: cannot take GSVD of matrix containing Inf or NaN values"); 
		  return retval;
		}
	      
	      if (tmpB.any_element_is_inf_or_nan ())
		{
		  error ("gsvd: cannot take GSVD of matrix containing Inf or NaN values"); 
		  return retval;
		}
	      

	      GSVD result (tmpA, tmpB, type);

	      // DiagMatrix sigma = result.singular_values ();

	      if (nargout == 0 || nargout == 1)
		{
		  DiagMatrix sigA =  result.singular_values_A ();
		  DiagMatrix sigB =  result.singular_values_B ();
		  for (int i = 0; i < nc; i++)
		    tmpA.xelem(i, i) /= tmpB.xelem(i, i);
		  retval(0) = sigA.diag();
		}
	      else
		{ 
		  if (nargout > 5) retval(5) = result.R_matrix ();
		  retval(4) = result.right_singular_matrix ();
		  retval(3) = result.singular_values_B ();
		  retval(2) = result.singular_values_A ();
		  retval(1) = result.left_singular_matrix_B ();
		  retval(0) = result.left_singular_matrix_A ();
		}
	    }
	}
      else if (argA.is_complex_type () || argB.is_complex_type ())
	{
	  ComplexMatrix ctmpA = argA.complex_matrix_value ();
	  ComplexMatrix ctmpB = argB.complex_matrix_value ();

	  if (! error_state)
	    {
	      if (ctmpA.any_element_is_inf_or_nan ())
		{
		  error ("gsvd: cannot take GSVD of matrix containing Inf or NaN values"); 
		  return retval;
		}
	      if (ctmpB.any_element_is_inf_or_nan ())
		{
		  error ("gsvd: cannot take GSVD of matrix containing Inf or NaN values"); 
		  return retval;
		}

	      ComplexGSVD result (ctmpA, ctmpB, type);

	      // DiagMatrix sigma = result.singular_values ();

	      if (nargout == 0 || nargout == 1)
		{
		  DiagMatrix sigA =  result.singular_values_A ();
		  DiagMatrix sigB =  result.singular_values_B ();
		  for (int i = 0; i < nc; i++)
		    ctmpA.xelem(i, i) /= ctmpB.xelem(i, i);
		  retval(0) = sigA.diag();
		}
	      else
		{
		  if (nargout > 5) retval(5) = result.R_matrix ();
		  retval(4) = result.right_singular_matrix ();
		  retval(3) = result.singular_values_B ();
		  retval(2) = result.singular_values_A ();
		  retval(1) = result.left_singular_matrix_B ();
		  retval(0) = result.left_singular_matrix_A ();
		}
	    }
	}
      else
	{
	  gripe_wrong_type_arg ("gsvd", argA);
	  gripe_wrong_type_arg ("gsvd", argB);
	  return retval;
	}
    }

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
