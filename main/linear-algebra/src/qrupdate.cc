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
  void F77_FCN (dqr1up, DQR1UP) ( const int *m, 
                                  const int *n, 
                                  double *Q, 
                                  double *R, 
                                  const double *u,
                                  const double *v );

  void F77_FCN (zqr1up, ZQR1UP) ( const int *m, 
                                  const int *n, 
                                  Complex *Q, 
                                  Complex *R, 
                                  const Complex *u,
                                  const Complex *v );
}

static bool chkdimmat (const dim_vector& dims, int m, int n)
{
  return (dims (0) == m) && (dims (1) == n);
}

DEFUN_DLD (qrupdate, args, nargout,
"-*- texinfo -*-\n\
@deftypefn{Loadable Function}\
{[@var{Q1},@var{R1}]} = qrupdate(@var{Q},@var{R},@var{u},@var{v})\n\
Given a QR@tie{}factorization of a real or complex matrix @w{@var{A} = @var{Q}*@var{R}},\n\
@var{Q}@tie{}unitary and @var{R}@tie{}upper trapezoidal,\n\
this function returns the QR@tie{}factorization of @w{@var{A} + @var{u}*@var{v}'},\n\
where @var{u} and @var{v} are column vectors (rank-1 update).\n\
\n\
@var{Q} must be square and @var{R} of the same shape as @var{A},\n\
i.e. the compact version computable with @code{qr(A,0)} cannot be\n\
used.\n\
@seealso{qr, qrinsert, qrdelete}\n\
@end deftypefn")
{
  int nargin = args.length ();
  octave_value_list retval;
  if (nargin != 4) 
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
       || !(arg2.is_complex_matrix () || arg2.is_real_matrix ()) 
       || !(arg3.is_complex_matrix () || arg3.is_real_matrix ()) )
    {
      print_usage ();
      return retval;
    }
  int m = arg1.rows (), n = arg1.columns ();
  if ( !chkdimmat (arg0.dims (), m, m) 
       || !chkdimmat (arg2.dims (), m, 1) 
       || !chkdimmat (arg3.dims (), n, 1) )
    {
      error ("qrupdate: dimension mismatch (column vectors required)");
      return retval;
    }

  if ( arg0.is_real_matrix () 
       && arg1.is_real_matrix () 
       && arg2.is_real_matrix () 
       && arg3.is_real_matrix () )
    {
      // all real case
      Matrix Q = arg0.matrix_value ();
      Matrix R = arg1.matrix_value ();
      Matrix u = arg2.matrix_value ();
      Matrix v = arg3.matrix_value ();

      if (m > 0 && n > 0)
        F77_XFCN (dqr1up, DQR1UP, ( &m, &n,
                                    Q.fortran_vec (),
                                    R.fortran_vec (),
                                    u.data (),
                                    v.data () ));
      // else just return original Q,R
      retval (0) = Q;
      retval (1) = R;
      return retval;
    }
  else
    {
      // complex case
      ComplexMatrix Q = arg0.complex_matrix_value ();
      ComplexMatrix R = arg1.complex_matrix_value ();
      ComplexMatrix u = arg2.complex_matrix_value ();
      ComplexMatrix v = arg3.complex_matrix_value ();

      if (m > 0 && n > 0)
        F77_XFCN (zqr1up, ZQR1UP, ( &m, &n,
                                    Q.fortran_vec (),
                                    R.fortran_vec (),
                                    u.data (),
                                    v.data () ));
      // else just return original Q,R
      retval (0) = Q;
      retval (1) = R;
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
%! u = [0.85082;  
%!      0.76426;  
%!      0.42883;  
%!      0.53010;  
%!      0.80683 ];
%!
%! v = [0.98810;
%!      0.24295;
%!      0.43167 ];
%!
%! [Q,R] = qr(A);
%! [Q,R] = qrupdate(Q,R,u,v);
%! assert(norm(vec(Q'*Q - eye(5)),Inf) < 1e1*eps)
%! assert(norm(vec(triu(R)-R),Inf) == 0)
%! assert(norm(vec(Q*R - A - u*v'),Inf) < norm(A)*1e1*eps)
%! 
%!test
%! A = [0.620405 + 0.956953i  0.480013 + 0.048806i  0.402627 + 0.338171i;
%!      0.589077 + 0.658457i  0.013205 + 0.279323i  0.229284 + 0.721929i;
%!      0.092758 + 0.345687i  0.928679 + 0.241052i  0.764536 + 0.832406i;
%!      0.912098 + 0.721024i  0.049018 + 0.269452i  0.730029 + 0.796517i;
%!      0.112849 + 0.603871i  0.486352 + 0.142337i  0.355646 + 0.151496i ];
%!
%! u = [0.20351 + 0.05401i;
%!      0.13141 + 0.43708i;
%!      0.29808 + 0.08789i;
%!      0.69821 + 0.38844i;
%!      0.74871 + 0.25821i ];
%!
%! v = [0.85839 + 0.29468i;
%!      0.20820 + 0.93090i;
%!      0.86184 + 0.34689i ];
%!
%! [Q,R] = qr(A);
%! [Q,R] = qrupdate(Q,R,u,v);
%! assert(norm(vec(Q'*Q - eye(5)),Inf) < 1e1*eps)
%! assert(norm(vec(triu(R)-R),Inf) == 0)
%! assert(norm(vec(Q*R - A - u*v'),Inf) < norm(A)*1e1*eps)
*/
