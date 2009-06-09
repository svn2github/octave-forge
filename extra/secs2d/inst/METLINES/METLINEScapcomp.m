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
## @deftypefn {Function File}{[@var{C},@var{L},@var{Lii},@var{LiI},@var{LII},@var{Dnodes},@var{Varnodes}]} =@
## METLINEScapcomp(@var{imesh},@var{epsilon},@var{contacts})
##
## @end deftypefn

function [C,L,Lii,LiI,LII,Dnodes,varnodes]= METLINEScapcomp(imesh,epsilon,contacts)

  Ncontacts = length(contacts);
  Nnodes    = columns(imesh.p);
  varnodes  = [1:Nnodes];

  for ii=1:Ncontacts
    Dnodes{ii} = Unodesonside(imesh,contacts{ii});
    varnodes   = setdiff(varnodes,Dnodes{ii});
  endfor

  L = Ucomplap (imesh,epsilon);

  for ii = 1:Ncontacts
    Lii{ii} = L(Dnodes{ii},Dnodes{ii});
    LiI{ii} = L(Dnodes{ii},varnodes);
  endfor

  LII =  L(varnodes,varnodes);

  for ii=1:Ncontacts
    for jj=ii:Ncontacts
      if ii==jj
	C(ii,jj) = sum(sum(Lii{ii}-LiI{ii}*(LII\(LiI{ii})')));
      else
	C(ii,jj) = sum(sum(-LiI{ii}*(LII\(LiI{jj})')));
      endif
    endfor
  endfor

  for ii=1:4
    for jj=1:ii-1
      C(ii,jj) = C(jj,ii);
    endfor
  endfor

endfunction