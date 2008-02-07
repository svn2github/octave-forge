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

#define DSIZE sizeof(double)

void GPR_predict(int ndim,int nx,double *X,
    double *theta,double *nu,
    int nlin,corfptr corf,
    double *var,double *mu,double *RP,
    int nx0,double *X0,double *y0,double *sig0,double *yd0)
{
  int nder = (yd0) ? ndim : 0;
  double *work = malloc(nx*(1+(nder)?1:0)*DSIZE);
  double dummy;

  for ( ;nx0; --nx0) {
    /* call infgpr */
    F77_infgpr(&ndim,&nx,X,theta,nu,var,&nlin,mu,RP,corf,
	X0,y0,sig0,&nder,yd0?yd0:&dummy,work);
    /* increment pointers */
    X0 += ndim;
    y0++;
    sig0++;
    if (yd0) yd0 += ndim;
  }
  free(work);
}
