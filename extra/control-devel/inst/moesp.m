## Copyright (C) 2012   Lukas F. Reichlin
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
## @deftypefn {Function File} {@var{dat} =} moesp (@var{dat}, @var{s}, @var{n})
## MOESP.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2012
## Version: 0.1

function [sys, x0] = moesp (varargin)

  [sys, x0] = __slicot_identification__ ("moesp", varargin{:});

endfunction