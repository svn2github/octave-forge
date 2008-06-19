/* Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
 * 
 * Author: Jaroslav Hajek <highegg@gmail.com>
 * 
 * This file is part of OctGPR.
 * 
 * OctGPR is free software; you can redistribute it and/or modify
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
 * <http://www.gnu.org/licenses/>.  */

#include <cmath>
#include <oct.h>
#include <oct-cmplx.h>

inline double abs2(double x)
{
  return x*x;
}
inline double abs2(Complex x)
{
  return abs2(x. real()) + abs2(x.imag ());
}

/* distance functors */
template<typename T>
struct distfun_eu
{
  double operator() (octave_idx_type dim, const T *x, const T* y)
    {
      double d = 1, scl = 0;
      for (octave_idx_type i = 0; i < dim; i++)
        {
          double t = std::abs (x[i]-y[i]);
          if (scl < t)
            {
              d *= abs2 (scl/t);
              d += 1;
              scl = t;
            }
          else if (t != 0)
            d += abs2 (t/scl);
        }
      return scl * std::sqrt (d);
    }
};

template<typename T>
struct distfun_sqeu
{
  double operator() (octave_idx_type dim, const T *x, const T* y)
    {
      double d = 0;
      for (octave_idx_type i = 0; i < dim; i++)
        d += abs2(x[i]-y[i]);
      return d;
    }
};

template<typename T>
struct distfun_l1
{
  double operator() (octave_idx_type dim, const T *x, const T* y)
    {
      double d = 0;
      for (octave_idx_type i = 0; i < dim; i++)
        d += std::abs(x[i]-y[i]);
      return d;
    }
};

template<typename T>
struct distfun_max
{
  double operator() (octave_idx_type dim, const T *x, const T* y)
    {
      double d = 0;
      for (octave_idx_type i = 0; i < dim; i++)
        {
          double t = std::abs(x[i]-y[i]);
          if (t > d) d = t;
        }
      return d;
    }
};

template<typename T>
struct distfun_mw
{
  double p;
  distfun_mw (double _p) : p(_p) {}
  double operator() (octave_idx_type dim, const T *x, const T* y)
    {
      double d = 1, scl = 0;
      for (octave_idx_type i = 0; i < dim; i++)
        {
          double t = std::abs (x[i]-y[i]);
          if (scl < t)
            {
              d *= std::pow (scl/t, p);
              d += 1;
              scl = t;
            }
          else if (t != 0)
            d += std::pow (t/scl, p);
        }
      return scl * std::pow (d, 1/p);
    }
};

template<typename T, class distfun>
void
fill_dist_matrix (octave_idx_type dim, octave_idx_type nx, octave_idx_type ny,
                 const T *X, const T* Y, double *D, distfun df)
{
  octave_idx_type i,j;
  for (j = 0; j < ny; j++)
    {
      const T *PX = X;
      for (i = 0; i < nx; i++)
        {
          *(D++) = df (dim, PX, Y);
          PX += dim;
        }
      Y += dim;
    }
}

template<typename T, class distfun>
void
fill_dist_matrix (octave_idx_type dim, octave_idx_type nx, 
                 const T *X, double *D, distfun df)
{
  octave_idx_type i,j;
  for (j = 0; j < nx; j++)
    {
      D += j;
      for (i = -j; i < 0; i++)
        D[i] = *(D + i*nx);
      const T *PX = X;
      for (i = j; i < nx; i++)
        {
          *(D++) = df (dim, PX, X);
          PX += dim;
        }
      X += dim;
    }
}

template<typename T>
Matrix
get_dist_matrix (const MArray2<T>& X, bool ssq, double p = 0)
{
  Matrix D(X.rows (), X.rows ());

  MArray2<T> XT = X.transpose ();

  if (ssq)
    fill_dist_matrix (XT.rows (), XT.cols (),
                      XT.data (), D.fortran_vec (), distfun_sqeu<T> ());
  else if (p == 2)
    fill_dist_matrix (XT.rows (), XT.cols (),
                      XT.data (), D.fortran_vec (), distfun_eu<T> ());
  else if (p == 1)
    fill_dist_matrix (XT.rows (), XT.cols (),
                      XT.data (), D.fortran_vec (), distfun_l1<T> ());
  else if (xisinf (p))
    fill_dist_matrix (XT.rows (), XT.cols (),
                      XT.data (), D.fortran_vec (), distfun_max<T> ());
  else 
    fill_dist_matrix (XT.rows (), XT.cols (),
                      XT.data (), D.fortran_vec (), distfun_mw<T> (p));
  return D;

}

