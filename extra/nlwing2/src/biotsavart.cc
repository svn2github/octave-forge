/* Copyright (C) 2009  VZLU Prague, a.s., Czech Republic
 * 
 * Author: Jaroslav Hajek <highegg@gmail.com>
 * 
 * This file is part of NLWing2.
 * 
 * NLWing2 is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
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

#include <oct.h>
#include <f77-fcn.h>

extern "C" 
{
  F77_RET_T
  F77_FUNC (bisavf, BISAVF) (const octave_idx_type& m, const octave_idx_type& n, 
                             const double *CP,
                             const double *X, const double *dir,
                             double *vi);
  F77_RET_T
  F77_FUNC (bisanf, BISANF) (const octave_idx_type& m, const octave_idx_type& n, 
                             const double *CP, const double *CN,
                             const double *X, const double *dir,
                             double *vn);

  F77_RET_T
  F77_FUNC (bisavb, BISAVB) (const octave_idx_type& m, const octave_idx_type& n, 
                             const double *CP,
                             const double *X, const double *Y,
                             double *vi);
  F77_RET_T
  F77_FUNC (bisanb, BISANB) (const octave_idx_type& m, const octave_idx_type& n, 
                             const double *CP, const double *CN,
                             const double *X, const double *Y,
                             double *vn);

  F77_RET_T
  F77_FUNC (bisavc, BISAVC) (const octave_idx_type& m, const octave_idx_type& n, 
                             const double *CP,
                             const double *X,
                             double *vi, double *work);
  F77_RET_T
  F77_FUNC (bisanc, BISANC) (const octave_idx_type& m, const octave_idx_type& n, 
                             const double *CP, const double *CN,
                             const double *X,
                             double *vn, double *work);

}

static void 
gripe_invalid_dimensions (void)
{
  error ("biotsavart: invalid dimensions");
}

DEFUN_DLD (biotsavart, args, ,
"-*- texinfo -*-\n\
@deftypefn{Loadable Function} {vi} = biotsavart (@dots{})\n\
Calculates vortex-induced velocities using Biot-Savart law.\n\
@deftypefnx{Loadable Function} {vi} = biotsavart (@var{cp}, @var{x}, @var{dir}, \"f\")\n\
@code{@var{vi}(i,j,1:3)} is the velocity induced in @code{@var{cp}(i,1:3)}\n\
by a vortex ray starting in @code{@var{x}(j,1:3)} and going in the direction @var{dir(1:3)}.\n\
@deftypefnx{Loadable Function} {vn} = biotsavart (@var{cp}, @var{cn}, @var{x}, @var{dir}, \"fn\")\n\
@code{@var{vi}(i,j,1:3)} is the velocity induced in @code{@var{cp}(i,1:3)}\n\
in the direction @code{@var{cn}(i,1:3)}\n\
by a vortex ray starting in @code{@var{x}(j,1:3)} and going in the direction @var{dir(1:3)}.\n\
@deftypefnx{Loadable Function} {vi} = biotsavart (@var{cp}, @var{x}, @var{y}, \"b\")\n\
@code{@var{vi}(i,j,1:3)} is the velocity induced in @code{@var{cp}(i,1:3)}\n\
by a vortex segment joining @code{@var{x}(j,1:3)} and @code{@var{y}(j,1:3)}.\n\
@deftypefnx{Loadable Function} {vn} = biotsavart (@var{cp}, @var{cn}, @var{x}, @var{y}, \"bn\")\n\
@code{@var{vi}(i,j,1:3)} is the velocity induced in @code{@var{cp}(i,1:3)}\n\
in the direction @code{@var{cn}(i,1:3)}\n\
by a vortex segment joining @code{@var{x}(j,1:3)} and @code{@var{y}(j,1:3)}.\n\
@deftypefnx{Loadable Function} {vi} = biotsavart (@var{cp}, @var{x}, \"c\")\n\
@code{@var{vi}(i,j,1:3)} is the velocity induced in @code{@var{cp}(i,1:3)}\n\
by a vortex segment joining @code{@var{x}(j,1:3)} and @code{@var{x}(j+1,1:3)}.\n\
@deftypefnx{Loadable Function} {vn} = biotsavart (@var{cp}, @var{cn}, @var{x}, \"cn\")\n\
@code{@var{vi}(i,j,1:3)} is the velocity induced in @code{@var{cp}(i,1:3)}\n\
in the direction @code{@var{cn}(i,1:3)}\n\
by a vortex segment joining @code{@var{x}(j,1:3)} and @code{@var{x}(j+1,1:3)}.\n\
@end deftypefn")
{
  int nargin = args.length ();
  octave_value retval;

  std::string opts;

  if (nargin < 3 || nargin > 5)
    print_usage ();
  else
    opts = args(nargin-1).string_value ();

  bool normals = false;
  char optc;

  if (! error_state)
    {
      switch (opts.size ())
        {
        case 2:
          normals = opts[1] == 'n';
          // fall through
        case 1:
          optc = opts[0];
          break;
        default:
          error ("biotsavart: invalid options");
        }
    }

  switch (optc)
    {
    case 'f':
      if (! normals && nargin == 4)
        {
          Matrix CP = args(0).matrix_value ();
          Matrix X = args(1).matrix_value ();
          RowVector dir = args(2).row_vector_value ();
          if (CP.cols () == 3 
              && X.cols () == 3 && dir.length () == 3)
            {
              octave_idx_type m = CP.rows (), n = X.rows ();
              NDArray vi (dim_vector (m, n, 3));

              F77_FUNC (bisavf, BISAVF) (m, n, CP.data (),
                                         X.data (), dir.data (),
                                         vi.fortran_vec ());

              retval = vi;
            }
          else
            gripe_invalid_dimensions ();
        }
      else if (normals && nargin == 5)
        {
          Matrix CP = args(0).matrix_value (), CN = args(1).matrix_value ();
          Matrix X = args(2).matrix_value ();
          RowVector dir = args(3).row_vector_value ();
          if (CP.cols () == 3 && CN.cols () == 3 && CP.rows () == CN.rows ()
              && X.cols () == 3 && dir.length () == 3)
            {
              octave_idx_type m = CP.rows (), n = X.rows ();
              Matrix vn (m, n);

              F77_FUNC (bisanf, BISANF) (m, n, CP.data (), CN.data (),
                                         X.data (), dir.data (),
                                         vn.fortran_vec ());

              retval = vn;
            }
          else
            gripe_invalid_dimensions ();
        }
      else
        print_usage ();
      break;

    case 'b':
      if (! normals && nargin == 4)
        {
          Matrix CP = args(0).matrix_value ();
          Matrix X = args(1).matrix_value (), Y = args(2).matrix_value ();
          if (CP.cols () == 3 
              && X.cols () == 3 && Y.cols () == 3 && Y.rows () == X.rows ())
            {
              octave_idx_type m = CP.rows (), n = X.rows ();
              NDArray vi (dim_vector (m, n, 3));

              F77_FUNC (bisavb, BISAVB) (m, n, CP.data (),
                                         X.data (), Y.data (),
                                         vi.fortran_vec ());

              retval = vi;
            }
          else
            gripe_invalid_dimensions ();
        }
      else if (normals && nargin == 5)
        {
          Matrix CP = args(0).matrix_value (), CN = args(1).matrix_value ();
          Matrix X = args(1).matrix_value (), Y = args(2).matrix_value ();
          if (CP.cols () == 3 && CN.cols () == 3 && CP.rows () == CN.rows ()
              && X.cols () == 3 && Y.cols () == 3 && Y.rows () == X.rows ())
            {
              octave_idx_type m = CP.rows (), n = X.rows ();
              Matrix vn (m, n);

              F77_FUNC (bisanb, BISANV) (m, n, CP.data (), CN.data (),
                                         X.data (), Y.data (),
                                         vn.fortran_vec ());

              retval = vn;
            }
          else
            gripe_invalid_dimensions ();
        }
      else
        print_usage ();
      break;

    case 'c':
      if (! normals && nargin == 3)
        {
          Matrix CP = args(0).matrix_value ();
          Matrix X = args(1).matrix_value ();
          if (CP.cols () == 3 
              && X.cols () == 3 && X.rows () > 0)
            {
              octave_idx_type m = CP.rows (), n = X.rows () - 1;
              NDArray vi (dim_vector (m, n, 3));

              OCTAVE_LOCAL_BUFFER (double, work, 4*m);

              F77_FUNC (bisavc, BISAVC) (m, n, CP.data (),
                                         X.data (),
                                         vi.fortran_vec (), work);

              retval = vi;
            }
          else
            gripe_invalid_dimensions ();
        }
      else if (normals && nargin == 4)
        {
          Matrix CP = args(0).matrix_value (), CN = args(1).matrix_value ();
          Matrix X = args(1).matrix_value ();
          if (CP.cols () == 3 && CN.cols () == 3 && CP.rows () == CN.rows ()
              && X.cols () == 3 && X.rows () > 0)
            {
              octave_idx_type m = CP.rows (), n = X.rows () - 1;
              Matrix vn (m, n);

              OCTAVE_LOCAL_BUFFER (double, work, 4*m);

              F77_FUNC (bisanc, BISANC) (m, n, CP.data (), CN.data (),
                                         X.data (),
                                         vn.fortran_vec (), work);

              retval = vn;
            }
          else
            gripe_invalid_dimensions ();
        }
      else
        print_usage ();
      break;

    }

  return retval;
}

