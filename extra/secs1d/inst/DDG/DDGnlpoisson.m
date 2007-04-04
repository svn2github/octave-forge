function [V,n,p,res,niter] = DDGnlpoisson (x,sinodes,Vin,nin,...
					   pin,Fnin,Fpin,D,l2,toll,maxit,verbose)

% [V,n,p,res,niter] = DDGnlpoisson (x,sinodes,Vin,nin,...
%             pin,Fnin,Fpin,D,l2,toll,maxit,verbose)
%     Solves the non linear Poisson equation
%     $$ - lamda^2 *V'' + (n(V,Fn) - p(V,Fp) -D)=0 $$
%     input:  x       spatial grid
%             sinodes index of the nodes of the grid which are in the
%                     semiconductor subdomain 
%                     (remaining nodes are assumed to be in the oxide subdomain)
%             Vin     initial guess for the electrostatic potential
%             nin     initial guess for electron concentration
%             pin     initial guess for hole concentration
%             Fnin    initial guess for electron Fermi potential
%             Fpin    initial guess for hole Fermi potential
%             D       doping profile
%             l2      scaled electric permittivity (diffusion coefficient)
%             toll    tolerance for convergence test
%             maxit   maximum number of Newton iterations
%             verbose verbosity level: 0,1,2
%     output: V       electrostatic potential
%             n       electron concentration
%             p       hole concentration
%             res     residual norm at each step
%             niter   number of Newton iterations

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
##  along with SECS1D; if not, write to the Free Software
##  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
##  USA


%% Set some useful constants
dampit 		= 10;
dampcoeff	= 2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% convert grid info to FEM form
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Ndiricheletnodes 	= 2;
nodes 		        = x;
sielements          = sinodes(1:end-1);

Nnodes		        = length(nodes);


totdofs             = Nnodes - Ndiricheletnodes ;

elements            = [[1:Nnodes-1]' , [2:Nnodes]'];
Nelements           = size(elements,1);

BCnodes             = [1;Nnodes];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% 		initialization:
%% 		we're going to solve
%% 		$$ -  lamda^2*(\delta V)'' +  (\frac{\partial n}{\partial V} -
%%            \frac{\partial p}{\partial V})= -R $$
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set $$ n_1 = nin $$ and $$ V = Vin $$
V = Vin;
Fn = Fnin;
Fp = Fpin;
n = DDGphin2n(V(sinodes),Fn);
p = DDGphip2p(V(sinodes),Fp);
if (sinodes(1)==1)
    n(1)=nin(1);
    p(1)=pin(1);
end
if (sinodes(end)==Nnodes)
    n(end)=nin(end);
    p(end)=pin(end);
end

%%%
%%% Compute LHS matrices
%%%

%% let's compute  FEM approximation of $$ L = -  \frac{d^2}{x^2} $$
L      = Ucomplap (nodes,Nnodes,elements,Nelements,l2.*ones(Nelements,1));

%% compute $$ Mv =  ( n + p)  $$
%% and the (lumped) mass matrix M
Mv            =  zeros(Nnodes,1);
Mv(sinodes)   =  (n + p);
Cv            =  zeros(Nelements,1);
Cv(sielements)=  1;
M             =  Ucompmass (nodes,Nnodes,elements,Nelements,Mv,Cv);

%%%
%%% Compute RHS vector (-residual)
%%%

%% now compute $$ T0 =  (n - p - D) $$
Tv0            =  zeros(Nnodes,1);
Tv0(sinodes)   = (n - p - D);
Cv            =  zeros(Nelements,1);
Cv(sielements)=  1;
T0             =  Ucompconst (nodes,Nnodes,elements,Nelements,Tv0,Cv);

%% now we're ready to build LHS matrix and RHS of the linear system for 1st Newton step
A 		= L + M;
R 		= L * V  + T0; 

%% Apply boundary conditions
A(BCnodes,:)	= [];
A(:,BCnodes)	= [];

R(BCnodes)	= [];

%% we need $$ \norm{R_1} $$ and $$ \norm{R_k} $$ for the convergence test   
normr(1)		=  norm(R,inf);
relresnorm 	= 1;
reldVnorm   = 1;
normrnew	= normr(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% START OF THE NEWTON CYCLE
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for newtit=1:maxit
    if verbose
        fprintf(1,'\n newton iteration: %d, reldVnorm = %e',newtit,reldVnorm);
        
    end

    dV =[0;(A)\(-R);0];
    
    
    
    %%%%%%%%%%%%%%%%%%
    %% Start of the damping procedure
    %%%%%%%%%%%%%%%%%%
    tk = 1;
    for dit = 1:dampit
        if verbose
            fprintf(1,'\n damping iteration: %d, residual norm = %e',dit,normrnew);
        end
        Vnew   = V + tk * dV;
        
        n = DDGphin2n(Vnew(sinodes),Fn);
        p = DDGphip2p(Vnew(sinodes),Fp);
        if (sinodes(1)==1)
            n(1)=nin(1);
            p(1)=pin(1);
        end
        if (sinodes(end)==Nnodes)
            n(end)=nin(end);
            p(end)=pin(end);
        end
        %%%
        %%% Compute LHS matrices
        %%%
        
        %% let's compute  FEM approximation of $$ L = -  \frac{d^2}{x^2} $$
        %L      = Ucomplap (nodes,Nnodes,elements,Nelements,ones(Nelements,1));
        
        %% compute $$ Mv =  ( n + p)  $$
        %% and the (lumped) mass matrix M
        Mv            =  zeros(Nnodes,1);
        Mv(sinodes)   =  (n + p);
        Cv            =  zeros(Nelements,1);
        Cv(sielements)=  1;        
        M    = Ucompmass (nodes,Nnodes,elements,Nelements,Mv,Cv);
        
        %%%
        %%% Compute RHS vector (-residual)
        %%%
        
        %% now compute $$ T0 =  (n - p - D) $$
        Tv0            =  zeros(Nnodes,1);
        Tv0(sinodes)   =  (n - p - D);
        Cv            =  zeros(Nelements,1);
        Cv(sielements)=  1;
        T0     = Ucompconst (nodes,Nnodes,elements,Nelements,Tv0,Cv);
        
        %% now we're ready to build LHS matrix and RHS of the linear system for 1st Newton step
        Anew 		= L + M;
        Rnew 		= L * Vnew  + T0; 
        
        %% Apply boundary conditions
        Anew(BCnodes,:)	= [];
        Anew(:,BCnodes)	= [];
        
        Rnew(BCnodes)	= [];
        
        if ((dit>1)&(norm(Rnew,inf)>=norm(R,inf)))
            if verbose
                fprintf(1,'\nexiting damping cycle \n');
            end
            break
        else
            A = Anew;
            R = Rnew;
        end
    
        %% compute $$ | R_{k+1} | $$ for the convergence test
        normrnew= norm(R,inf);
        
        % check if more damping is needed
        if (normrnew > normr(newtit))
            tk = tk/dampcoeff;
        else
            if verbose
                fprintf(1,'\nexiting damping cycle because residual norm = %e \n',normrnew);
            end		
            break
        end	
    end

    V		            = Vnew;	
    normr(newtit+1) 	= normrnew;
    dVnorm              = norm(tk*dV,inf);
    % check if convergence has been reached
    reldVnorm           = dVnorm / norm(V,inf);
    if (reldVnorm <= toll)
        if(verbose)
            fprintf(1,'\nexiting newton cycle because reldVnorm= %e \n',reldVnorm);
        end
        break
    end
end

res = normr;
niter = newtit;

% Last Revision:
% $Author$
% $Date$


