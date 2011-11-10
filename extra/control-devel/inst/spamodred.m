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
## @deftypefn{Function File} {[@var{sysr}, @var{nr}] =} spamodred (@var{sys}, @dots{})
## Model order reduction by frequency weighted optimal Hankel-norm approximation method.
##
## @strong{Inputs}
## @table @var
## @item sys
## LTI model to be reduced.
## @item @dots{}
## Pairs of properties and values.
## TODO: describe options.
## @end table
##
## @strong{Outputs}
## @table @var
## @item sysr
## Reduced order state-space model.
## @item nr
## The order of the obtained system @var{sysr}.
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT AB09ID by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function [sysr, info] = spamodred (varargin)

  [sysr, info] = __modred_ab09id__ ("spa", varargin{:});

endfunction

## TODO: add a test