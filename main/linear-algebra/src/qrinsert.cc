/* Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
 * 
 * Author: Jaroslav Hajek <highegg@gmail.com>
 * 
 * This source is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

#include <oct.h>
#include <f77-fcn.h>

extern "C" 
{
  void F77_FCN (dqrinc, DQRINC) ( const int *m, 
                                  const int *n, 
                                  double *Q, 
                                  double *R, 
                                  const int *j,
                                  const double *x );

  void F77_FCN (zqrinc, ZQRINC) ( const int *m, 
                                  const int *n, 
                                  Complex *Q, 
                                  Complex *R, 
                                  const int *j,
                                  const Complex *x );

  void F77_FCN (dlacpy, DLACPY) ( const char *uplo,
                                  const int *m,
                                  const int *n,
                                  const double *A,
                                  const int *lda,
                                  double *B,
                                  const int *ldb );

  void F77_FCN (zlacpy, ZLACPY) ( const char *uplo,
                                  const int *m,
                                  const int *n,
                                  const Complex *A,
                                  const int *lda,
                                  Complex *B,
                                  const int *ldb );
}

static bool chkdimmat (const dim_vector& dims, int m, int n)
{
  return (dims (0) == m) && (dims (1) == n);
}

DEFUN_DLD (qrinsert, args, nargout,
"-*- texinfo -*-\n\
@deftypefn{Loadable Function} \
{[@var{Q1},@var{R1}]} = qrinsert(@var{Q},@var{R},@var{j},@var{x},@var{orient})\n\
Given a QR@tie{}factorization of a real or complex matrix @w{@var{A} = @var{Q}*@var{R}},\n\
@var{Q}@tie{}unitary and @var{R}@tie{}upper trapezoidal,\n\
this function returns the QR@tie{}factorization of @w{[A(:,1:j-1) x A(:,j:n)]},\n\
where @var{u} is a column vector to be inserted (if @var{orient} == 'col'),\n\
or the QR@tie{}factorization of @w{[A(1:j-1,:);x;A(:,j:n)]},\n\
where @var{x} is a row vector to be inserted (if @var{orient} == 'row').\n\
@var{orient} defaults to 'col'.\n\
\n\
@var{Q} must be square and @var{R} of the same shape as @var{A},\n\
i.e. the compact version computable with @code{qr(A,0)} cannot be \n\
used. \n\
@seealso{qr, qrupdate, qrdelete}\n\
@end deftypefn")
{
  int nargin = args.length ();
  octave_value_list retval;
  if (nargin < 4 || nargin > 5) 
    {
      print_usage ();
      return retval;
    }

  octave_value arg0 = args (0);
  octave_value arg1 = args (1);
  octave_value arg2 = args (2);
  octave_value arg3 = args (3);

  if ( !(arg0.is_complex_matrix () || arg0.is_real_matrix ()) 
       || !(arg1.is_complex_matrix () || arg1.is_real_matrix ()) 
       || !(arg2.is_scalar_type ()) 
       || !(arg3.is_complex_matrix () || arg3.is_real_matrix ()) ) 
    {
      print_usage ();
      return retval;
    }
  int m = arg1.rows (), n = arg1.columns ();
  bool row = false;

  if (nargin > 4) 
    {
      octave_value arg4 = args (4);
      if (arg4.is_string ()) 
        {
          std::string orient = arg4.string_value ();
          if (orient == "col" || orient == "column")
            row = false;
          else if (orient == "row")
            row = true;
          else 
            {
              error ("orient should be \"col\" or \"row\"");
              return retval;
            }
        } 
      else 
        {
          error ("orient should be a string");
          return retval;
        }
    }

  if (!chkdimmat (arg0.dims (), m, m) ||
      (!row && !chkdimmat (arg3.dims (), m, 1)) ||
      ( row && !chkdimmat (arg3.dims (), 1, n)) )
    {
      error ("qrinsert: dimension mismatch");
      return retval;
    }

  int j = arg2.scalar_value ();
  if (j < 1 || (row && j > m+1) || (!row && j > n+1))
    {
      error("index j out of range.");
      return retval;
    }

  if ( arg0.is_real_matrix () 
       && arg1.is_real_matrix () 
       && arg3.is_real_matrix () )
    {
      // all real case
      Matrix Q = arg0.matrix_value ();
      Matrix R = arg1.matrix_value ();
      Matrix x = arg3.matrix_value ();

      if (row) 
        {
          error ("row inserting is not yet implemented.");
          return retval;
        } 
      else 
        {
          Matrix R1 (m, n+1);
          int nn;
          // copy R with empty column
          nn = j-1;
          F77_XFCN (dlacpy, DLACPY, ( "0", &m, &nn,
                                      R.data (), &m,
                                      R1.fortran_vec (), &m ) );
          nn = n-j+1;
          F77_XFCN (dlacpy, DLACPY, ( "0", &m, &nn,
                                      R.data () + m*(j-1), &m,
                                      R1.fortran_vec () + m*j, &m ) );

          n++;
          // do the update
          F77_XFCN (dqrinc, DQRINC, ( &m, &n,
                                      Q.fortran_vec (),
                                      R1.fortran_vec (),
                                      &j,
                                      x.data () ) );

          retval (0) = Q;
          retval (1) = R1;
        }
      return retval;
    }
  else
    {
      // complex case
      ComplexMatrix Q = arg0.complex_matrix_value ();
      ComplexMatrix R = arg1.complex_matrix_value ();
      ComplexMatrix x = arg3.complex_matrix_value ();

      if (row) 
        {
          error ("row inserting is not yet implemented.");
          return retval;
        } 
      else 
        {
          ComplexMatrix R1 (m, n+1);
          int nn;
          // copy R with empty column
          nn = j-1;
          F77_XFCN (zlacpy, ZLACPY, ( "0", &m, &nn,
                                      R.data (), &m,
                                      R1.fortran_vec (), &m ) );
          nn = n-j+1;
          F77_XFCN (zlacpy, ZLACPY, ( "0", &m, &nn,
                                      R.data () + m*(j-1), &m,
                                      R1.fortran_vec () + m*j, &m ) );

          n++;
          // do the update
          F77_XFCN (zqrinc, ZQRINC, ( &m, &n,
                                      Q.fortran_vec (),
                                      R1.fortran_vec (),
                                      &j,
                                      x.data () ) );

          retval (0) = Q;
          retval (1) = R1;
        }
      return retval;
    }
}

/*
%!test
%! A = [0.091364  0.613038  0.999083;
%!      0.594638  0.425302  0.603537;
%!      0.383594  0.291238  0.085574;
%!      0.265712  0.268003  0.238409;
%!      0.669966  0.743851  0.445057 ];
%!
%! x = [0.85082;  
%!      0.76426;  
%!      0.42883;  
%!      0.53010;  
%!      0.80683 ];
%!
%! [Q,R] = qr(A);
%! [Q,R] = qrinsert(Q,R,3,x);
%! assert(norm(vec(Q'*Q - eye(5)),Inf) < 1e1*eps)
%! assert(norm(vec(triu(R)-R),Inf) == 0)
%! assert(norm(vec(Q*R - [A(:,1:2) x A(:,3)]),Inf) < norm(A)*1e1*eps)
%! 
%!test
%! A = [0.620405 + 0.956953i  0.480013 + 0.048806i  0.402627 + 0.338171i;
%!      0.589077 + 0.658457i  0.013205 + 0.279323i  0.229284 + 0.721929i;
%!      0.092758 + 0.345687i  0.928679 + 0.241052i  0.764536 + 0.832406i;
%!      0.912098 + 0.721024i  0.049018 + 0.269452i  0.730029 + 0.796517i;
%!      0.112849 + 0.603871i  0.486352 + 0.142337i  0.355646 + 0.151496i ];
%!
%! x = [0.20351 + 0.05401i;
%!      0.13141 + 0.43708i;
%!      0.29808 + 0.08789i;
%!      0.69821 + 0.38844i;
%!      0.74871 + 0.25821i ];
%!
%! [Q,R] = qr(A);
%! [Q,R] = qrinsert(Q,R,3,x);
%! assert(norm(vec(Q'*Q - eye(5)),Inf) < 1e1*eps)
%! assert(norm(vec(triu(R)-R),Inf) == 0)
%! assert(norm(vec(Q*R - [A(:,1:2) x A(:,3)]),Inf) < norm(A)*1e1*eps)
*/
