/* Copyright (C) 2002  Kai Habel
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

*/

#include <octave/oct.h>
#include <octave/f77-fcn.h>

// SLATEC/PCHIP function not in libcruft
extern "C" {
  extern int F77_FUNC (dpchim, DPCHIM)
    (const int &n, double *x, double *f, 
	  double *d, const int &incfd, int *ierr);
}

DEFUN_DLD(pchip_deriv, args, ,"\
pchip_deriv(x,y):\n\
wrapper for SLATEC/PCHIP function DPCHIM to calculate derivates for\n\
piecewise polynomials. You shouldn't use pchip_deriv, use pchip instead.\n\
")
{
  octave_value_list retval;
  const int nargin = args.length();

  if (nargin == 2)
    {
      ColumnVector xvec(args(0).vector_value());
      Matrix ymat(args(1).matrix_value());
      int nx = xvec.length();
      int nyr = ymat.rows();
      int nyc = ymat.columns();

      if (nx != nyr)
        {
          error("number of rows for x and y must match");
          return retval;
        }

      ColumnVector dvec(nx),yvec(nx);
      Matrix dmat(nyr,nyc);

      int ierr;
      const int incfd = 1;
      for (int c=0; c<nyc; c++)
        {
          for (int r=0; r<nx; r++)
            {
              yvec(r) = ymat(r,c);
            }

          F77_FUNC (dpchim, DPCHIM) (nx, xvec.fortran_vec(), yvec.fortran_vec(), dvec.fortran_vec(), incfd, &ierr);

		    	if (ierr < 0)
            {
  				    error ("DPCHIM error: %i\n",ierr);
              return retval;
            }
          for (int r=0; r<nx; r++)
            {
              dmat(r,c) = dvec(r);
            }
        }

			retval(0) = dmat;

		}
  return retval;

}
