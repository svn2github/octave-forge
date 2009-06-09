## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## SECS2D is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
##
## AUTHOR: Carlo de Falco <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
##
## @deftypefn {Function File}{@var{epsilon}} = @
## METLINESdefinepermittivity(@var{omesh},@var{basevalue},[@var{regions1},@var{value1},...])
##
## @end deftypefn

function epsilon = METLINESdefinepermittivity(omesh,basevalue,varargin);

  load (file_in_path(path,"constants.mat"));
  epsilon = e0*basevalue*ones(size(omesh.t(1,:)))';

  for ii = 1:floor(length(varargin)/2)
    [ignore1,ignore2,elements] = Usubmesh(omesh,[],varargin{2*ii-1},1);
    epsilon(elements)          = varargin{2*ii}*e0;
  endfor

endfunction