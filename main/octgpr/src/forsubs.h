/* Copyright (C) 2008, 2009  VZLU Prague, a.s., Czech Republic
 * 
 * Author: Jaroslav Hajek <highegg@gmail.com>
 * 
 * This file is part of OctGPR.
 * 
 * OctGPR is free software; you can redistribute it and/or modify
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

#ifndef _FORSUBS_H
#define _FORSUBS_H
#include <config.h>

typedef void (*corfptr) (const double *t, double *f, double *d);

#ifdef __cplusplus
extern "C" {
#endif

#define F77_corgau F77_FUNC(corgau,CORGAU)
#define F77_corexp F77_FUNC(corexp,COREXP)
#define F77_corimq F77_FUNC(corimq,CORIMQ)
#define F77_cormt3 F77_FUNC(cormt3,CORMT3)
#define F77_cormt5 F77_FUNC(cormt5,CORMT5)
#define F77_nllgpr F77_FUNC(nllgpr,NLLGPR)
#define F77_nldgpr F77_FUNC(nldgpr,NLDGPR)
#define F77_nl0gpr F77_FUNC(nl0gpr,NL0GPR)
#define F77_infgpr F77_FUNC(infgpr,INFGPR)
#define F77_pakgpr F77_FUNC(pakgpr,PAKGPR)
#define F77_nllpgp F77_FUNC(nllpgp,NLLPGP)
#define F77_nldpgp F77_FUNC(nldpgp,NLDPGP)
#define F77_nl0pgp F77_FUNC(nl0pgp,NL0PGP)
#define F77_infpgp F77_FUNC(infpgp,INFPGP)
#define F77_pakpgp F77_FUNC(pakpgp,PAKPGP)
#define F77_stheta F77_FUNC(stheta,STHETA)
#define F77_dtr2tp F77_FUNC(dtr2tp,DTR2TP)
#define F77_optdrv F77_FUNC(optdrv,OPTDRV)

    void F77_corgau (const double *t, double *f, double *d);

    void F77_corexp (const double *t, double *f, double *d);

    void F77_corimq (const double *t, double *f, double *d);

    void F77_cormt3 (const double *t, double *f, double *d);

    void F77_cormt5 (const double *t, double *f, double *d);

    void F77_nllgpr (const int *ndim, 
                     const int *nx, 
                     const double x[], 
                     const double y[], 
                     const double theta[], 
                     const double *nu,
                     double *var, 
                     const int *nlin, 
                     double mu[], 
                     double r[], 
                     double *nll, 
                     const corfptr corr, 
                     int *info );

    void F77_nllpgp (const int *ndim, 
                     const int *nx, 
                     const int *nf, 
                     const double x[], 
                     const double f[], 
                     const double y[], 
                     const double theta[], 
                     const double *nu, 
                     double *var, 
                     const int *nlin, 
                     double mu[], 
                     double r[], 
                     double q[], 
                     double *nll, 
                     const corfptr corr, 
                     int *info);

    void F77_nldgpr (const int *ndim, 
                     const int *nx, 
                     const double x[], 
                     const double theta[], 
                     const double *nu, 
                     double *var, 
                     double r[], 
                     double dtheta[], 
                     double dnu[], 
                     int *info );

    void F77_nldpgp (const int *ndim,
                     const int *nx,
                     const int *nf,
                     const double x[],
                     const double f[],
                     const double theta[],
                     const double *nu,
                     double *var,
                     double r[],
                     double q[],
                     double dtheta[],
                     double *dnu,
                     int *info
                     );


    void F77_nl0gpr (const int *nx, 
                     const double y[], 
                     const double *nu, 
                     double *nll0, 
                     double *nllinf );

    void F77_nl0pgp (const int *nx, 
                     const int *nf, 
                     const double y[], 
                     const double *nu, 
                     double *nll0, 
                     double *nllinf );

    void F77_infgpr (const int *ndim, 
                     const int *nx, 
                     const double x[], 
                     const double theta[], 
                     const double *nu, 
                     const double *var, 
                     const int *nlin, 
                     const double mu[], 
                     const double rp[], 
                     const corfptr corr, 
                     const double x0[],
                     double *y0, 
                     double *sig0, 
                     const int *nder, 
                     double yd0[], 
                     double *w );

    void F77_infpgp (const int *ndim, 
                     const int *nf, 
                     const double f[], 
                     const double theta[], 
                     const double *nu, 
                     const double *var, 
                     const int *nlin, 
                     const double mu[], 
                     const double qp[], 
                     const corfptr corr, 
                     const double x0[],
                     double *y0, 
                     double *sig0, 
                     const int *nder, 
                     double yd0[], 
                     double *w );

    void F77_stheta (const int *ndim, 
                     const int *nx, 
                     const double x[], 
                     double theta[] );

    void F77_pakgpr (const int *nx, 
                     const int *nlin, 
                     const double mu[], 
                     const double r[], 
                     double mup[],
                     double rp[] );

    void F77_pakpgp (const int *nf, 
                     const int *nlin, 
                     const double mu[], 
                     const double r[], 
                     double mup[],
                     double rp[] );

    void F77_dtr2tp (const char *uplo, 
                     const char *diag, 
                     const int *n, 
                     const double a[], 
                     const int *lda, 
                     double ap[] );

    void F77_optdrv (const int *ndim,
                     double theta[],
                     double *nu,
                     double *nll,
                     double dtheta[],
                     double dnu[],
                     double theta0[],
                     double *nu0,
                     double *nll0,
                     double dtheta0[],
                     double dnu0[],
                     int *info,
                     double scal[],
                     const int *l2nu,
                     double vm[],
                     double cp[],
                     int ic[] );

#ifdef __cplusplus
}
#endif
#endif /* forsubs.h */