template<typename T>
Matrix
get_dist_matrix (const MArray2<T>& X, const MArray2<T>& Y, bool ssq, double p = 0)
{
  Matrix D(X.rows (), Y.rows ());

  MArray2<T> XT = X.transpose (), YT = Y.transpose ();

  if (ssq)
    fill_dist_matrix (XT.rows (), XT.cols (), YT.cols (),
                      XT.data (), YT.data (), D.fortran_vec (), distfun_sqeu<T> ());
  else if (p == 2)
    fill_dist_matrix (XT.rows (), XT.cols (), YT.cols (),
                      XT.data (), YT.data (), D.fortran_vec (), distfun_eu<T> ());
  else if (p == 1)
    fill_dist_matrix (XT.rows (), XT.cols (), YT.cols (),
                      XT.data (), YT.data (), D.fortran_vec (), distfun_l1<T> ());
  else if (xisinf (p))
    fill_dist_matrix (XT.rows (), XT.cols (), YT.cols (),
                      XT.data (), YT.data (), D.fortran_vec (), distfun_max<T> ());
  else 
    fill_dist_matrix (XT.rows (), XT.cols (), YT.cols (),
                      XT.data (), YT.data (), D.fortran_vec (), distfun_mw<T> (p));
  return D;

}

DEFUN_DLD(pdist2_mw,args,,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} @var{D} = pdist2_mw (@var{X}, @var{Y}, @var{p})\n\
@deftypefnx {Loadable Function} @var{D} = pdist2_mw (@var{X}, @var{p})\n\
Assembles a pairwise minkowski-distance matrix for two given sets of points.\n\
@var{X} and @var{Y} should be real or complex matrices with a point per row,\n\
so numbers of columns must match. The matrix contains the pairwise\n\
distances @code{D(i,j) = norm(X(i,:)-Y(j,:),P)}.\n\
@var{p} can also be the string \'ssq\' requesting squared euclidean distance.\n\
(not a metric, but often useful and faster than @code{@var{p}=2})\n\
If @var{Y} is not given, a symmetric distance matrix is calculated efficiently.\n\
@seealso{norm}\n\
@end deftypefn")
{
  int nargin = args.length();
  octave_value_list retval;

  if (nargin < 2 || nargin > 3)
    {
      print_usage ();
      return retval;
    }

  octave_value argx = args(0), argy, argp;
  bool sym = false;

  if (nargin > 2) 
    argy = args(1);
  else
    { 
      argy = argx;
      sym = true;
    }

  if (nargin > 2) 
    argp = args(2);
  else
    argp = args(1);

  bool ssq = (argp.is_string () && argp.string_value () == "ssq");

  if (argx.is_matrix_type () && argy.is_matrix_type () && (ssq || argp.is_real_scalar ())) 
    {
      double p = ssq ? 0 : argp.scalar_value ();

      if (argx.columns () == argy.columns ())
        {
          if (argx.is_real_matrix () && argy.is_real_matrix ())
            {
              if (sym)
                retval(0) = get_dist_matrix (argx.matrix_value (), 
                                             ssq, p);
              else
                retval(0) = get_dist_matrix (argx.matrix_value (), 
                                             argy.matrix_value (), 
                                             ssq, p);
            } 
          else 
            {
              if (sym)
                retval(0) = get_dist_matrix (argx.complex_matrix_value (), 
                                             ssq, p);
              else
                retval(0) = get_dist_matrix (argx.complex_matrix_value (), 
                                             argy.complex_matrix_value (), 
                                             ssq, p);
            }
        }
      else
        error ("pmwdmat: dimension mismatch");
    }
  else
    error ("pmwdmat: X and Y should be matrices, p a real scalar");

  return retval;
}
