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
  void F77_FCN (dqrdec, DQRDEC) ( const int *m, 
                                  const int *n, 
                                  double *Q, 
                                  double *R, 
                                  const int *j );

  void F77_FCN (zqrdec, ZQRDEC) ( const int *m, 
                                  const int *n, 
                                  Complex *Q, 
                                  Complex *R, 
                                  const int *j );

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

DEFUN_DLD (qrdelete, args, nargout,
"-*- texinfo -*-\n\
@deftypefn{Loadable Function} \
{[@var{Q1},@var{R1}]} = qrdelete(@var{Q},@var{R},@var{j},@var{orient})\n\
Given a QR@tie{}factorization of a real or complex matrix @w{@var{A} = @var{Q}*@var{R}},\n\
@var{Q}@tie{}unitary and @var{R}@tie{}upper trapezoidal,\n\
this function returns the QR@tie{}factorization of @w{[A(:,1:j-1) A(:,j+1:n)]},\n\
with one column deleted (if @var{orient} == 'col'),\n\
or the QR@tie{}factorization of @w{[A(1:j-1,:);A(:,j+1:n)]},\n\
with one row deleted (if @var{orient} == 'row').\n\
@var{orient} defaults to 'col'.\n\
\n\
@var{Q} must be square and @var{R} of the same shape as @var{A},\n\
i.e. the compact version computable with @code{qr(A,0)} cannot be \n\
used.\n\
@seealso{qr, qrinsert, qrupdate}\n\
@end deftypefn")
{
  int nargin = args.length ();
  octave_value_list retval;
  if (nargin < 3 || nargin > 4) 
    {
      print_usage ();
      return retval;
    }

  octave_value arg0 = args (0);
  octave_value arg1 = args (1);
  octave_value arg2 = args (2);

  if ( !(arg0.is_complex_matrix () || arg0.is_real_matrix ()) 
       || !(arg1.is_complex_matrix () || arg1.is_real_matrix ()) 
       || !(arg2.is_scalar_type ()) )
    {
      print_usage ();
      return retval;
    }
  int m = arg1.rows (), n = arg1.columns ();
  bool row = false;

  if (nargin > 3) 
    {
      octave_value arg3 = args (3);
      if (arg3.is_string ()) 
        {
          std::string orient = arg3.string_value ();
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

  if (!chkdimmat (arg0.dims (), m, m) )
    {
      error ("qrdelete: dimension mismatch");
      return retval;
    }

  int j = arg2.scalar_value ();
  if (j < 1 || (row && j > m) || (!row && j > n))
    {
      error("index j out of range.");
      return retval;
    }

  if ( arg0.is_real_matrix () 
       && arg1.is_real_matrix () )
    {
      // all real case
      Matrix Q = arg0.matrix_value ();
      Matrix R = arg1.matrix_value ();

      if (m > 0 && n > 0)
        if (row) 
          {
            error ("row inserting is not yet implemented.");
            return retval;
          } 
        else 
          {
            Matrix R1 (m, n-1);
            int nn;
            // copy R with empty column
            nn = j-1;
            F77_XFCN (dlacpy, DLACPY, ( "0", &m, &nn,
                                        R.data (), &m,
                                        R1.fortran_vec (), &m ) );
            nn = n-j;
            F77_XFCN (dlacpy, DLACPY, ( "0", &m, &nn,
                                        R.data () + m*j, &m,
                                        R1.fortran_vec () + m*(j-1), &m ) );

            n--;
            // do the downdate
            F77_XFCN (dqrdec, DQRDEC, ( &m, &n,
                                        Q.fortran_vec (),
                                        R1.fortran_vec (),
                                        &j ) );

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

      if (row) 
        {
          error ("row deleting is not yet implemented.");
          return retval;
        } 
      else 
        {
          ComplexMatrix R1 (m, n-1);
          int nn;
          // copy R with empty column
          nn = j-1;
          F77_XFCN (zlacpy, ZLACPY, ( "0", &m, &nn,
                                      R.data (), &m,
                                      R1.fortran_vec (), &m ) );
          nn = n-j;
          F77_XFCN (zlacpy, ZLACPY, ( "0", &m, &nn,
                                      R.data () + m*j, &m,
                                      R1.fortran_vec () + m*(j-1), &m ) );

          n--;
          // do the update
          F77_XFCN (zqrdec, ZQRDEC, ( &m, &n,
                                      Q.fortran_vec (),
                                      R1.fortran_vec (),
                                      &j ) );

          retval (0) = Q;
          retval (1) = R1;
        }
      return retval;
    }
}
 
/*
%!test
%! A = [0.091364  0.613038  0.027504  0.999083;
%!      0.594638  0.425302  0.562834  0.603537;
%!      0.383594  0.291238  0.742073  0.085574;
%!      0.265712  0.268003  0.783553  0.238409;
%!      0.669966  0.743851  0.457255  0.445057 ];
%!
%! [Q,R] = qr(A);
%! [Q,R] = qrdelete(Q,R,3);
%! assert(norm(vec(Q'*Q - eye(5)),Inf) < 1e1*eps)
%! assert(norm(vec(triu(R)-R),Inf) == 0)
%! assert(norm(vec(Q*R - [A(:,1:2) A(:,4)]),Inf) < norm(A)*1e1*eps)
%! 
%!test
%! A = [0.364554 + 0.993117i  0.669818 + 0.510234i  0.426568 + 0.041337i  0.847051 + 0.233291i;
%!      0.049600 + 0.242783i  0.448946 + 0.484022i  0.141155 + 0.074420i  0.446746 + 0.392706i;
%!      0.581922 + 0.657416i  0.581460 + 0.030016i  0.219909 + 0.447288i  0.201144 + 0.069132i;
%!      0.694986 + 0.000571i  0.682327 + 0.841712i  0.807537 + 0.166086i  0.192767 + 0.358098i;
%!      0.945002 + 0.066788i  0.350492 + 0.642638i  0.579629 + 0.048102i  0.600170 + 0.636938i ] * I;
%!
%! [Q,R] = qr(A);
%! [Q,R] = qrdelete(Q,R,3);
%! assert(norm(vec(Q'*Q - eye(5)),Inf) < 1e1*eps)
%! assert(norm(vec(triu(R)-R),Inf) == 0)
%! assert(norm(vec(Q*R - [A(:,1:2) A(:,4)]),Inf) < norm(A)*1e1*eps)
*/
