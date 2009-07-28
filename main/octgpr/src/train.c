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

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "gprmod.h"

#define DSIZE sizeof (double)

int GPR_train (int ndim, int nx, const double *X, const double *y,
               double *theta, double *nu, double *nll,
               int nlin, corfptr corf, struct GPR_train_opts *opts)
{
  double *wrk = malloc ((4*ndim+7)*DSIZE); 
  double *scal = wrk;
  double *theta0 = scal + ndim;
  double *nu0 = theta0 + ndim;
  double *nll0 = nu0 + 1;
  double *var = nll0 + 1;
  double *dtheta = var + 1;
  double *dnu = dtheta + ndim;
  double *dtheta0 = dnu + 2;
  double *dnu0 = dtheta0 + ndim;
  double *VM = malloc (1+(ndim+1)*(3*ndim+2)/2*DSIZE);

  /* workspace for nllgpr, nldgpr */
  double *R = malloc (nx*(nx+2+nlin)*DSIZE);
  double *mu = malloc ((nlin+1)*3*DSIZE);
  double CP[20];
  double dummy;
  int IC[4];

  int i, code, info, l2nu = 1;

  /* setup scale factors */
  F77_stheta (&ndim, &nx, X, scal);

  info = 0;

  /* request default values */
  for (i = 1; i < 20; i++) CP[i] = 0;
  CP[0] = opts->numin;
  CP[1] = (*nu > 1e-6) ? (*nu < 1e-1) ? *nu : 1e-1 : 1e-6; /* noise scale factor */
  CP[2] = opts->tol;
  CP[11] = opts->ftol;
  /* setup the reference objective value */
  F77_nl0gpr(&nx,y,nu,&dummy,&CP[10]);


  while (1) 
    {
      /* call the optimization driver */
      F77_optdrv (&ndim, theta, nu, nll, dtheta, dnu,
                  theta0, nu0, nll0, dtheta0, dnu0,
                  &info, scal, &l2nu, VM, CP, IC);
      if (info == 1 || info == 2) 
        {
          code = TRAIN_CONV;
          break;
        } 
      else if (info == 3)
        {
          code = TRAIN_PREM;
          break;
        }
      else if (info == -1) 
        {
          code = TRAIN_FAIL;
          break;
        }

      /* evaluate objective */
      F77_nllgpr (&ndim, &nx, X, y, theta, nu, var, &nlin,
                  mu, R, nll, corf, &info);

      if (IC[0] > opts->maxev || (opts->monitor 
                                  && (*opts->monitor) (opts->instance, IC[0], nll0) != 0)) 
        {
          code = TRAIN_STOP;
          break;
        }

      if (!info)
        /* evaluate gradient */
        F77_nldgpr (&ndim, &nx, X, theta, nu, var, R, dtheta, dnu, &info);

      /* mark whether the step was successful */
      if (info) 
        info = 2;
      else
        info = 1;

    }

  /* use last value. Change theta to have positive sign. */
  for (i = 0; i < ndim; i++) theta[i] = fabs (theta0[i]);
  *nu = *nu0;
  *nll = *nll0;

  free (mu);
  free (R);
  free (VM);
  free (wrk);

  return code;

}

int PGP_train (int ndim, int nx, int nf, const double *X, const double *F,
               const double *y, double *theta, double *nu, double *nll,
               int nlin, corfptr corf, struct PGP_train_opts *opts)
{
  double *wrk = malloc ((4*ndim+7)*DSIZE); 
  double *scal = wrk;
  double *theta0 = scal + ndim;
  double *nu0 = theta0 + ndim;
  double *nll0 = nu0 + 1;
  double *var = nll0 + 1;
  double *dtheta = var + 1;
  double *dnu = dtheta + ndim;
  double *dtheta0 = dnu + 2;
  double *dnu0 = dtheta0 + ndim;
  double *VM = malloc (1+(ndim+1)*(3*ndim+2)/2*DSIZE);

  /* workspace for nllpgp, nldpgp */
  double *R = malloc (nx*(2*nf+1)*DSIZE);
  double *Q = malloc (nf*(2*nf+nlin+3)*DSIZE);
  double *mu = malloc ((nlin+1)*3*DSIZE);
  double CP[20];
  double dummy;
  int IC[4];

  int i, code, info, l2nu = 1;

  /* setup scale factors */
  F77_stheta (&ndim, &nx, X, scal);

  info = 0;

  /* request default values */
  for (i = 1; i < 20; i++) CP[i] = 0;
  CP[0] = opts->numin;
  CP[1] = (*nu > 1e-6) ? (*nu < 1e-1) ? *nu : 1e-1 : 1e-6; /* noise scale factor */
  CP[2] = opts->tol;
  CP[11] = opts->ftol;
  /* setup the reference objective value */
  F77_nl0pgp(&nx,&nf,y,nu,&dummy,&CP[10]);

  while (1) 
    {
      /* call the optimization driver */
      F77_optdrv (&ndim, theta, nu, nll, dtheta, dnu,
                  theta0, nu0, nll0, dtheta0, dnu0,
                  &info, scal, &l2nu, VM, CP, IC);
      if (info == 1 || info == 2) 
        {
          code = TRAIN_CONV;
          break;
        } 
      else if (info == 3)
        {
          code = TRAIN_PREM;
          break;
        }
      else if (info == -1) 
        {
          code = TRAIN_FAIL;
          break;
        }

      /* evaluate objective */
      F77_nllpgp (&ndim, &nx, &nf, X, F, y, theta, nu, var, &nlin,
                  mu, R, Q, nll, corf, &info);

      if (IC[0] > opts->maxev || (opts->monitor 
                                  && (*opts->monitor) (opts->instance, IC[0], nll0) != 0)) 
        {
          code = TRAIN_STOP;
          break;
        }

      if (!info)
        /* evaluate gradient */
        F77_nldpgp (&ndim, &nx, &nf, X, F, theta, nu, var, R, Q, dtheta, dnu, &info);

      /* mark whether the step was successful */
      if (info) 
        info = 2;
      else
        info = 1;

    }

  /* use last value. Change theta to have positive sign. */
  for (i = 0; i < ndim; i++) theta[i] = fabs (theta0[i]);
  *nu = *nu0;
  *nll = *nll0;

  free (mu);
  free (R);
  free (Q);
  free (VM);
  free (wrk);

  return code;

}

