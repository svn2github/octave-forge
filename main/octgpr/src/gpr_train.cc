// Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
// 
// Author: Jaroslav Hajek <highegg@gmail.com>
// 
// This file is part of OctGPR.
// 
// OctGPR is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this software; see the file COPYING.  If not, see
// <http://www.gnu.org/licenses/>.

#include <octave/oct.h>
#include <octave/oct-map.h>
#include <octave/quit.h>

#include <iostream>
#include <stdio.h>
#include <math.h>

#include "gprmod.h"

int progress_monitor(void *instance,int num,double *nll)
{ 
  fprintf(stdout,"\revals: %5d -log(lhood): %10.5le  ",num,*nll); 
  fflush(stdout);
  // interrupt if caught a signal 
  return (int)octave_signal_caught;
}

DEFUN_DLD(gpr_train,args,nargout,	
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{GPM} =} gpr_train (@var{X}, @var{y}, @var{theta}, @var{opts})\n\
@deftypefnx {Loadable Function} {[@var{GPM}, @var{nll}]} = gpr_train (@var{X}, @var{y}, @var{theta},\
 @var{nu}, @var{nlin}, @var{corf}, @var{opts})\n\
@cindex Gaussian Process Regression model training.\n\
If requested, estimates the hyperparameters for Gaussian Process Regression (inverse\n\
length scales and relative noise) via reduced maximum likelihood, and then \n\
sets up the model for inference (prediction), storing necessary information in \n\
the structure @var{GPM}, intended for use with gpr_train. \n\
\n\
@var{X} is the matrix of independent variables of the observations, \n\
@var{y} is a vector containing the dependent variables, \n\
@var{theta} contains the (initial) inverse length scales for the regression model. \n\
If @var{theta} is a row vector, rows of @var{X} correspond to observations, columns to \n\
variables. Otherwise, it is the other way around. \n\
\n\
@var{nu} specifies the (initial) relative noise level. If not supplied, it defaults \n\
to 1e-5. \n\
@var{nlin} specifies the number of leading variables to include in linear \n\
underlying trend. If not supplied, it defaults to 0 (constant trend). \n\
\n\
@var{corf} specifies the decreasing function type for correlation function:\n\
@code{corr(x,y) = f((x-y).^2 * theta\')} (x,y,theta row vectors). Possible values:\n\
@enumerate \n\
@item gau: @code{f(t) = exp(-t)} \n\
@item exp: @code{f(t) = exp(-sqrt(t))} \n\
@item imq: @code{f(t) = 1/sqrt(1+t^2)} \n\
@end enumerate \n\
\n\
@var{opts} is a cell array in the form @{\"option name\",option value,...@}. \n\
Possible options: \n\
\n\
  maxev: maximum number of factorizations to be used during training. default 500.\n\
\n\
  tol: stopping tolerance (minimum trust-region radius). default 1e-6. \n\
\n\
  numin: minimum allowable noise. Default is @code{sqrt(1e1*eps)}. \n\
\n\
Training cell array @var{opts} is recognized even if other arguments are omitted. \n\
If it is not supplied (the last argument is not a cell array), training is skipped. \n\
\n\
On return the function creates the @var{GPM} structure, \n\
which can subsequently be used for predictions with @code{gpr_predict}. \n\
If @var{nll} is present, it is set to the resulting negative log likelihood.\n\
@seealso{gpr_predict}\n\
@end deftypefn")
{
  octave_value_list retval;
  octave_value arg;
  int nargin = args.length();
  if (nargin < 3 || nargin > 7 || nargout < 1) {
    print_usage();
    return retval;
  }

  Cell opts;
  bool do_train;
  arg = args(nargin-1);
  if (arg.is_cell()) {
    opts = arg.cell_value();
    nargin -= 1;
    do_train = true;
  } else
    do_train = false;

  arg = args(0);
  if (!arg.is_real_matrix()) {
    error("X must be a real matrix");
    return retval;
  }
  Matrix X(arg.matrix_value());

  arg = args(1);
  if (!arg.is_real_matrix()) {
    error("y must be a real vector");
    return retval;
  }
  ColumnVector y(arg.matrix_value());

  arg = args(2);
  if (!arg.is_real_matrix() && !arg.is_real_scalar()) {
    error("theta must be a real vector");
    return retval;
  }
  Matrix theta(args(2).matrix_value());

  int ndim;
  bool trans;
  if ((ndim = theta.rows()) == 1) {
    ndim = theta.cols();
    trans = ndim > 1 || X.rows() != 1;
  } else 
    trans = false;

  if (ndim == 0) {
    error("theta must be a nonempty real vector");
    return retval;
  } 
  for (int i = 0; i < ndim; i++) theta.xelem(i) = fabs(theta.xelem(i));

  // check matching dimensions
  if (trans) X = X.transpose();
  int nx = X.cols();
  if (X.rows() != ndim || y.numel() != nx) {
    error("X,y,theta dimensions do not match");
    return retval;
  }
  if (nx < 2) {
    error("must have at least 2 observations.");
    return retval;
  }

  double nu = 1e-5;
  if (nargin > 3) {
    arg = args(3);
    if (!arg.is_real_scalar()) {
      error("nu must be a real scalar");
      return retval;
    }
    nu = fabs(arg.scalar_value());
  } 

  int nlin = (nargin > 4) ? args(4).int_value() : 0;
  if (nlin < 0 || nlin > ndim || nlin >= nx) {
    error("nlin must be in 0:min(size(X,2),size(X,1)-1)");
    return retval;
  }

  std::string corfs;
  corfptr corf;
  if (nargin > 5) {
    arg = args(5);
    if (!arg.is_string() || 
        (corfs = arg.string_value(),corf = get_corrf(corfs.c_str()),!corf)) {
      error("invalid correlation function: %s",corfs.c_str());
      return retval;
    }
  } else {
    corfs = "gau";
    corf = get_corrf(corfs.c_str());
  }

  double nll;

  if (do_train) {

    struct GPR_train_opts topts;
    // setup initial values 
    topts.maxev = 500;
    topts.tol= 1e-5;
    topts.numin = 5e-8;
    topts.monitor = &progress_monitor;
    topts.instance = 0;

    // parse options 

    int iopt = 0;
    octave_value val;
    while(iopt < opts.length()-1) {
      val = opts(iopt);
      if (!val.is_string()) {
        error("OPTS should consist of name,value pairs");
        return retval;
      }
      std::string oname = val.string_value();
      if (oname == "maxev") {
        topts.maxev = opts(++iopt).scalar_value();
      } else if (oname == "tol") {
        topts.tol = opts(++iopt).scalar_value();
      } else if (oname == "numin") {
        topts.numin = opts(++iopt).scalar_value();
      } else {
        error("unrecognized option: %s",oname.c_str());
        return retval;
      }
      ++iopt;
    }

    if (topts.maxev > 0) {

      // run training 
      int ierr = GPR_train(ndim,nx,X.fortran_vec(),y.fortran_vec(),
          theta.fortran_vec(),&nu,&nll,nlin,corf,&topts);
      fprintf(stdout,"\n"); 
      if (octave_signal_caught) {
        octave_signal_caught = 0;
        // allow the optimization to be interrupted by Ctrl-C
        if (octave_interrupt_state > 0)
          octave_interrupt_state = 0;
        else
          octave_handle_signal();
      }

      switch (ierr) {
        case TRAIN_CONV:
          std::cout << "converged." << '\n';
          break;
        case TRAIN_STOP:
          std::cout << "stopped." << '\n';
          break;
        case TRAIN_FAIL:
          error("failed. try different initial guess.");
          return retval;
      }

    }
  }

  // setup model for predictions 

  double var;
  ColumnVector RP(nx+nx*(nx+1)/2);
  // make mu follow the theta convention (given by trans)
  Matrix mu(trans?1:nlin+1,trans?nlin+1:1);

  GPR_setup(ndim,nx,X.fortran_vec(),y.fortran_vec(),theta.fortran_vec(),&nu,
      nlin,corf,&var,mu.fortran_vec(),RP.fortran_vec(),&nll);

  // construct model structure 

  Octave_map GPM;

  // store training data 
  GPM.assign("X",X);
  // hyperparameters 
  GPM.assign("theta",theta);
  GPM.assign("nu",nu);

  // prediction and additional data 
  GPM.assign("var",var);
  GPM.assign("RP",RP);
  GPM.assign("mu",mu);
  GPM.assign("corf",corfs);

  retval = octave_value_list(nargout,octave_value());
  retval(0) = GPM;
  if (nargout > 1) retval(1) = nll;
  return retval;
}

