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
## {@var{odata},@var{it},@var{res}} = DDNnewtonmap(@var{x},@var{idata},@var{toll},@var{maxit},@var{verbose})
##
## Solve the scaled stationary bipolar DD equation system using a
## coupled Newton algorithm
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
## @item toll: tolerance for Newton iterarion convergence test
## @item maxit: maximum number of Newton iterarions
## @item verbose: verbosity level: 0,1,2
## @end itemize
##
## Output:
## @itemize @minus
## @item odata.n: electron concentration
## @item odata.p: hole concentration
## @item odata.V: electrostatic potential
## @item odata.Fn: electron Fermi potential
## @item odata.Fp: hole Fermi potential
## @item it: number of Newton iterations performed
## @item res: residual at each step
## @end itemize
##
## @end deftypefn

function [odata,it,res] = DDNnewtonmap (x,idata,toll,maxit,verbose)

  odata     = idata;
  Nnodes    = rows(x);
Nelements=Nnodes-1;
elements=[1:Nnodes-1;2:Nnodes]';
BCnodesp = [1,Nnodes];
BCnodes = [BCnodesp,BCnodesp+Nnodes,BCnodesp+2*Nnodes];
totaldofs= Nnodes-2;
dampcoef = 2;
maxdamp  = 2;

V = idata.V;
n = idata.n;
p = idata.p;
D = idata.D;

  ## Create the complete unknown vector
u = [V; n; p];

  ## Build fem matrices
L = Ucomplap (x,Nnodes,elements,Nelements,idata.l2*ones(Nelements,1));
M = Ucompmass (x,Nnodes,elements,Nelements,ones(Nnodes,1),ones(Nelements,1));
DDn = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.un,1,V);
DDp = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.up,1,-V);

  ## Initialise RHS 
r1  = L * V + M * (n - p - D); 
r2  = DDn * n;
r3  = DDp * p;
  RHS = - [ r1; r2; r3 ];

  ##  Apply BCs
RHS(BCnodes,:)= [];
nrm = norm(RHS,inf);
res(1) = nrm;

  ## Begin Newton Cycle
for count = 1: maxit
  if verbose
      fprintf (1,"\n\n\nNewton Iteration Number:%d\n",count);	
    endif
    Ln = Ucomplap (x,Nnodes,elements,Nelements,Umediaarmonica(idata.un*n));
    Lp = Ucomplap (x,Nnodes,elements,Nelements,Umediaarmonica(idata.up*p));
    Z  = sparse(zeros(Nnodes));    
    DDn = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.un,1,V);
    DDp = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.up,1,-V);
    
    A 	= L;
    B	= M;
    C	= -M;
    DDD	= -Ln;
    E	= DDn;
    F	= Z;
    G	= Lp;
    H	= Z;
    I	= DDp;
    
    ## Build LHS
    LHS =sparse([
	[A	B C];
	[DDD    E F];
	[G      H I];
    ]);
    
    ## Apply BCs
    LHS(BCnodes,:)=[];    
    LHS(:,BCnodes)=[];
    
    ## Solve the linearised system
    dutmp = (LHS) \ (RHS);
    dv    = dutmp(1:totaldofs);
    dn    = dutmp(totaldofs+1:2*totaldofs);
    dp    = dutmp(2*totaldofs+1:3*totaldofs);
    du    = [0;dv;0;0;dn;0;0;dp;0];
    
    ## Check Convergence
    nrm_u = norm(u,inf);
    nrm_du = norm(du,inf);
	
    ratio = nrm_du/nrm_u; 
    if verbose
      fprintf (1,"ratio = %e\n", ratio);		
    endif
    
    if (ratio <= toll)
        V 	    = u(1:Nnodes);
        n	    = u(Nnodes+1:2*Nnodes);
        p	    = u(2*Nnodes+1:end);
        res(count)  = nrm;
        break;
    endif

    ## Begin damping cycle
    tj = 1;
    
    for cc = 1:maxdamp
      if verbose
        fprintf (1,"\ndamping iteration number:%d\n",cc);
        fprintf (1,"reference residual norm:%e\n",nrm);
      endif
      ## Update the unknown vector		
        utmp    = u + tj*du;
        Vnew 	    = utmp(1:Nnodes);
        nnew	    = utmp(Nnodes+1:2*Nnodes);
        pnew	    = utmp(2*Nnodes+1:end);
      ## Try a new RHS
        DDn = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.un,1,Vnew);
        DDp = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.up,1,-Vnew);
        
        r1  = L * V + M * (nnew - pnew - D); 
        r2  = DDn * nnew;
        r3  = DDp * pnew;
        
      RHS =- [r1;r2;r3];
        
      ## Apply BCs
      RHS(BCnodes,:) = [];
        nrmtmp=norm(RHS,inf);
        
      ## Update the damping coefficient
        if verbose
	fprintf(1,"residual norm:%e\n\n", nrmtmp);
      endif
        
		if (nrmtmp>nrm)
			tj = tj/(dampcoef*cc);
			if verbose
	  fprintf (1,"\ndamping coefficients = %e",tj);    
	endif
        else
			break;
      endif
    endfor

    nrm_du = norm(tj*du,inf);
    u 	= utmp;
    
    if (count>1)
        ratio = nrm_du/nrm_du_old;
        if (ratio<.005)
            V 	    = u(1:Nnodes);
            n	    = u(Nnodes+1:2*Nnodes);
            p	    = u(2*Nnodes+1:end);            
            res(count)  = nrm;
            break;           
      endif
    endif
    nrm = nrmtmp;
    res(count)  = nrm;
	
    ## Convert result vector into distinct output vectors 
    V 	    = u(1:Nnodes);
    n	    = u(Nnodes+1:2*Nnodes);
    p	    = u(2*Nnodes+1:end);    
    nrm_du_old = nrm_du;
  endfor

odata.V = V;
odata.n = n;
odata.p = p;
Fn   = V - log(n);
Fp   = V + log(p);
it   = count; 

endfunction




