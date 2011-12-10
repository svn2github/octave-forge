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
## @deftypefn{Function File} {[@var{Kr}, @var{info}] =} btaconred (@var{G}, @var{K}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} btaconred (@var{G}, @var{K}, @var{ncr}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} btaconred (@var{G}, @var{K}, @var{opt}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} btaconred (@var{G}, @var{K}, @var{ncr}, @var{opt}, @dots{})
##
## Controller reduction by frequency-weighted Balanced Truncation Approximation (BTA).
##
## @strong{Inputs}
## @table @var
## @item G
## LTI model of the plant.
## It has m inputs, p outputs and n states.
## @item K
## LTI model of the controller.
## It has p inputs, m outputs and nc states.
## @item ncr
## The desired order of the resulting reduced order controller @var{Kr}.
## If not specified, @var{ncr} is chosen automatically according
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
## @item Kr
## State-space model of reduced order controller.
## @item info
## Struct containing additional information.
## @table @var
## @item info.ncr
## The order of the obtained reduced order controller @var{Kr}.
## @item info.ncs
## The order of the alpha-stable part of original controller @var{K}.
## @item info.hsvc
## The Hankel singular values of the alpha-stable part of @var{K}.
## The @var{ncs} Hankel singular values are ordered decreasingly.
## @end table
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT SB16AD by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2011
## Version: 0.1

function [Kr, info] = btaconred (varargin)

  [Kr, info] = __conred_sb16ad__ ("bta", varargin{:});

endfunction


%!shared Mo, Me, Info, HSVCe
%! A =  [ -1.  0.   4.
%!         0.  2.   0.
%!         0.  0.  -3. ];
%!
%! B =  [  1.
%!         1.
%!         1. ];
%!
%! C =  [  1.  1.   1. ];
%!
%! D =  [  0. ];
%!
%! G = ss (A, B, C, D, "scaled", true);
%!
%! AC = [ -26.4000,    6.4023,    4.3868;
%!         32.0000,         0,         0;
%!               0,    8.0000,         0  ];
%!
%! BC = [      -16
%!               0
%!               0 ];
%!
%! CC = [   9.2994    1.1624    0.1090 ];
%!
%! DC = [        0 ];
%!
%! K = ss (AC, BC, CC, DC, "scaled", true);
%!
%! [Kr, Info] = btaconred (G, K, 2, "weight", "input");
%! [Ao, Bo, Co, Do] = ssdata (Kr);
%!
%! Ae = [   9.1900   0.0000
%!          0.0000 -34.5297 ];
%!
%! Be = [ -11.9593
%!         86.3137 ];
%!
%! Ce = [   2.8955  -1.3566 ];
%!
%! De = [   0.0000 ];
%!
%! HSVCe = [  3.8253   0.2005 ].';
%!
%! Mo = [Ao, Bo; Co, Do];
%! Me = [Ae, Be; Ce, De];
%!
%!assert (Mo, Me, 1e-4);
%!assert (Info.hsvc, HSVCe, 1e-4);
