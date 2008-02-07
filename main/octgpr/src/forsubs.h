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

#ifndef _FORSUBS_H
#define _FORSUBS_H
#include <config.h>

typedef void (*corfptr) (double *t,double *f,double *d);

#ifdef __cplusplus
extern "C" {
#endif

#define F77_corgau F77_FUNC(corgau,CORGAU)
#define F77_corexp F77_FUNC(corexp,COREXP)
#define F77_corimq F77_FUNC(corimq,CORIMQ)
#define F77_nllgpr F77_FUNC(nllgpr,NLLGPR)
#define F77_nldgpr F77_FUNC(nldgpr,NLDGPR)
#define F77_nllbnd F77_FUNC(nllbnd,NLLBND)
#define F77_infgpr F77_FUNC(infgpr,INFGPR)
#define F77_stheta F77_FUNC(stheta,STHETA)
#define F77_dtr2tp F77_FUNC(dtr2tp,DTR2TP)
#define F77_optdrv F77_FUNC(optdrv,OPTDRV)

void F77_corgau(double *t, double *f, double *d);
void F77_corexp(double *t, double *f, double *d);
void F77_corimq(double *t, double *f, double *d);
void F77_nllgpr(int *ndim, int *nx, double x[], double y[], double theta[], double *nu, 
		double *var, int *nlin, double mu[], double r[], double *nll, corfptr corr, int *info);
void F77_nldgpr(int *ndim, int *nx, double x[], double theta[], double *nu, double *var, double r[], 
		double dtheta[], double dnu[], int *info);
void F77_nl0gpr(int *nx, double y[], double *nu, double *nll0, double *nllinf);
void F77_infgpr(int *ndim, int *nx, double x[], double theta[], double *nu, double *var, 
		int *nlin, double mu[], double rp[], corfptr corr, double x0[], 
		double *y0, double *sig0, int *nder, double yd0[], double *w);
void F77_stheta(int *ndim, int *nx, double x[], double theta[]);
void F77_dtr2tp(char *uplo, char *diag, int *n, double a[], int *lda, double ap[]);

void F77_optdrv(int *ndim, double theta[], double *nu, double *nll, double dtheta[], double dnu[], double theta0[], double *nu0, double *nll0, double dtheta0[], double dnu0[], int *info, double scal[], int *l2nu, double vm[], double cp[], int ic[]);

#ifdef __cplusplus
}
#endif
#endif /* forsubs.h */
