// Copyright (C) 2009 Carlo de Falco <cdf@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

#include <octave/oct.h>
#include <octave/parse.h>
#include <octave/oct-norm.h>
#include <iostream>

class matrixfreematrix
{
public:
  virtual ColumnVector operator * (ColumnVector) = 0;
};

class matrixfreematrixfun: public  matrixfreematrix
{
private:
    octave_function *fun;
public:
  matrixfreematrixfun  (octave_value);
  ColumnVector operator * (ColumnVector);
};

class matrixfreematrixmat: public  matrixfreematrix
{
private:
    SparseMatrix mat;
public:
  matrixfreematrixmat  (octave_value);
  ColumnVector operator * (ColumnVector);
};

class matrixfreematrixinvmat: public  matrixfreematrix
{
private:
  SparseMatrix mat;
public:
  matrixfreematrixinvmat  (octave_value);
  ColumnVector operator * (ColumnVector);
};

bool converged (double pbn, double prn, octave_idx_type iter,
                double prtol, octave_idx_type max_it)
{
  return (((prtol != 0) && (prn <= prtol*pbn)) || (iter >= max_it));
}

//----------------------//----------------------//
DEFUN_DLD(pgmres,args,nargout,"\
\n [x, resids] = pgmres (A, b, x0, rtol, maxit, m, P)\
\n\
\n   Solves A x = b using the Preconditioned GMRES iterative method\
\n   with restart a.k.a. PGMRES(m).\
\n\n   rtol is the relative tolerance,\
\n   maxit the maximum number of iterations,\
\n   x0 the initial guess and \
\n   m is the restart parameter.\
\n\n   A can be passed as a matrix or as a function handle or \
\n   inline function f such that f(x) = A*x.\
\n\n   The preconditioner P can be passed as a matrix or as a function handle or \
\n   inline function g such that g(x) = P\\x.\n\n")
{
  
  warning("'pgmres' has been deprecated in favor of 'gmres' now part of Octave core. This function will be removed from future versions of the 'linear-algebra' package");
  octave_value_list retval;
  int nargin = args.length();
  
  if (nargin != 7)
    {
      print_usage ();
    }
  else
    {
      
      matrixfreematrix *A=NULL, *invP=NULL;
      Matrix V, H;
      
      ColumnVector b, x0, x_old, res, B, resids;
      ColumnVector x, tmp, Y, little_res, ret;
      double  prtol, prn, pbn;
      octave_idx_type max_it, restart, iter = 0, reit;
      
      // arg #1
      if (args(0).is_function_handle () || args(0).is_inline_function ())
        A = new matrixfreematrixfun (args (0));
      else if (args(0).is_real_matrix ())
        A = new matrixfreematrixmat (args (0));
      else
        error ("pgmres: first argument is expected to be a function or matrix");
      
      // arg #2
      b = args(1).column_vector_value ();
      // arg #3
      x0 = args(2).column_vector_value ();
      // arg #4
      prtol = args(3).double_value ();
      // arg #5
      max_it = args(4).idx_type_value ();
      // arg #6
      restart = args(5).idx_type_value ();
      // arg #7
      if (args(6).is_function_handle () || args(6).is_inline_function ())
        invP = new matrixfreematrixfun (args (6));
      else if (args(6).is_real_matrix ())
        invP = new matrixfreematrixinvmat (args (6));
      else
        error ("pgmres: last argument is expected to be a function or matrix");

      if (! error_state)
        {
          x_old = x0; 
          x = x_old;
          res = b - (*A) * x_old;
          res = (*invP) * res;
          prn = xnorm (res, 2.0);
          
          B = ColumnVector (restart + 1, 0.0);
          B(0) = prn;
          
          //begin loop
          iter = 0;
          reit = restart + 1;
          resids(0) = prn;
          pbn = xnorm ((*invP) * b, 2.0);
          
          while (! converged(pbn, prn, iter, prtol, max_it))
            {
              
              // restart
              if (reit > restart)
                {
                  reit = 1;
                  x_old = x;
                  res = b - (*A) * x_old;
                  res = (*invP) * res;
                  prn = xnorm (res, 2.0);
                  B(0) = prn;
                  H = Matrix (1, 1, 0.0);
                  V = Matrix (b.length (), 1, 0.0);
                  for (octave_idx_type ii = 0; ii < V.rows (); ii++)
                    V(ii,0) = res(ii) / prn;
                }
              
              //basic iteration
              tmp = (*A) * (V.column (reit-1));
              tmp = (*invP) * tmp;
              
              H.resize (reit+1, reit, 0.0);
              for (octave_idx_type j = 0; j < reit; j++)
                {
                  H(j, reit-1) = (V.column (j).transpose ()) * tmp;
                  tmp = tmp - (H (j, reit-1) * V.column (j));
                }
              
              H(reit, reit-1) = xnorm (tmp, 2.0);
              V = V.append (tmp / H(reit, reit-1));
              
              Y = (H.lssolve (B.extract_n (0, reit+1)));
              
              little_res = B.extract_n (0,reit+1) - H * Y.extract_n (0,reit);
              prn = xnorm (little_res, 2.0);
              
              x = x_old + V.extract_n (0, 0, V.rows (), reit) * Y.extract_n (0, reit);
              
              resids.resize (iter+1);
              resids(iter++) = prn ;
              reit++ ;
            }
          
          retval(1) = octave_value(resids);
          retval(0) = octave_value(x);
        }
      else
        print_usage ();
      
      delete A;
      delete invP;
    }
  
  return retval;
}


