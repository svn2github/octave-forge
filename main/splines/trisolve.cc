/* Copyright (C) 2001  Kai Habel
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## 2001-02-19 Paul Kienzle
##    * common interface trisolve() for +/- cyclic, +/- symmetric
*/

#include <octave/oct.h>
#include <octave/f77-fcn.h>

// LAPACK 3.0 functions not in libcruft
extern "C" {
  extern int F77_FUNC (dgtsv, DGTSV)
    (const int &n, const int &nrhs, double *l, 
	  double *d, double *u, double *b, const int &ldb, int *info);

  extern int F77_FUNC (dptsv, DPTSV)
    (const int &n, const int &nrhs, double *d, 
	  double *e, double *b, const int &ldb, int *info);
}

DEFUN_DLD(trisolve, args, ,"\
Solve triangular systems.\n\
x = trisolve(d,e,b)\n\n\
Solves the symmetric positive definite tridiagonal system:\n\
  / d1 e1  0  . . .  0    0 \\     / b11 b12 . . . b1k \\\n\
  | e1 d2 e2  . . .  0    0 |     | b21 b22 . . . b2k |\n\
  |  0 e2 d3  . . .  0    0 | x = | b31 b22 . . . b3k |\n\
  |           . . .         |     |         . . .     |\n\
  \\  0  0  0  . . . en-1 dn /     \\ bn1 bn2 . . . bnk /\n\n\
If the system is not positive definite, then use the following form.\n\n\
x = trisolve(l,d,u,b)\n\n\
Solves the tridiagonal system:\n\
  / d1 u1  0  . . .  0    0 \\     / b11 b12 . . . b1k \\\n\
  | l1 d2 u2  . . .  0    0 |     | b21 b22 . . . b2k |\n\
  |  0 l2 d3  . . .  0    0 | x = | b31 b22 . . . b3k |\n\
  |           . . .         |     |         . . .     |\n\
  \\  0  0  0  . . . ln-1 dn /     \\ bn1 bn2 . . . bnk /\n\n\
x = trisolve(d,e,b,cl,cu)\n\n\
Solves the cyclic system with symmetric positive definite tridiagonal:\n\
  / d1 e1  0  . . .  0   cu \\     / b11 b12 . . . b1k \\\n\
  | e1 d2 e2  . . .  0    0 |     | b21 b22 . . . b2k |\n\
  |  0 e2 d3  . . .  0    0 | x = | b31 b22 . . . b3k |\n\
  |           . . .         |     |         . . .     |\n\
  \\ cl  0  0  . . . en-1 dn /     \\ bn1 bn2 . . . bnk /\n\n\
If the system is not positive definite, then use the following form.\n\n\
x = trisolve(l,d,u,b,cl,cu)\n\n\
Solves the cyclic tridiagonal system:\n\
  / d1 u1  0  . . .  0   cu \\     / b11 b12 . . . b1k \\\n\
  | l1 d2 u2  . . .  0    0 |     | b21 b22 . . . b2k |\n\
  |  0 l2 d3  . . .  0    0 | x = | b31 b22 . . . b3k |\n\
  |           . . .         |     |         . . .     |\n\
  \\ cl  0  0  . . . ln-1 dn /     \\ bn1 bn2 . . . bnk /\n\n\
Uses LAPACK routines DGTSVX or DPTSVX to solve the tridiagonal\n\
system.  Uses the Sherman-Morrison formula to extend the solution\n\
to the cyclic system. See Numerical Recipes, pp 73-75\n\
<http://lib-www.lanl.gov/numerical/bookc/c2-7.pdf>\n\
")
{
  octave_value_list retval;
  const int nargin = args.length();

  if (nargin == 3)
    {
      ColumnVector d(args(0).vector_value());
      ColumnVector e(args(1).vector_value());
      Matrix b(args(2).matrix_value());
      if ( error_state ) return retval;

      int n = d.length();
      int nrhs = b.columns();
      if (e.length() != n-1)
	{
	  error ("trisolve: e must be one shorter than d");
	  return retval;
	}
      if (b.rows() != n)
	{
	  error ("trisolve: b must have same number of rows as d");
	  return retval;
	}

      int info;
      F77_FUNC (dptsv, DPTSV) (n, nrhs, d.fortran_vec(), e.fortran_vec(), 
			      b.fortran_vec(), n, &info);
       
      if (info > 0)
	error ("trisolve: not positive definite---use trisolve(e,d,e,b).");
      else if (info < 0) // will never happen
	error ("trisolve: lapack dptsv called incorrectly.");
      else
	retval(0) = b;

    }
  else if (nargin == 5)
    {
      ColumnVector d(args(0).vector_value());
      ColumnVector e(args(1).vector_value());
      Matrix b(args(2).matrix_value());
      double cl = args(3).double_value();
      double cu = args(4).double_value();
      if ( error_state ) return retval;

      int n = d.length();
      int nrhs = b.columns();
      if (e.length() != n-1)
	{
	  error ("trisolve: e must be one shorter than d");
	  return retval;
	}
      if (b.rows() != n)
	{
	  error ("trisolve: b must have same number of rows as d");
	  return retval;
	}

      double gamma = -d(0);
      d(0) -= gamma;
      d(n-1) -= cl * cu / gamma;
      Matrix z(n, nrhs+1, 0);
      z(0,0) = gamma;
      z(n-1,0) = cl;
      z.insert(b, 0, 1);

      int info;
      F77_FUNC (dptsv, DPTSV) (n, nrhs+1, d.fortran_vec(), e.fortran_vec(), 
			      z.fortran_vec(), n, &info);

      if (info == 0)
	{
	  for (int i = 1; i <= nrhs; i++)
	    {
	      const double fact =
		(z(0,i) + cu*z(n-1,i)/gamma)
		/ (1.0 + z(0,0) + cu*z(n-1,0)/gamma);
	      for (int j = 0; j < n; j++) b(j,i-1) = z(j,i) - fact * z(j,0);
	    }
	}
      
      if (info > 0)
	error ("trisolve: not positive definite---use trisolve(e,d,e,b,cl,cu).");
      else if (info < 0) // will never happen
	error ("trisolve: lapack dptsv called incorrectly.");
      else
	retval(0) = b;

    }
  else if (nargin == 4)
    {
      ColumnVector l(args(0).vector_value());
      ColumnVector d(args(1).vector_value());
      ColumnVector u(args(2).vector_value());
      Matrix b(args(3).matrix_value());
      if ( error_state ) return retval;

      int n = d.length();
      int nrhs = b.columns();
      if (u.length() != n-1 || l.length() != n-1)
	{
	  error ("trisolve: l,u must be one shorter than d");
	  return retval;
	}
      if (b.rows() != n)
	{
	  error ("trisolve: b must have same number of rows as d");
	  return retval;
	}

      int info;
      F77_FUNC (dgtsv, DGTSV) (n, nrhs, l.fortran_vec(), d.fortran_vec(), 
			      u.fortran_vec(), b.fortran_vec(), n, &info);
       
      if (info > 0)
	error ("trisolve: singular system.");
      else if (info < 0) // will never happen
	error ("trisolve: lapack dptsv called incorrectly.");
      else
	retval(0) = b;

    }
  else if (nargin == 6)
    {
      ColumnVector l(args(0).vector_value());
      ColumnVector d(args(1).vector_value());
      ColumnVector u(args(2).vector_value());
      Matrix b(args(3).matrix_value());
      double cl = args(4).double_value();
      double cu = args(5).double_value();
      if ( error_state ) return retval;

      int n = d.length();
      int nrhs = b.columns();
      if (u.length() != n-1 || l.length() != n-1)
	{
	  error ("trisolve: l,u must be one shorter than d");
	  return retval;
	}
      if (b.rows() != n)
	{
	  error ("trisolve: b must have same number of rows as d");
	  return retval;
	}

      double gamma = -d(0);
      d(0) -= gamma;
      d(n-1) -= cl * cu / gamma;
      Matrix z(n, nrhs+1, 0);
      z(0,0) = gamma;
      z(n-1,0) = cl;
      z.insert(b, 0, 1);

      int info;
      F77_FUNC (dgtsv, DGTSV) (n, nrhs+1, l.fortran_vec(), d.fortran_vec(), 
			      u.fortran_vec(), z.fortran_vec(), n, &info);

      if (info == 0)
	{
	  for (int i = 1; i <= nrhs; i++)
	    {
	      const double fact =
		(z(0,i) + cu*z(n-1,i)/gamma)
		/ (1.0 + z(0,0) + cu*z(n-1,0)/gamma);
	      for (int j = 0; j < n; j++) b(j,i-1) = z(j,i) - fact * z(j,0);
	    }
	}
      
      if (info > 0)
	error ("trisolve: singular system.");
      else if (info < 0) // will never happen
	error ("trisolve: lapack dptsv called incorrectly.");
      else
	retval(0) = b;

    }
  else
    {
      print_usage ();
      return retval;
    }

  return retval;

}

