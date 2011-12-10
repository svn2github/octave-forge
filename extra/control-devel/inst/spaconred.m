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
## @deftypefn{Function File} {[@var{Kr}, @var{info}] =} spaconred (@var{G}, @var{K}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} spaconred (@var{G}, @var{K}, @var{ncr}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} spaconred (@var{G}, @var{K}, @var{opt}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} spaconred (@var{G}, @var{K}, @var{ncr}, @var{opt}, @dots{})
##
## Controller reduction by frequency-weighted Singular Perturbation Approximation (SPA).
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

function [Kr, info] = spaconred (varargin)

  [Kr, info] = __conred_sb16ad__ ("spa", varargin{:});

endfunction

## TODO: add a test