//----------------------//----------------------//

matrixfreematrixfun::matrixfreematrixfun  (octave_value A)
{
  fun = A.function_value ();
  if (error_state)
    error ("error extracting function from first argument");
}
  
ColumnVector matrixfreematrixfun::operator * (ColumnVector b)
{
  ColumnVector res;
  octave_value_list retval;
  retval = feval (fun, octave_value(b), 1);
  res = retval(0).column_vector_value ();
  if ( error_state)
    {
      error ("error applying linear operator");
    }
  return res;
}

//----------------------//----------------------//
matrixfreematrixmat::matrixfreematrixmat  (octave_value A)
{
  mat = A.sparse_matrix_value ();
  if (error_state)
    error ("error extracting matrix value from first argument");
}

ColumnVector matrixfreematrixmat::operator * (ColumnVector b)
{
  return ColumnVector (mat * Matrix(b));
}

//----------------------//----------------------//
matrixfreematrixinvmat::matrixfreematrixinvmat  (octave_value A)
{
  mat = A.sparse_matrix_value ();
  if (error_state)
    error ("error extracting matrix value from first argument");
}

ColumnVector matrixfreematrixinvmat::operator * (ColumnVector b)
{
  return mat.solve(b);
}

/*

%!shared A, b, dim
%!test
%! dim = 300;
%! A = spdiags ([-ones(dim,1) 2*ones(dim,1) ones(dim,1)], [-1:1], dim, dim);
%! b =  ones(dim, 1); 
%! [x, resids] = pgmres (A, b, b, 1e-10,dim, dim, @(x) x./diag(A));
%! assert(x, A\b, 1e-9*norm(x,inf))
%!
%!test
%! [x, resids] = pgmres (A, b, b, 1e-10, 1e4, dim, @(x) diag(diag(A))\x);
%! assert(x, A\b, 1e-7*norm(x,inf))
%!
%!test
%! A = sprandn (dim, dim, .1);
%! A = A'*A;
%! b = rand (dim, 1);
%! [x, resids] = pgmres (@(x) A*x, b, b, 1e-10, dim, dim, @(x) diag(diag(A))\x);
%! assert(x, A\b, 1e-9*norm(x,inf))
%! [x, resids] = pgmres (A, b, b, 1e-10, dim, dim, @(x) diag(diag(A))\x);
%! assert(x, A\b, 1e-9*norm(x,inf))
%!
%!test
%! [x, resids] = pgmres (A, b, b, 1e-10, 1e6, dim, @(x) x./diag(A));
%! assert(x, A\b, 1e-7*norm(x,inf))

*/