/*

%!shared n,l,d,u,b,cl,cu
%! n=6; 
%! l=[ 0.16, 0.05, 0.56, 0.94, 0.87 ]';
%! d=[ 0.21, 0.51, 0.18, 0.56, 0.80, 0.69 ]';
%! u=[ 0.35, 0.46, 0.23, 0.55, 0.77 ]';
%! b=[ 0.63, 0.88, 0.13, 0.55, 0.01, 0.96;
%!    0.96, 0.83, 0.85, 0.04, 0.09, 0.01 ]';
%! cl=0.71;
%! cu=0.91;

%!test # disp(">trisolve(d,u,b)");
%! A=diag(u,-1)+diag(d+2)+diag(u,1);
%! assert(A*trisolve(d+2,u,b),b,10000*eps);

%!test # disp(">trisolve(l,d,u,b)");
%! A=diag(l,-1)+diag(d)+diag(u,1);
%! assert(A*trisolve(l,d,u,b),b,10000*eps);

%!test # disp(">trisolve(d,e,b,cl,cu)");
%! A=diag(cl,-n+1)+diag(u,-1)+diag(d+2)+diag(u,1)+diag(cu,n-1);
%! assert(A*trisolve(d+2,u,b,cl,cu),b,10000*eps);

%!test # disp(">trisolve(l,d,u,b,cl,cu)");
%! A=diag(cl,-n+1)+diag(l,-1)+diag(d)+diag(u,1)+diag(cu,n-1);
%! assert(A*trisolve(l,d,u,b,cl,cu),b,10000*eps);

 */
