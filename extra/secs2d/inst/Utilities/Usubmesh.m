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
## @deftypefn {Function File}@
## {@var{omesh},@var{onodes},@var{oelements}} = Usubmesh(@var{imesh},@var{intrfc},@var{sdl},@var{short})
##
## Build the mesh structure for the given list of subdomains sdl
##
## NOTE: the intrfc parameter is unused and only kept as a legacy
##
## @end deftypefn

function [omesh,onodes,oelements]=Usubmesh(imesh,intrfc,sdl,short)

  nsd = length(sdl);

  ## Shp field remain unchanged
  if (~short)
    omesh.shp = imesh.shp;
  endif

  ## Set list of output triangles 
  oelements = [];
  for isd = 1:nsd
    oelements = [oelements find(imesh.t(4,:)==sdl(isd))];
  endfor

  omesh.t = imesh.t(:,oelements);

  ## Discard unneeded part of shg and wjacdet
  if (~short)
    omesh.shg     = imesh.shg(:,:,oelements);
    omesh.wjacdet = imesh.wjacdet(:,oelements);
  endif

  ## Set list of output nodes
  onodes   = unique(reshape(imesh.t(1:3,oelements),1,[]));
  omesh.p  = imesh.p(:,onodes);

  ## Use new node numbering in connectivity matrix
  indx(onodes) = [1:length(onodes)];
  iel = [1:length(oelements)];
  omesh.t(1:3,iel) = indx(omesh.t(1:3,iel));

  ## Set list of output edges
  omesh.e = [];
  for isd = 1:nsd
    omesh.e = [omesh.e imesh.e(:,imesh.e(7,:)==sdl(isd))];
    omesh.e = [omesh.e imesh.e(:,imesh.e(6,:)==sdl(isd))];
  endfor
  omesh.e = unique(omesh.e',"rows")';

  ## Use new node numbering in boundary segment list
  ied = [1:size(omesh.e,2)];
  omesh.e(1:2,ied) = indx(omesh.e(1:2,ied));

endfunction