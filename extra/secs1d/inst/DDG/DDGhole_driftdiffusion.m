## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
##
##  SECS1D is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  SECS1D is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with SECS1D; If not, see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
##
## @deftypefn {Function File}@
## {@var{p}} = DDGhole_driftdiffusio(@var{psi},@var{x},@var{pg},@var{n},@var{ni},@var{tn},@var{tp},@var{up})
##
## Solve the continuity equation for holes
##
## Input:
## @itemize @minus
## @item psi: electric potential
## @item x: spatial grid
## @item ng: initial guess and BCs for electron density
## @item n: electron density (for SRH recombination)
## @end itemize
##
## Output:
## @itemize @minus
## @item p: updated hole density
## @end itemize
##
## @end deftypefn

function p = DDGhole_driftdiffusion(psi,x,pg,n,ni,tn,tp,up)

nodes        = x;
Nnodes     =length(nodes);
elements   = [[1:Nnodes-1]' [2:Nnodes]'];
Nelements=size(elements,1);
Bcnodes = [1;Nnodes];

pl = pg(1);
pr = pg(Nnodes);
h=nodes(elements(:,2))-nodes(elements(:,1));
c=up./h;
Bneg=Ubernoulli(-(psi(2:Nnodes)-psi(1:Nnodes-1)),1);
Bpos=Ubernoulli( (psi(2:Nnodes)-psi(1:Nnodes-1)),1);


d0    = [c(1).*Bpos(1); c(1:end-1).*Bneg(1:end-1)+c(2:end).*Bpos(2:end); c(end)*Bneg(end)];
d1    = [1000;-c.* Bneg];
dm1   = [-c.* Bpos;1000];

A = spdiags([dm1 d0 d1],-1:1,Nnodes,Nnodes);
  b = zeros(Nnodes,1);## - A * pg;

  ## SRH Recombination term
SRHD = tp * (n + ni) + tn * (pg + ni);
SRHL = n ./ SRHD;
SRHR = ni.^2 ./ SRHD;

ASRH = Ucompmass (nodes,Nnodes,elements,Nelements,SRHL,ones(Nelements,1));
bSRH = Ucompconst (nodes,Nnodes,elements,Nelements,SRHR,ones(Nelements,1));

A = A + ASRH;
b = b + bSRH;

  ## Boundary conditions
b(Bcnodes)   = [];
b(1)         = - A(2,1) * pl;
b(end)       = - A(end-1,end) * pr;
A(Bcnodes,:) = [];
A(:,Bcnodes) = [];

p = [pl; A\b ;pr];

endfunction


