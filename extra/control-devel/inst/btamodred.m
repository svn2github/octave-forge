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
## @deftypefn{Function File} {[@var{Gr}, @var{info}] =} btamodred (@var{G}, @dots{})
## @deftypefnx{Function File} {[@var{Gr}, @var{info}] =} btamodred (@var{G}, @var{nr}, @dots{})
## @deftypefnx{Function File} {[@var{Gr}, @var{info}] =} btamodred (@var{G}, @var{opt}, @dots{})
## @deftypefnx{Function File} {[@var{Gr}, @var{info}] =} btamodred (@var{G}, @var{nr}, @var{opt}, @dots{})
##
## Model order reduction by frequency weighted Balanced Truncation Approximation (BTA) method.
## The aim of model reduction is to find an LTI system @var{Gr} of order
## @var{nr} (nr << n) such that the input-output behaviour of @var{Gr}
## approximates the one from original system @var{G}.
##
## BTA is an absolute error method which tries to minimize
## @iftex
## @tex
## $$ || G - G_r ||_{\\infty} = min $$
## $$ || W_o \\ (G - G_r) \\ W_i ||_{\\infty} = min $$
## @end tex
## @end iftex
## @ifnottex
## @example
## ||G-Gr||    = min
##         inf
##
## ||Wo (G-Gr) Wi||    = min
##                 inf
## @end example
## @end ifnottex
## where @var{Wo} and @var{Wi} denote output and input weightings.
##
## UNSTABLE (from bstmodred)
##
## MIMO (from bstmodred)
##
## Approximation Properties:
## @itemize @bullet
## @item
## Guaranteed stability of reduced models
## @item
## Lower guaranteed error bound
## @item
## Guaranteed a priori error bound
## @iftex
## @tex
## $$ \\sigma_{r+1} \\leq || (G-G_r) ||_{\\infty} \\leq 2 \\sum_{j=r+1}^{n} \\sigma_j $$
## @end tex
## @end iftex
## @end itemize
##
## @strong{Inputs}
## @table @var
## @item G
## LTI model to be reduced.
## @item nr
## The desired order of the resulting reduced order system @var{Gr}.
## If not specified, @var{nr} is chosen automatically according
## to the description of key @var{"order"}.
## @item @dots{}
## Optional pairs of keys and values.  @code{"key1", value1, "key2", value2}.
## @item opt
## Optional struct with keys as field names.
## Struct @var{opt} can be created directly or
## by command @command{options}.  @code{opt.key1 = value1, opt.key2 = value2}.
## @end table
##
## @strong{Outputs}
## @table @var
## @item Gr
## Reduced order state-space model.
## @item info
## Struct containing additional information.
## @table @var
## @item info.n
## The order of the original system @var{G}.
## @item info.ns
## The order of the @var{alpha}-stable subsystem of the original system @var{G}.
## @item info.hsv
## The Hankel singular values of the @var{alpha}-stable part of
## the original system @var{G}, ordered decreasingly.
## @item info.nu
## The order of the @var{alpha}-unstable subsystem of both the original
## system @var{G} and the reduced-order system @var{Gr}.
## @item info.nr
## The order of the obtained reduced order system @var{Gr}.
## @end table
## @end table
##
##
## @strong{Option Keys and Values}
## @table @var
## @item "order", "nr"
## The desired order of the resulting reduced order system @var{Gr}.
## If not specified, @var{nr} is chosen automatically.
##
## @item "left", "output"
## LTI model of the left/output frequency weighting.
## Default value is an identity matrix.
##
## @item "right", "input"
## LTI model of the right/input frequency weighting.
## Default value is an identity matrix.
##
## @item "method"
## Order reduction approach to be used as follows:
## @table @var
## @item "sr", "b"
## Use the square-root Balance & Truncate method.
## @item "bfsr", "f"
## Use the balancing-free square-root Balance & Truncate method.  Default method.
## @end table
##
## @item "alpha"
## Specifies the ALPHA-stability boundary for the eigenvalues
## of the state dynamics matrix @var{G.A}.  For a continuous-time
## system, ALPHA <= 0 is the boundary value for
## the real parts of eigenvalues, while for a discrete-time
## system, 0 <= ALPHA <= 1 represents the
## boundary value for the moduli of eigenvalues.
## The ALPHA-stability domain does not include the boundary.
## Default value is 0 for continuous-time systems and
## 1 for discrete-time systems.
##
## @item "tol1"
## If @var{"order"} is not specified, @var{tol1} contains the tolerance for
## determining the order of the reduced model.
## For model reduction, the recommended value of @var{tol1} is
## c*info.hsv(1), where c lies in the interval [0.00001, 0.001].
## If @var{"order"} is specified, the value of @var{tol1} is ignored.
##
## @item "tol2"
## The tolerance for determining the order of a minimal
## realization of the ALPHA-stable part of the given
## model.  TOL2 <= TOL1.
## If not specified, ns*eps*info.hsv(1) is chosen.
##
## @item "equil", "scale"
## Boolean indicating whether equilibration (scaling) should be
## performed on system @var{G} prior to order reduction.
## Default value is true if @code{G.scaled == false} and
## false if @code{G.scaled == true}.
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT AB09ID by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function [Gr, info] = btamodred (varargin)

  [Gr, info] = __modred_ab09id__ ("bta", varargin{:});

endfunction


%!shared Mo, Me, Info, HSVe
%! A =  [ -26.4000,    6.4023,    4.3868;
%!         32.0000,         0,         0;
%!               0,    8.0000,         0 ];
%!
%! B =  [       16
%!               0
%!               0 ];
%!
%! C =  [   9.2994     1.1624     0.1090 ];
%!
%! D =  [        0 ];
%!
%! G = ss (A, B, C, D);  % "scaled", false
%!
%! AV = [  -1.0000,         0,    4.0000,   -9.2994,   -1.1624,   -0.1090;
%!               0,    2.0000,         0,   -9.2994,   -1.1624,   -0.1090;
%!               0,         0,   -3.0000,   -9.2994,   -1.1624,   -0.1090;
%!         16.0000,   16.0000,   16.0000,  -26.4000,    6.4023,    4.3868;
%!               0,         0,         0,   32.0000,         0,         0;
%!               0,         0,         0,         0,    8.0000,         0 ];
%!
%! BV = [        1
%!               1
%!               1
%!               0
%!               0
%!               0 ];
%!
%! CV = [        1          1          1          0          0          0 ];
%!
%! DV = [        0 ];
%!
%! V = ss (AV, BV, CV, DV);
%!
%! [Gr, Info] = btamodred (G, 2, "left", V);
%! [Ao, Bo, Co, Do] = ssdata (Gr);
%!
%! Ae = [  9.1900   0.0000
%!         0.0000 -34.5297 ];
%!
%! Be = [ 11.9593
%!        16.9329 ];
%!
%! Ce = [  2.8955   6.9152 ];
%!
%! De = [  0.0000 ];
%!
%! HSVe = [  3.8253   0.2005 ].';
%!
%! Mo = [Ao, Bo; Co, Do];
%! Me = [Ae, Be; Ce, De];
%!
%!assert (Mo, Me, 1e-4);
%!assert (Info.hsv, HSVe, 1e-4);
