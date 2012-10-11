## Copyright (C) 2012 Juan Pablo Carbajal
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

function [PathLength CyclesLength]=getAllPath(graph)
#
# graph is a Torsche Graph

# Using DANIELSON, GORDON . On finding simple paths and circuits in a
# graph. IEEE Trans. Circuit Theor. 15 (1968), 294-295.
  N=numel(graph.N);
  A=graph.adj;
  B=A;
  [x y]=find(A==1);
  i=sub2ind(size(A),x,y);
  B(i)=y;

  Ac=graph2cell(A,'adj');
  Bc=graph2cell(B,'varadj');

  P=cellmatprod(Bc,Ac);
  [P cycles]=simplepath(P);

  i=1;
  notemptyp=~iscellempty(P);
  notemptyc=~iscellempty(cycles);
  PathLength=[];
  CyclesLength=[];
  while any(notemptyp(:)) || any(notemptyc(:))
      if any(notemptyp(:))
          PathLength{i}=P;
      end
      if any(notemptyc(:))
          CyclesLength{i}=cycles;
      end
      P=cellmatprod(Bc,P);
      [P cycles]=simplepath(P);
      i=i+1;
      notemptyp=~iscellempty(P);
      notemptyc=~iscellempty(cycles);
  end

endfunction
