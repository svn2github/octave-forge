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

#ifndef _MODTP_H
#define _MODTP_H

#include "forsubs.h"

/* terminating conditions for training */
enum train_cond { 
  TRAIN_CONV, 
  TRAIN_STOP, 
  TRAIN_FAIL 
};

/* training options for GPR */
struct GPR_train_opts
{
  double numin,tol; 
  int maxev;
  int (*monitor)(void *instance,int num,double *nll); 
  void *instance;
};


#ifdef __cplusplus
extern "C" {
#endif

/* parse correlation type name */
corfptr get_corrf(const char *name);

/* train model hyperparameters */
int GPR_train(int ndim,int nx,const double *X,const double *y,
    double *theta,double *nu,double *nll,
    int nlin,const corfptr corf,struct GPR_train_opts *opts);

/* given hypers, setup model for predictions */
int GPR_setup(int ndim,int nx,const double *X,const double *y,
    const double *theta,const double *nu,
    int nlin,const corfptr corf,
    double *var, double *mu,double *RP,double *nll);

/* compute predictions */
void GPR_predict(int ndim,int nx,const double *X,
    const double *theta,const double *nu,
    int nlin,const corfptr corf,
    const double *var,const double *mu,const double *RP,
    int nx0,const double *X0,double *y0,double *sig0,double *yd0);

#ifdef __cplusplus
}
#endif
#endif /* modtp.h */
