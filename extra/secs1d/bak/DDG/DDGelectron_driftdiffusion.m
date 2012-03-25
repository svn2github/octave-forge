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
## {@var{n}} = DDGelectron_driftdiffusion(@var{psi},@var{x},@var{ng},@var{p},@var{ni},@var{tn},@var{tp},@var{un})
##
## Solve the continuity equation for electrons
##
## Input:
## @itemize @minus
## @item psi: electric potential
## @item x: integration domain
## @item ng: initial guess and BCs for electron density
## @item p: hole density (for SRH recombination)
## @end itemize
##
## Output:
## @itemize @minus
## @item n: updated electron density
## @end itemize
##
## @end deftypefn

function n = DDGelectron_driftdiffusion(psi,x,ng,p,ni,tn,tp,un)

nodes        = x;
Nnodes     =length(nodes);

elements   = [[1:Nnodes-1]' [2:Nnodes]'];
Nelements=size(elements,1);

Bcnodes = [1;Nnodes];

nl = ng(1);
nr = ng(Nnodes);
h=nodes(elements(:,2))-nodes(elements(:,1));

c=1./h;
Bneg=Ubernoulli(-(psi(2:Nnodes)-psi(1:Nnodes-1)),1);
Bpos=Ubernoulli( (psi(2:Nnodes)-psi(1:Nnodes-1)),1);


d0    = [c(1).*Bneg(1); c(1:end-1).*Bpos(1:end-1)+c(2:end).*Bneg(2:end); c(end)*Bpos(end)];
d1    = [1000;-c.* Bpos];
dm1   = [-c.* Bneg;1000];

A = spdiags([dm1 d0 d1],-1:1,Nnodes,Nnodes);
b = zeros(Nnodes,1);%- A * ng;

  ## SRH Recombination term
SRHD = tp * (ng + ni) + tn * (p + ni);
SRHL = p ./ SRHD;
SRHR = ni.^2 ./ SRHD;

ASRH = Ucompmass (nodes,Nnodes,elements,Nelements,SRHL,ones(Nelements,1));
bSRH = Ucompconst (nodes,Nnodes,elements,Nelements,SRHR,ones(Nelements,1));

A = A + ASRH;
b = b + bSRH;

  ## Boundary conditions
b(Bcnodes)   = [];
b(1)         = - A(2,1) * nl;
b(end)       = - A(end-1,end) * nr;
A(Bcnodes,:) = [];
A(:,Bcnodes) = [];

n = [nl; A\b ;nr];

endfunction

