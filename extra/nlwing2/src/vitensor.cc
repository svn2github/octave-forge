/* Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
 * 
 * Author: Jaroslav Hajek <highegg@gmail.com>
 * 
 * This file is part of NLWing2.
 * 
 * NLWing2 is free software; you can redistribute it and/or modify
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

#include <oct.h>
#include <f77-fcn.h>

extern "C" 
{
  F77_RET_T
  F77_FUNC(vitens, VITENS) (const octave_idx_type&, const double&, 
                            const double*, const double*, const double*, 
                            const int&, double*, double*, 
                            double*, double*);
}

DEFUN_DLD(vitensor, args, nargout,
"-*- texinfo -*-\n\
@deftypefn{Loadable Function} {[@var{vxg}, @var{vyg}, @var{vx0}, @var{vy0}]} = \
vitensor (@var{alfa}, @var{xAC}, @var{yAC}, @var{zAC}, @var{sym})\n\
Computes the induced velocities tensors on a lifting line approximated by a chain\n\
of vortex segments. @var{alfa} is the angle of attack (relative to x-z plane),\n\
@var{xAC}, @var{yAC}, @var{zAC} are coordinates of the lifting line points\n\
(chordwise, vertical, spanwise). @var{sym} denotes symmetry - only half of the\n\
lifting line is given, the other half is obtained by mirroring by the xy plane.\n\
On return, @var{vxg} and @var{vyg} are jacobians of induced local x and y\n\
velocities - the velocities induced by j-th vortex on i-th collocation point are\n\
given by @var{vxg}(i,j), @var{vyg}(i,j). @var{vx0}(i), @var{vy0}(i) denote local\n\
velocities induced on the collocation point by freestream. Thus, if @var{gam} is a\n\
vector of panel circulations, the corresponding induced velocities can be calculated\n\
as @code{@var{vx} = @var{vxg}*@var{gam}+@var{vx0}; @var{vy} = @var{vyg}*@var{gam}+@var{vy0};}\n\
@end deftypefn")
{
  int nargin = args.length ();
  octave_value_list retval;

  if (nargin < 4 || nargin > 5)
    {
      print_usage ();
      return retval;
    }

  octave_value argalfa = args (0);
  octave_value argxAC = args (1);
  octave_value argyAC = args (2);
  octave_value argzAC = args (3);

  if (argalfa.is_real_scalar () 
      && argxAC.is_real_matrix () 
      && argyAC.is_real_matrix () 
      && argzAC.is_real_matrix () 
      && (nargin < 5 || args (4).is_bool_scalar ()))
    {
      double alfa = argalfa.scalar_value();
      octave_idx_type np = argxAC.length()-1;

      int sym = (nargin >= 5) ? args (4).scalar_value () : 0;

      if (np > 0 && argyAC.length() == np+1 && argzAC.length() == np+1)
        {
          Matrix xAC = argxAC.matrix_value ();
          Matrix yAC = argyAC.matrix_value ();
          Matrix zAC = argzAC.matrix_value ();

          Matrix vxg(np,np), vyg(np,np);
          Matrix vx0(np,1), vy0(np,1);

          F77_FUNC(vitens, VITENS) (np, alfa, 
                                    xAC.data (), yAC.data (), zAC.data (), sym,
                                    vx0.fortran_vec (), vxg.fortran_vec (),
                                    vy0.fortran_vec (), vyg.fortran_vec ());
          retval (0) = vxg;
          retval (1) = vyg;
          retval (2) = vx0;
          retval (3) = vy0;
        }
      else
        error ("vitensor: dimension mismatch");
    }
  else
    print_usage();

  return retval;

}
