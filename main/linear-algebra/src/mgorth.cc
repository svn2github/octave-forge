/*
  Copyright (C) 2009 Carlo de Falco
  Copyright (C) 2010 VZLU Prague
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this file.  If not, see <http://www.gnu.org/licenses/>.
  
  Author: Carlo de Falco <cdf _AT_ users _DOT_ sourceforge _DOT_ net>
          Jaroslav Hajek <highegg@gmail.com>
*/


#include <octave/oct.h>
#include <octave/oct-norm.h>

template <class ColumnVector, class Matrix, class RowVector>
static void 
do_mgorth (ColumnVector& x, const Matrix& V, RowVector& h) 
{
  octave_idx_type Vc = V.columns ();
  h = RowVector (Vc + 1);
  for (octave_idx_type j = 0; j < Vc; j++)
    {
      ColumnVector Vcj = V.column (j);
      h(j) = RowVector (Vcj.hermitian ()) * x;
      x -= h(j) * Vcj;
    }

  h(Vc) = xnorm (x);
  if (real (h(Vc)) > 0)
    x = x / h(Vc);
}

DEFUN_DLD (mgorth, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn{Loadable Function} {[@var{y}, @var{h}] =} mgorth (@var{x}, @var{v})\n\
Orthogonalizes a given column vector @var{x} w.r.t. a given orthonormal basis\n\
@var{v}, using modified Gram-Schmidt orthogonalization. On exit, @var{y} is\n\
a unit vector such that:\n\
\n\
@example\n\
  norm (@var{y}) = 1\n\
  @var{v}' * @var{y} = 0\n\
  @var{x} = @var{h}*[@var{v}, @var{y}]\n\
@end example\n\
\n\
@end deftypefn")
{
  
  octave_value_list retval;
  int nargin = args.length();

  if (nargin == 2)
    {
      octave_value argx = args(0), argv = args(1);

      if (argv.ndims () != 2 || argx.ndims () != 2 || argx.columns () != 1
          || argv.rows () != argx.rows ())
        {
          error ("mgorth: V should me a matrix and x a column vector with"
                 " the same number of rows.");
          return retval;
        }

      bool iscomplex = (argx.is_complex_type () || argv.is_complex_type ());
      if (argx.is_single_type () || argv.is_single_type ())
        {
          if (iscomplex)
            {
              FloatComplexColumnVector x = argx.float_complex_column_vector_value ();
              FloatComplexMatrix V = argv.float_complex_matrix_value ();
              FloatComplexRowVector h;
              do_mgorth (x, V, h);
              retval(0) = x;
              retval(1) = h;
            }
          else
            {
              FloatColumnVector x = argx.float_column_vector_value ();
              FloatMatrix V = argv.float_matrix_value ();
              FloatRowVector h;
              do_mgorth (x, V, h);
              retval(0) = x;
              retval(1) = h;
            }
        }
      else if (argx.is_numeric_type () && argv.is_numeric_type ())
        {
          if (iscomplex)
            {
              ComplexColumnVector x = argx.complex_column_vector_value ();
              ComplexMatrix V = argv.complex_matrix_value ();
              ComplexRowVector h;
              do_mgorth (x, V, h);
              retval(0) = x;
              retval(1) = h;
            }
          else
            {
              ColumnVector x = argx.column_vector_value ();
              Matrix V = argv.matrix_value ();
              RowVector h;
              do_mgorth (x, V, h);
              retval(0) = x;
              retval(1) = h;
            }
        }
      else
        error ("mgorth: numeric arguments expected");
    }

  return retval;
}
