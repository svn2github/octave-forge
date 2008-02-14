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

#include "gprmod.h"

octave_value getfield(const Octave_map& map,const char *field,bool& err) {
  Cell c = map.contents(field);
  if (!c.is_empty()) 
    return c(0);
  else {
    err = true;
    return octave_value();
  }
}

DEFUN_DLD(gpr_predict,args,nargout,	
  "-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {@var{y}}= gpr_predict (@var{GPM},@var{X})\n\
@deftypefnx {Loadable Function} {[@var{y},@var{sig}]}= gpr_predict (@var{GPM},@var{X})\n\
@deftypefnx {Loadable Function} {[@var{y},@var{sig},@var{dy}]}= gpr_predict (@var{GPM},@var{X})\n\
@cindex Gaussian Process Regression inference \n\
Uses the model @var{GPM} to predict values, standard deviations and model\n\
derivatives in spatial points. @var{X} is the matrix of independent variables. \n\
(The organization is determined by GPM.theta, as in @code{gpr_train}). \n\
\n\
@var{y} is set to the predicted dependent variable values. \n\
If @var{sig} is requested, it is set to the estimated prediction deviations. \n\
If @var{dy} is requested, it is populated with the prediction gradients. \n\
\n\
@seealso{gpr_train, gpr_setup}\n\
@end deftypefn")
{
  octave_value_list retval;
  int nargin = args.length();
  if (nargin != 2 || nargout > 3 || nargout < 1) {
    print_usage();
    return retval;
  }

  octave_value arg;
  // extract the model info
  arg = args(0);
  if (!arg.is_map()) {
    error("the first argument must be a structure.");
    return retval;
  } 
  Octave_map GPM(arg.map_value());
  // parse model structure

  bool err = false;;
  Matrix X(getfield(GPM,"X",err).matrix_value());
  int nx = X.cols();
  Matrix theta(getfield(GPM,"theta",err).matrix_value());

  // determine row/col convention
  int ndim = theta.rows();
  bool trans = ndim == 1;
  if (trans) ndim = theta.cols();

  if (theta.rows() == 1) 
    trans = true,ndim = theta.cols();
  else if (theta.cols() == 1)
    trans = false,ndim = theta.rows();
  else 
    ndim = 0;

  double nu = getfield(GPM,"nu",err).scalar_value();
  double var = getfield(GPM,"var",err).scalar_value();

  ColumnVector mu(getfield(GPM,"mu",err).matrix_value());
  int nlin = mu.numel()-1;

  ColumnVector RP(getfield(GPM,"RP",err).matrix_value());

  std::string corfs = getfield(GPM,"corf",err).string_value();
  corfptr corf = get_corrf(corfs.c_str());
  if (!corf) error("invalid correlation funspec: %s",corfs.c_str()); 

  if (err) {
    error("the GPM structure is incomplete");
    return retval;
  }

  arg = args(1);
  if (!arg.is_real_matrix()) {
    error("X must be a real matrix");
    return retval;
  }
  Matrix X0(arg.matrix_value());
  if (trans) X0 = X0.transpose();

  if (X0.rows() != ndim) error("dimension mismatch.");
  int nx0 = X0.cols();

  // build return values
  Matrix y0(trans?nx0:1,trans?1:nx0),sig0(trans?nx0:1,trans?1:nx0),yd0;
  if (nargout > 2) yd0 = Matrix(ndim,nx0);

  // do the predictions
  if (nx0 > 0) GPR_predict(ndim,nx,X.fortran_vec(),
      theta.fortran_vec(),&nu,nlin,corf,
      &var,mu.fortran_vec(),RP.fortran_vec(),
      nx0,X0.fortran_vec(),y0.fortran_vec(),sig0.fortran_vec(),
      (nargout > 2) ? yd0.fortran_vec() : 0);

  // build return list
  retval = octave_value_list(nargout,octave_value());
  retval(0) = y0;
  if (nargout > 1) retval(1) = sig0;
  if (nargout > 2) retval(2) = trans?yd0.transpose():yd0;
  return retval;

}
