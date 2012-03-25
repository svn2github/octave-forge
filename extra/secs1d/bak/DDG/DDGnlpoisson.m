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
## {@var{V},@var{n},@var{p},@var{res},@var{niter}} = @
## DDGnlpoisson(@var{x},@var{sinodes},@var{Vin},@var{nin},@var{pin},@var{Fnin},@var{Fpin},@var{D},@var{l2},@var{toll},@var{maxit},@var{verbose})
##
## Solve the non linear Poisson equation
## 
## - lamda^2 *V'' + (n(V,Fn) - p(V,Fp) -D) = 0 
##
## Input:
## @itemize @minus
## @item x: spatial grid
## @item sinodes: index of the nodes of the grid which are in the
## semiconductor subdomain (remaining nodes are assumed to be in the oxide subdomain)
## @item Vin: initial guess for the electrostatic potential
## @item nin: initial guess for electron concentration
## @item pin: initial guess for hole concentration
## @item Fnin: initial guess for electron Fermi potential
## @item Fpin: initial guess for hole Fermi potential
## @item D: doping profile
## @item l2: scaled electric permittivity (diffusion coefficient)
## @item toll: tolerance for convergence test
## @item maxit: maximum number of Newton iterations
## @item verbose: verbosity level (0,1,2)
## @end itemize
##
## Output:
## @itemize @minus
## @item V: electrostatic potential
## @item n: electron concentration
## @item p: hole concentration
## @item res: residual norm at each step
## @item niter: number of Newton iterations
## @end itemize
##
## @end deftypefn

function [V,n,p,res,niter] = DDGnlpoisson (x,sinodes,Vin,nin,pin,Fnin,Fpin,D,l2,toll,maxit,verbose)

  ## Set some useful constants
dampit 		= 10;
dampcoeff	= 2;

  ## Convert grid info to FEM form
Ndiricheletnodes 	= 2;
nodes 		        = x;
sielements          = sinodes(1:end-1);
Nnodes		        = length(nodes);
totdofs             = Nnodes - Ndiricheletnodes ;
elements            = [[1:Nnodes-1]' , [2:Nnodes]'];
Nelements           = size(elements,1);
BCnodes             = [1;Nnodes];

  ## Initialization
V = Vin;
Fn = Fnin;
Fp = Fpin;
n = DDGphin2n(V(sinodes),Fn);
p = DDGphip2p(V(sinodes),Fp);
if (sinodes(1)==1)
    n(1)=nin(1);
    p(1)=pin(1);
  endif
if (sinodes(end)==Nnodes)
    n(end)=nin(end);
    p(end)=pin(end);
  endif

  ## Compute LHS matrices
L      = Ucomplap (nodes,Nnodes,elements,Nelements,l2.*ones(Nelements,1));

  ## Compute Mv =  ( n + p)
Mv            =  zeros(Nnodes,1);
Mv(sinodes)   =  (n + p);
Cv            =  zeros(Nelements,1);
Cv(sielements)=  1;
M             =  Ucompmass (nodes,Nnodes,elements,Nelements,Mv,Cv);

  ## Compute RHS vector
Tv0            =  zeros(Nnodes,1);
Tv0(sinodes)   = (n - p - D);
Cv            =  zeros(Nelements,1);
Cv(sielements)=  1;
T0             =  Ucompconst (nodes,Nnodes,elements,Nelements,Tv0,Cv);

  ## Build LHS matrix and RHS of the linear system for 1st Newton step
A 		= L + M;
R 		= L * V  + T0; 

  ## Apply boundary conditions
A(BCnodes,:)	= [];
A(:,BCnodes)	= [];
R(BCnodes)	= [];


normr(1)		=  norm(R,inf);
relresnorm 	= 1;
reldVnorm   = 1;
normrnew	= normr(1);


  ## Start of the newton cycle
for newtit=1:maxit
    if verbose
        fprintf(1,"\n newton iteration: %d, reldVnorm = %e",newtit,reldVnorm);
    endif
    dV =[0;(A)\(-R);0];
    
    ## Start of the damping procedure
    tk = 1;
    for dit = 1:dampit
        if verbose
        fprintf(1,"\n damping iteration: %d, residual norm = %e",dit,normrnew);
      endif
        Vnew   = V + tk * dV;
        n = DDGphin2n(Vnew(sinodes),Fn);
        p = DDGphip2p(Vnew(sinodes),Fp);
        if (sinodes(1)==1)
            n(1)=nin(1);
            p(1)=pin(1);
      endif
        if (sinodes(end)==Nnodes)
            n(end)=nin(end);
            p(end)=pin(end);
      endif
        
      ## Compute LHS matrices
        Mv            =  zeros(Nnodes,1);
        Mv(sinodes)   =  (n + p);
        Cv            =  zeros(Nelements,1);
        Cv(sielements)=  1;        
        M    = Ucompmass (nodes,Nnodes,elements,Nelements,Mv,Cv);
        
      ## Compute RHS vector (-residual)
        Tv0            =  zeros(Nnodes,1);
        Tv0(sinodes)   =  (n - p - D);
        Cv            =  zeros(Nelements,1);
        Cv(sielements)=  1;
        T0     = Ucompconst (nodes,Nnodes,elements,Nelements,Tv0,Cv);
        
      ## Build LHS matrix and RHS of the linear system for 1st Newton step
        Anew 		= L + M;
        Rnew 		= L * Vnew  + T0; 
        
      ## Apply boundary conditions
        Anew(BCnodes,:)	= [];
        Anew(:,BCnodes)	= [];
        Rnew(BCnodes)	= [];
        
        if ((dit>1)&(norm(Rnew,inf)>=norm(R,inf)))
            if verbose
          fprintf(1,"\nexiting damping cycle \n");
        endif
            break
        else
            A = Anew;
            R = Rnew;
      endif
    
      ## Compute | R_{k+1} | for the convergence test
        normrnew= norm(R,inf);
        
      ## Check if more damping is needed
        if (normrnew > normr(newtit))
            tk = tk/dampcoeff;
        else
            if verbose
          fprintf(1,"\nexiting damping cycle because residual norm = %e \n",normrnew);
        endif		
            break
      endif	
    endfor

    V		            = Vnew;	
    normr(newtit+1) 	= normrnew;
    dVnorm              = norm(tk*dV,inf);

    ## Check if convergence has been reached
    reldVnorm           = dVnorm / norm(V,inf);
    if (reldVnorm <= toll)
        if(verbose)
        fprintf(1,"\nexiting newton cycle because reldVnorm= %e \n",reldVnorm);
      endif
        break
    endif

  endfor

res = normr;
niter = newtit;

endfunction