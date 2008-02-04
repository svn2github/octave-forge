function [odata,it,res] =...
      DDGgummelmap (x,idata,toll,maxit,ptoll,pmaxit,verbose)

 
%
% [odata,it,res] =...
%            DDGgummelmap (x,idata,toll,maxit,ptoll,pmaxit,verbose)
%
% Solves the scaled stationary bipolar DD equation system
%     using Gummel algorithm
%
%     input: x          spatial grid
%            idata.D    doping profile
%            idata.p    initial guess for hole concentration
%            idata.n    initial guess for electron concentration
%            idata.V    initial guess for electrostatic potential
%            idata.Fn   initial guess for electron Fermi potential
%            idata.Fp   initial guess for hole Fermi potential
%            idata.l2   scaled electric permittivity (diffusion coefficient in Poisson equation)
%            idata.un   scaled electron mobility
%            idata.up   scaled electron mobility
%            idata.nis  scaled intrinsic carrier density
%            idata.tn   scaled electron lifetime
%            idata.tp   scaled hole lifetime
%            toll       tolerance for Gummel iterarion convergence test
%            maxit      maximum number of Gummel iterarions
%            ptoll      tolerance for Newton iterarion convergence test for non linear Poisson
%            pmaxit     maximum number of Newton iterarions
%            verbose    verbosity level: 0,1,2
%
%     output: odata.n     electron concentration
%             odata.p     hole concentration
%             odata.V     electrostatic potential
%             odata.Fn    electron Fermi potential
%             odata.Fp    hole Fermi potential
%             it          number of Gummel iterations performed
%             res         total potential increment at each step

## This file is part of 
##
## SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
## -------------------------------------------------------------------
## Copyright (C) 2004-2007  Carlo de Falco
##
##
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


odata = idata;

Nnodes=rows(x);

D         = idata.D;
vout(:,1) = idata.V;
hole_density (:,1) = idata.p;
electron_density (:,1)= idata.n;
fermin (:,1)=idata.Fn;
fermip (:,1)=idata.Fp;

for i=1:1:maxit
	if (verbose>1)
		fprintf(1,'*****************************************************************\n');  
		fprintf(1,'****    start of gummel iteration number: %d\n',i);
		fprintf(1,'*****************************************************************\n');  
    end

	if (verbose>1)
		fprintf(1,'solving non linear poisson equation\n\n');
    end
	[vout(:,2),electron_density(:,2),hole_density(:,2)] =...
	DDGnlpoisson (x,[1:Nnodes],vout (:,1),electron_density(:,1),hole_density(:,1),...
	fermin(:,1),fermip(:,1),D,idata.l2,ptoll,pmaxit,verbose);
	
	if (verbose>1)
		fprintf (1,'\n\nupdating electron qfl\n\n');
    end
	electron_density(:,3)=...
	DDGelectron_driftdiffusion(vout(:,2), x, electron_density(:,2),hole_density(:,2),idata.nis,idata.tn,idata.tp,idata.un);
    
    fermin(:,2) = DDGn2phin(vout(:,2),electron_density(:,3));
    fermin(1,2)   = idata.Fn(1);
    fermin(end:2) = idata.Fn(end);
    
	if (verbose>1)
		fprintf(1,'updating hole qfl\n\n');
    end

	hole_density(:,3)=...
    DDGhole_driftdiffusion(vout(:,2), x, hole_density(:,2),electron_density(:,2),idata.nis,idata.tn,idata.tp,idata.up);
    fermip(:,2) = DDGp2phip(vout(:,2),hole_density(:,3));
    fermip(1,2)   = idata.Fp(1);
    fermip(end,2) = idata.Fp(end);
    
    if (verbose>1)
		fprintf(1,'checking for convergence\n\n');
    end
	nrfn= norm(fermin(:,2)-fermin(:,1),inf);
	nrfp= norm (fermip(:,2)-fermip(:,1),inf);
	nrv = norm (vout(:,2)-vout(:,1),inf);
	nrm(i) = max([nrfn;nrfp;nrv]);
	
	if (verbose>1)
		fprintf (1,' max(|phin_(k+1)-phinn_(k)| , |phip_(k+1)-phip_(k)| , |v_(k+1)- v_(k)| )= %d\n',nrm(i));
    end
	if (nrm(i)<toll)
		break
    end

	vout(:,1) = vout(:,end);
	hole_density (:,1) = hole_density (:,end) ;
	electron_density (:,1)= electron_density (:,end);
	fermin (:,1)= fermin (:,end);
	fermip (:,1)= fermip (:,end);
	
	
	if(verbose)
		DDGplotresults(x,electron_density,hole_density,vout,fermin,fermip);		
    end
end

it = i;
res = nrm;

if (verbose>0)
	fprintf(1,'\n\nInitial guess computed by DD: # of Gummel iterations = %d\n\n',it);
end

odata.n     = electron_density(:,end);
odata.p     = hole_density(:,end);
odata.V     = vout(:,end);
odata.Fn    = fermin(:,end);
odata.Fp    = fermip(:,end);



