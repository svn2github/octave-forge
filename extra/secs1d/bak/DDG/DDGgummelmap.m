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
## {@var{odata},@var{it},@var{res}} =  DDGgummelmap(@var{x},@var{idata},@var{toll},@var{maxit},@var{ptoll},@var{pmaxit},@var{verbose})
##
## Solve the scaled stationary bipolar DD equation system using Gummel
## algorithm
##
## Input:
## @itemize @minus
## @item x: spatial grid
## @item idata.D: doping profile
## @item idata.p: initial guess for hole concentration
## @item idata.n: initial guess for electron concentration
## @item idata.V: initial guess for electrostatic potential
## @item idata.Fn: initial guess for electron Fermi potential
## @item idata.Fp: initial guess for hole Fermi potential
## @item idata.l2: scaled electric permittivity (diffusion coefficient in Poisson equation)
## @item idata.un: scaled electron mobility
## @item idata.up: scaled electron mobility
## @item idata.nis: scaled intrinsic carrier density
## @item idata.tn: scaled electron lifetime
## @item idata.tp: scaled hole lifetime
## @item toll: tolerance for Gummel iterarion convergence test
## @item maxit: maximum number of Gummel iterarions
## @item ptoll: tolerance for Newton iterarion convergence test for non linear Poisson
## @item pmaxit: maximum number of Newton iterarions
## @item verbose: verbosity level (0,1,2)
## @end itemize
##
## Output:
## @itemize @minus
## @item odata.n: electron concentration
## @item odata.p: hole concentration
## @item odata.V: electrostatic potential
## @item odata.Fn: electron Fermi potential
## @item odata.Fp: hole Fermi potential
## @item it: number of Gummel iterations performed
## @item res: total potential increment at each step
## @end itemize
##
## @end deftypefn

function [odata,it,res] = DDGgummelmap (x,idata,toll,maxit,ptoll,pmaxit,verbose)

  odata  = idata;
Nnodes=rows(x);

D         = idata.D;
vout(:,1) = idata.V;

hole_density (:,1) = idata.p;
electron_density (:,1)= idata.n;
fermin (:,1)=idata.Fn;
fermip (:,1)=idata.Fp;

for i=1:1:maxit
	if (verbose>1)
      fprintf(1,"*****************************************************************\n");  
      fprintf(1,"****    start of gummel iteration number: %d\n",i);
      fprintf(1,"*****************************************************************\n");  
    endif
    
    if (verbose>1)
      fprintf(1,"solving non linear poisson equation\n\n");
    endif

    [vout(:,2),electron_density(:,2),hole_density(:,2)] =...
	DDGnlpoisson (x,[1:Nnodes],vout(:,1),electron_density(:,1),hole_density(:,1),fermin(:,1),fermip(:,1),D,idata.l2,ptoll,pmaxit,verbose);
	
    if (verbose>1)
      fprintf (1,"\n\nupdating electron qfl\n\n");
    endif
    electron_density(:,3)=...
	DDGelectron_driftdiffusion(vout(:,2), x, electron_density(:,2),hole_density(:,2),idata.nis,idata.tn,idata.tp,idata.un);
    
    fermin(:,2) = DDGn2phin(vout(:,2),electron_density(:,3));
    fermin(1,2)   = idata.Fn(1);
    fermin(end:2) = idata.Fn(end);
    
	if (verbose>1)
      fprintf(1,"updating hole qfl\n\n");
    endif

    hole_density(:,3) = ...
    DDGhole_driftdiffusion(vout(:,2), x, hole_density(:,2),electron_density(:,2),idata.nis,idata.tn,idata.tp,idata.up);

    fermip(:,2) = DDGp2phip(vout(:,2),hole_density(:,3));
    fermip(1,2)   = idata.Fp(1);
    fermip(end,2) = idata.Fp(end);
    
    if (verbose>1)
      fprintf(1,"checking for convergence\n\n");
    endif

	nrfn= norm(fermin(:,2)-fermin(:,1),inf);
	nrfp= norm (fermip(:,2)-fermip(:,1),inf);
	nrv = norm (vout(:,2)-vout(:,1),inf);
	nrm(i) = max([nrfn;nrfp;nrv]);
	
	if (verbose>1)
      fprintf (1," max(|phin_(k+1)-phinn_(k)| , |phip_(k+1)-phip_(k)| , |v_(k+1)- v_(k)| )= %d\n",nrm(i));
    endif

	if (nrm(i)<toll)
		break
    endif

	vout(:,1) = vout(:,end);
	hole_density (:,1) = hole_density (:,end) ;
	electron_density (:,1)= electron_density (:,end);
	fermin (:,1)= fermin (:,end);
	fermip (:,1)= fermip (:,end);
	
	
	if(verbose)
		DDGplotresults(x,electron_density,hole_density,vout,fermin,fermip);		
    endif
  endfor

it = i;
res = nrm;

if (verbose>0)
    fprintf(1,"\n\nInitial guess computed by DD: # of Gummel iterations = %d\n\n",it);
  endif

odata.n     = electron_density(:,end);
odata.p     = hole_density(:,end);
odata.V     = vout(:,end);
odata.Fn    = fermin(:,end);
odata.Fp    = fermip(:,end);

endfunction