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

#include <stdlib.h>
#include <string.h>
#include "gprmod.h"

#define DSIZE sizeof (double)

int GPR_setup (int ndim, int nx, const double *X, const double *y,
               const double *theta, const double *nu,
               int nlin, corfptr corf,
               double *var, double *mu, double *RP, double *nll)
{
  /* allocate workspace */
  double *R = malloc (nx*(nx+2+nlin)*DSIZE);
  double *mmu = malloc ((nlin+1)*3*DSIZE);

  int ierr;

  /* compute model via nllgpr */
  F77_nllgpr (&ndim, &nx, X, y, theta, nu, var, &nlin,
              mmu, R, nll, corf, &ierr);

  /* pack model data */
  memcpy (RP, R, nx*DSIZE);
  memcpy (mu, mmu, (nlin+1)*DSIZE);
  F77_dtr2tp ("L", "N", &nx, R+nx, &nx, RP+nx);

  /* free workspace */
  free (R); free (mmu);

  return ierr;
}

