function [odata,it,res] = DDNnewtonmap (x,idata,toll,maxit,verbose)

%
% [odata,it,res] = DDNnewtonmap (x,idata,toll,maxit,verbose)
%
%     Solves the scaled stationary bipolar DD equation system
%     using a coupled Newton algorithm
%
%     input: x              spatial grid
%            idata.D        doping profile
%            idata.p        initial guess for hole concentration
%            idata.n        initial guess for electron concentration
%            idata.V        initial guess for electrostatic potential
%            idata.Fn       initial guess for electron Fermi potential
%            idata.Fp       initial guess for hole Fermi potential
%            idata.l2       scaled electric permittivity (diffusion coefficient in Poisson equation)
%            idata.un       scaled electron mobility
%            idata.up       scaled electron mobility
%            idata.nis      scaled intrinsic carrier density
%            idata.tn       scaled electron lifetime
%            idata.tp       scaled hole lifetime
%            toll           tolerance for Newton iterarion convergence test
%            maxit          maximum number of Newton iterarions
%            verbose        verbosity level: 0,1,2
%
%     output: odata.n     electron concentration
%             odata.p     hole concentration
%             odata.V     electrostatic potential
%             odata.Fn    electron Fermi potential
%             odata.Fp    hole Fermi potential
%             it          number of Newton iterations performed
%             res         residual at each step         
    
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create the complete unknown vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
u = [V; n; p];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% build fem matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = Ucomplap (x,Nnodes,elements,Nelements,idata.l2*ones(Nelements,1));
M = Ucompmass (x,Nnodes,elements,Nelements,ones(Nnodes,1),ones(Nelements,1));
DDn = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.un,1,V);
DDp = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.up,1,-V);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialise RHS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r1  = L * V + M * (n - p - D); 
r2  = DDn * n;
r3  = DDp * p;

RHS =- [...
r1;
r2;
r3
];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Apply BCs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RHS(BCnodes,:)= [];

nrm = norm(RHS,inf);
res(1) = nrm;

%%%%%%%%%%%%%%%%%%%%%%%
%% Begin Newton Cycle
%%%%%%%%%%%%%%%%%%%%%%%
for count = 1: maxit
  if verbose
    fprintf (1,'\n\n\nNewton Iteration Number:%d\n',count);	
  end
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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Build LHS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LHS =sparse([
	[A	B C];
	[DDD    E F];
	[G      H I];
    ]);
    
    %Apply BCs
    LHS(BCnodes,:)=[];    
    LHS(:,BCnodes)=[];
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Solve the linearised system
    %%%%%%%%%%%%%%%%%%%%%%%
    dutmp = (LHS) \ (RHS);
    dv    = dutmp(1:totaldofs);
    dn    = dutmp(totaldofs+1:2*totaldofs);
    dp    = dutmp(2*totaldofs+1:3*totaldofs);
    du    = [0;dv;0;0;dn;0;0;dp;0];
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %% Check Convergence
    %%%%%%%%%%%%%%%%%%%%%%%
    
    nrm_u = norm(u,inf);
	
    nrm_du = norm(du,inf);
	
    ratio = nrm_du/nrm_u; 
    if verbose
      fprintf (1,'ratio = %e\n', ratio);		
    end
    
    if (ratio <= toll)
        V 	    = u(1:Nnodes);
        n	    = u(Nnodes+1:2*Nnodes);
        p	    = u(2*Nnodes+1:end);
        res(count)  = nrm;
        break;
    end


    %%%%%%%%%%%%%%%%%%%%%%
    %% begin damping cycle
    %%%%%%%%%%%%%%%%%%%%%%
    tj = 1;
    
	
    for cc = 1:maxdamp
      if verbose
        fprintf (1,'\ndamping iteration number:%d\n',cc);
        fprintf (1,'reference residual norm:%e\n',nrm);
      end
        %%%%%%%%%%%%%%%%%%%%%%%%%
        %	Update the unknown vector		
        %%%%%%%%%%%%%%%%%%%%%%%%%
        utmp    = u + tj*du;
        Vnew 	    = utmp(1:Nnodes);
        nnew	    = utmp(Nnodes+1:2*Nnodes);
        pnew	    = utmp(2*Nnodes+1:end);
        
        %%%%%%%%%%%%%%%%%
        %% try a new RHS
        %%%%%%%%%%%%%%%%
        DDn = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.un,1,Vnew);
        DDp = Uscharfettergummel(x,Nnodes,elements,Nelements,idata.up,1,-Vnew);
        
        r1  = L * V + M * (nnew - pnew - D); 
        r2  = DDn * nnew;
        r3  = DDp * pnew;
        
        RHS =- [...
        r1;
        r2;
        r3
        ];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  Apply BCs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        RHS(BCnodes,:)= [];
        
        nrmtmp=norm(RHS,inf);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        %% Update the damping coefficient
        %%%%%%%%%%%%%%%%%%%%%%%%
        if verbose
	  fprintf(1,'residual norm:%e\n\n', nrmtmp);
        end
        
		if (nrmtmp>nrm)
			tj = tj/(dampcoef*cc);
			if verbose
			  fprintf (1,'\ndamping coefficients = %e',tj);    
			end
        else
			break;
        end
    end

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
        end
    end

    nrm = nrmtmp;
    
    res(count)  = nrm;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% convert result vector into distinct output vectors 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    V 	    = u(1:Nnodes);
    n	    = u(Nnodes+1:2*Nnodes);
    p	    = u(2*Nnodes+1:end);    
    
    nrm_du_old = nrm_du;
end

odata.V = V;
odata.n = n;
odata.p = p;
Fn   = V - log(n);
Fp   = V + log(p);

it   = count; 




