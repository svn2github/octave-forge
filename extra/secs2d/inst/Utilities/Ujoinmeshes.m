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
## @deftypefn {Function File} {[@var{mesh}]} = Ujoinmeshes(@var{mesh1},@var{mesh2},@var{s1},@var{s2})
##
## Join two structured meshes into one mesh structure variable.
##
## Input:
## @itemize @minus
## @item @var{mesh1}, @var{mesh2}: standard PDEtool-like mesh, with field "p", "e", "t".
## @item @var{s1}, @var{s2}: number of the corresponding geometrical border edge for respectively mesh1 and mesh2.
## @end itemize
##
## Output:
## @itemize @minus
## @item @var{mesh}: standard PDEtool-like mesh, with field "p", "e", "t".
## @end itemize 
##
## WARNING: on the common edge the two meshes must share the same vertexes.
##
## @end deftypefn

function mesh=Ujoinmeshes(mesh1,mesh2,s1,s2)

  ## Make sure that the outside world is always 
  ## on the same side of the boundary of mesh1
  [mesh1.e(6:7,:),I] = sort(mesh1.e(6:7,:));
  for ic=1:size(mesh1.e,2)
    mesh1.e(1:2,ic) = mesh1.e(I(:,ic),ic);
  endfor

  intnodes1 = [];
  intnodes2 = [];

  j1 = [];
  j2 = [];

  for is=1:length(s1)    
    side1 = s1(is);side2 = s2(is);
    [i,j] = find(mesh1.e(5,:)==side1);
    j1    = [j1 j];
    [i,j] = find(mesh2.e(5,:)==side2);
    
    oldregion(side1) = max(max(mesh2.e(6:7,j)));
    j2               = [j2 j];
  endfor

  intnodes1 = [mesh1.e(1,j1),mesh1.e(2,j1)];
  intnodes2 = [mesh2.e(1,j2),mesh2.e(2,j2)];

  intnodes1 = unique(intnodes1);
  [tmp,I]   = sort(mesh1.p(1,intnodes1));
  intnodes1 = intnodes1(I);
  [tmp,I]   = sort(mesh1.p(2,intnodes1));
  intnodes1 = intnodes1(I);

  intnodes2 = unique(intnodes2);
  [tmp,I]   = sort(mesh2.p(1,intnodes2));
  intnodes2 = intnodes2(I);
  [tmp,I]   = sort(mesh2.p(2,intnodes2));
  intnodes2 = intnodes2(I);

  ## Delete redundant edges
  mesh2.e(:,j2) = [];

  ## Change edge numbers
  indici=[];consecutivi=[];
  indici = unique(mesh2.e(5,:));
  consecutivi (indici) = [1:length(indici)]+max(mesh1.e(5,:));
  mesh2.e(5,:)=consecutivi(mesh2.e(5,:));


  ## Change node indices in connectivity matrix
  ## and edge list
  indici      = [];
  consecutivi = [];
  indici      = 1:size(mesh2.p,2);
  offint      = setdiff(indici,intnodes2);

  consecutivi (offint)    = [1:length(offint)]+size(mesh1.p,2);
  consecutivi (intnodes2) = intnodes1;
  mesh2.e(1:2,:)          = consecutivi(mesh2.e(1:2,:));
  mesh2.t(1:3,:)          = consecutivi(mesh2.t(1:3,:));

  ## Delete redundant points
  mesh2.p(:,intnodes2) = [];

  ## Set region numbers
  regions             = unique(mesh1.t(4,:));
  newregions(regions) = 1:length(regions);
  mesh1.t(4,:)        = newregions(mesh1.t(4,:));

  ## Set region numbers
  regions             = unique(mesh2.t(4,:));
  newregions(regions) = [1:length(regions)]+max(mesh1.t(4,:));
  mesh2.t(4,:)        = newregions(mesh2.t(4,:));

  ## Set adjacent region numbers in edge structure 2
  [i,j]        = find(mesh2.e(6:7,:));
  i            = i+5;
  mesh2.e(i,j) = newregions(mesh2.e(i,j));

  ## Set adjacent region numbers in edge structure 1
  mesh1.e(6,j1) = newregions(oldregion(mesh1.e(5,j1)));

  ## Make the new p structure
  mesh.p = [mesh1.p mesh2.p];
  mesh.e = [mesh1.e mesh2.e];
  mesh.t = [mesh1.t mesh2.t];

endfunction