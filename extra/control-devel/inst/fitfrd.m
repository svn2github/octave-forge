## Copyright (C) 2011   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{sys}, @var{n}] =} fitfrd (@var{dat}, @var{n})
## Fit frequency response data with a stable, minimum-phase state-space system.
##
## @strong{Inputs}
## @table @var
## @item G
## LTI model of plant.
## @item W1
## LTI model of precompensator.  Model must be SISO or of appropriate size.
## An identity matrix is taken if @var{W1} is not specified or if an empty model
## @code{[]} is passed.
## @item W2
## LTI model of postcompensator.  Model must be SISO or of appropriate size.
## An identity matrix is taken if @var{W2} is not specified or if an empty model
## @code{[]} is passed.
## @item factor
## @code{factor = 1} implies that an optimal controller is required.
## @code{factor > 1} implies that a suboptimal controller is required,
## achieving a performance that is @var{factor} times less than optimal.
## Default value is 1.
## @end table
##
## @strong{Outputs}
## @table @var
## @item K
## State-space model of the H-infinity loop-shaping controller.
## @item N
## State-space model of the closed loop depicted below.
## @item gamma
## L-infinity norm of @var{N}.
## @item info
## Structure containing additional information.
## @item info.emax
## Nugap robustness.  @code{emax = inv (gamma)}.
## @item info.Gs
## Shaped plant.  @code{Gs = W2 * G * W1}.
## @item info.Ks
## Controller for shaped plant.  @code{Ks = ncfsyn (Gs)}.
## @item info.rcond
## Estimates of the reciprocal condition numbers of the Riccati equations.
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT SB10YD by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2011
## Version: 0.1

function [sys, n] = fitfrd (dat, n, flag = 0)

  if (nargin == 0 || nargin > 3)
    print_usage ();
  endif
  
  if (! isa (dat, "frd"))
    dat = frd (dat);
  endif
  
  if (! issample (n, 0) || n != round (n))
    error ("fitfrd: second argument must be an integer >= 0");
  endif

  [H, w, tsam] = frdata (dat, "vector");
  dt = isdt (dat);
  
  [a, b, c, d, n] = slsb10yd (real (H), imag (H), w, n, dt, flag);
  
  sys = ss (a, b, c, d, tsam);

endfunction