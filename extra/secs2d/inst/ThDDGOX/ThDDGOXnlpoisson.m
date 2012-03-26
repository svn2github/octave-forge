## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn {Function File}@
## {@var{V},@var{n},@var{p},@var{res},@var{niter}} =@
## ThDDGOXnlpoisson(@var{mesh},@var{Dsides},@var{Sinodes},@var{SiDnodes},@
##                @var{Sielements},@var{Vin},@var{Vthn},@var{Vthp},@var{nin},@var{pin},@
##                @var{Fnin},@var{Fpin},@var{D},@var{l2},@
##                @var{l2ox},@var{toll},@var{maxit},@var{verbose})
##
## Solve -\lambda^2 V'' + (n(V,Fn,Tn) - p(V,Fp,Tp) -D) = 0
##
## @end deftypefn

function [V,n,p,res,niter] = ThDDGOXnlpoisson (mesh,Dsides,Sinodes,SiDnodes,Sielements,Vin,Vthn,Vthp,nin,pin,Fnin,Fpin,D,l2,l2ox,toll,maxit,verbose)

  global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS 

  ## Set some useful constants
  dampit    = 3;
  dampcoeff = 2;

  ## Setup FEM data structures
  nodes     = mesh.p;
  elements  = mesh.t;
  Nnodes    = length(nodes);
  Nelements = length(elements);
  ## Set list of nodes with Dirichelet BCs
  Dnodes    = Unodesonside(mesh,Dsides);
  ## Set values of Dirichelet BCs
  Bc        = zeros(length(Dnodes),1);
  ## Set list of nodes without Dirichelet BCs
  Varnodes  = setdiff([1:Nnodes],Dnodes);

  ## Initialization:
  ## - \lambda^2 (\delta V)'' + (\frac{\partial n}{\partial V} - \frac{\partial p}{\partial V})= -R

  ## Set n_1 = nin and V = Vin
  V  = Vin;
  Fn = Fnin;
  Fp = Fpin;
  n  = exp((V(Sinodes)-Fn)./Vthn);
  p  = exp((-V(Sinodes)+Fp)./Vthp);

  n(SiDnodes) = nin(SiDnodes);
  p(SiDnodes) = pin(SiDnodes);

  ## Compute LHS matrices
  ## Compute FEM approximation of L = -  \frac{d^2}{x^2}
  if (isempty(DDGOXNLPOISSON_LAP))
    coeff              = l2ox * ones(Nelements,1);
    coeff(Sielements)  = l2;
    DDGOXNLPOISSON_LAP = Ucomplap (mesh,coeff);
  endif

  ## Compute Mv = (n + p) and the (lumped) mass matrix M
  if (isempty(DDGOXNLPOISSON_MASS))
    coeffe              = zeros(Nelements,1);
    coeffe(Sielements)  = 1;
    DDGOXNLPOISSON_MASS = Ucompmass2(mesh,ones(Nnodes,1),coeffe);
  endif
  freecarr          = zeros(Nnodes,1);
  freecarr(Sinodes) = (n./Vthn + p./Vthp);

  Mv =  freecarr;
  M  =  DDGOXNLPOISSON_MASS*spdiag(Mv);

  ## Compute RHS vector (-residual)
  ## Compute T0 = \frac{q}{\epsilon} (n - p - D)
  if (isempty(DDGOXNLPOISSON_RHS))
    coeffe             = zeros(Nelements,1);
    coeffe(Sielements) = 1;
    DDGOXNLPOISSON_RHS = Ucompconst (mesh,ones(Nnodes,1),coeffe);
  endif
  totcharge          = zeros(Nnodes,1);
  totcharge(Sinodes) = (n - p - D);
  Tv0 = totcharge;
  T0  = Tv0 .* DDGOXNLPOISSON_RHS;

  ## Build LHS matrix and RHS of the linear system for 1st Newton step
  A = DDGOXNLPOISSON_LAP + M;
  R = DDGOXNLPOISSON_LAP * V  + T0; 

  ## Apply boundary conditions
  A(Dnodes,:) = [];
  A(:,Dnodes) = [];
  R(Dnodes)   = [];

  ## We need \norm{R_1} and \norm{R_k} for the convergence test   
  normr(1)	=  norm(R,inf);
  relresnorm 	= 1;
  reldVnorm   = 1;
  normrnew	= normr(1);
  dV          = V*0;

  ## Start of the newton cycle
  for newtit = 1:maxit
    if (verbose>2)
      fprintf(1,"\n***\nNewton iteration: %d, reldVnorm = %e\n***\n",newtit,reldVnorm);
    endif
    dV(Varnodes) = (A)\(-R);
    dV(Dnodes)   = 0;

    ## Start of th damping procedure
    tk = 1;
    for dit = 1:dampit
      if (verbose>2)
	fprintf(1,"\ndamping iteration: %d, residual norm = %e\n",dit,normrnew);
      endif
      Vnew  = V + tk * dV;
      n     = exp((Vnew(Sinodes)-Fn)./Vthn);
      p     = exp((-Vnew(Sinodes)+Fp)./Vthp);

      n(SiDnodes) = nin(SiDnodes);
      p(SiDnodes) = pin(SiDnodes);
      ## Compute LHS matrices
      ## Compute FEM approximation of L = -  \frac{d^2}{x^2}
      ## Compute Mv = (n + p) and the (lumped) mass matrix M
      freecarr          = zeros(Nnodes,1);
      freecarr(Sinodes) = (n./Vthn + p./Vthp);  
      Mv                =  freecarr;
      M                 =  DDGOXNLPOISSON_MASS*spdiag(Mv);
      
      ## Compute RHS vector (-residual)
      ## Compute T0 = \frac{q}{\epsilon} (n - p - D)
      totcharge( Sinodes) = (n - p - D);
      Tv0                 = totcharge;
      T0                  = Tv0 .* DDGOXNLPOISSON_RHS;
      
      ## Build LHS matrix and RHS of the linear system for 1st Newton step
      A 		= DDGOXNLPOISSON_LAP + M;
      R 		= DDGOXNLPOISSON_LAP * Vnew  + T0; 
      
      ## Apply boundary conditions
      A(Dnodes,:) = [];
      A(:,Dnodes) = [];
      R(Dnodes)   = [];
      
      ## Compute | R_{k+1} | for the convergence test
      normrnew = norm(R,inf);
      ## Check if more damping is needed
      if (normrnew > normr(newtit))
	tk = tk/dampcoeff;
      else
	if (verbose>2)
	  fprintf(1,"\nexiting damping cycle because residual norm = %e \n-----------\n",normrnew);
	endif		
	break
      endif
    endfor

    V               = Vnew;	
    normr(newtit+1) = normrnew;
    dVnorm          = norm(tk*dV,inf);
    pause(.1);
    ## Check if convergence has been reached
    reldVnorm       = dVnorm / norm(V,inf);
    if (reldVnorm <= toll)
      if(verbose>2)
	fprintf(1,"\nexiting newton cycle because reldVnorm= %e \n",reldVnorm);
      endif
      break
    endif

  endfor

  res   = normr;
  niter = newtit;

endfunction
