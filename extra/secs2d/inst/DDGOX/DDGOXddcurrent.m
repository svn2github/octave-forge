## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn {Function File}@
## {@var{current},@var{divrg}} = DDGOXddcurrent(@var{mesh},@var{Sinodes},@var{data},@var{contacts})
##
## Compute contacts total current and local element divergence
##
## @end deftypefn

function [current,divrg] = DDGOXddcurrent(mesh,Sinodes,data,contacts);

  load (file_in_path(path,'constants.mat'))

  Nelements = size(mesh.t,2);
  mob       = Ufielddepmob(mesh,data.un,data.Fn,data.vsatn,data.mubn);
  An        = Uscharfettergummel(mesh,data.V(Sinodes),mob);
  mob       = Ufielddepmob(mesh,data.up,data.Fp,data.vsatp,data.mubp);
  Ap        = Uscharfettergummel(mesh,-data.V(Sinodes),mob);
  divrg     = An * data.n + Ap * data.p;

  for con = 1:length(contacts)

    cedges       = [];
    cedges       = [cedges,find(mesh.e(5,:)==contacts(con))];
    cnodes       = mesh.e(1:2,cedges);
    cnodes       = [cnodes(1,:) cnodes(2,:)];
    cnodes       = unique(cnodes);
    current(con) = sum(divrg(cnodes));
    
  endfor

  Is      = q*data.us*data.Vs*data.ns;
  current = current * Is;

endfunction
