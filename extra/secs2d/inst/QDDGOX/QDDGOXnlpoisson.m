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
## {[@var{V},@var{n},@var{p},@var{res},@var{niter}]} = @
## QDDGOXnlpoisson(@var{mesh},@var{Dsides},@var{Sinodes},@var{SiDnodes},@var{Sielements},@
##                 @var{Vin},@var{nin},@var{pin},@var{Fnin},@var{Fpin},@
##                 @var{Gin},@var{Gpin},@var{D},@var{l2},@var{l2ox},@
##                 @var{toll},@var{maxit},@var{verbose})
##
## @end deftypefn

function [V,n,p,res,niter] = QDDGOXnlpoisson (mesh,Dsides,Sinodes,SiDnodes,Sielements,Vin,nin,pin,Fnin,Fpin,Gin,Gpin,D,l2,l2ox,toll,maxit,verbose)

  global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS 

  ## Set some useful constants
  dampit    = 3;
  dampcoeff = 2;

  ## Convert input vectors to columns
  if Ucolumns(D)>Urows(D)
    D = D';
  endif

  if Ucolumns(nin)>Urows(nin)
    nin = nin';
  endif

  if Ucolumns(pin)>Urows(pin)
    pin = pin';
  endif

  if Ucolumns(Vin)>Urows(Vin)
    Vin = Vin';
  endif

  if Ucolumns(Fnin)>Urows(Fnin)
    Fnin = Fnin';
  endif

  if Ucolumns(Fpin)>Urows(Fpin)
    Fpin = Fpin';
  endif

  ## Setup FEM data structures
  nodes     = mesh.p;
  elements  = mesh.t;
  Nnodes    = length(nodes);
  Nelements = length(elements);
  Dedges    = [];

  for ii = 1:length(Dsides)
    Dedges = [Dedges,find(mesh.e(5,:)==Dsides(ii))];
  endfor

  ## Set list of nodes with Dirichelet BCs
  Dnodes   = mesh.e(1:2,Dedges);
  Dnodes   = [Dnodes(1,:) Dnodes(2,:)];
  Dnodes   = unique(Dnodes);
  ## Set values of Dirichelet BCs
  Bc       = zeros(length(Dnodes),1);
  ## Set list of nodes without Dirichelet BCs
  Varnodes = setdiff([1:Nnodes],Dnodes);

  ## Initialization:
  ## - \lambda^2 (\delta V)'' +  (\frac{\partial n}{\partial V} - \frac{\partial p}{\partial V})= -R

  ## Set n_1 = nin and V = Vin
  V  = Vin;
  Fn = Fnin;
  Fp = Fpin;
  G  = Gin;
  Gp = Gpin;
  n  = exp(V(Sinodes)+G-Fn);
  p  = exp(-V(Sinodes)-Gp+Fp);

  n(SiDnodes) = nin(SiDnodes);
  p(SiDnodes) = pin(SiDnodes);

  ## Compute LHS matrices
  ## Compute FEM approximation of L = -  \frac{d^2}{x^2}
  if (isempty(DDGOXNLPOISSON_LAP))
    coeff              = l2ox * ones(Nelements,1);
    coeff(Sielements)  = l2;
    DDGOXNLPOISSON_LAP = Ucomplap (mesh,coeff);
  endif

  ## Compute Mv = ( n + p) and the (lumped) mass matrix M
  if (isempty(DDGOXNLPOISSON_MASS))
    Cvect               = zeros(Nelements,1);
    Cvect(Sielements)   = 1;
    DDGOXNLPOISSON_MASS = Ucompmass2 (mesh,ones(Nnodes,1),Cvect);
  endif
  freecarr          = zeros(Nnodes,1);
  freecarr(Sinodes) = (n + p);
  Mv                = freecarr;
  MV(SiDnodes)      = 0;
  M                 = DDGOXNLPOISSON_MASS*sparse(diag(Mv));

  ## Compute RHS vector (-residual)
  ## Compute T0 = \frac{q}{\epsilon} (n - p - D)
  if (isempty(DDGOXNLPOISSON_RHS))
    DDGOXNLPOISSON_RHS = Ucompconst (mesh,ones(Nnodes,1),ones(Nelements,1));
  endif
  totcharge          = zeros(Nnodes,1);
  totcharge(Sinodes) = (n - p - D);
  Tv0                = totcharge;
  T0                 = Tv0 .* DDGOXNLPOISSON_RHS;

  ## Build LHS matrix and RHS of the linear system for 1st Newton step
  A = DDGOXNLPOISSON_LAP + M;
  R = DDGOXNLPOISSON_LAP * V  + T0; 

  ## Apply boundary conditions
  A(Dnodes,:) = [];
  A(:,Dnodes) = [];
  R(Dnodes)   = [];

  ## \norm{R_1} and \norm{R_k} for the convergence test   
  normr(1)   =  norm(R,inf);
  relresnorm = 1;
  reldVnorm  = 1;
  normrnew   = normr(1);
  dV         = V*0;

  ## Start of the newton cycle
  for newtit = 1:maxit
    if (verbose>0)
      fprintf(1,"\n***\nNewton iteration: %d, reldVnorm = %e\n***\n",newtit,reldVnorm);
    endif


    dV(Varnodes) = (A)\(-R);
    dV(Dnodes)   = 0;

    ## Start of the damping procedure
    tk = 1;
    for dit = 1:dampit
      if (verbose>0)
	fprintf(1,"\ndamping iteration: %d, residual norm = %e\n",dit,normrnew);
      endif
      Vnew = V + tk * dV;
      n    = exp(Vnew(Sinodes)+G-Fn);
      p    = exp(-Vnew(Sinodes)-Gp+Fp);

      n(SiDnodes) = nin(SiDnodes);
      p(SiDnodes) = pin(SiDnodes);
      ## Compute LHS matrices
      ## Compute FEM approximation of L = -  \frac{d^2}{x^2}
      ## Compute Mv = (n + p) and the (lumped) mass matrix M
      freecarr          = zeros(Nnodes,1);
      freecarr(Sinodes) = (n + p);  
      Mv                =  freecarr;
      M                 =  DDGOXNLPOISSON_MASS*sparse(diag(Mv));%M     = Ucompmass (mesh,Mv);
      ## Compute RHS vector (-residual)
      ## Compute T0 = \frac{q}{\epsilon} (n - p - D)
      totcharge( Sinodes) = (n - p - D);
      Tv0                 = totcharge;
      T0                  = Tv0 .* DDGOXNLPOISSON_RHS;
      
      ## Build LHS matrix and RHS of the linear system for 1st Newton step
      A = DDGOXNLPOISSON_LAP + M;
      R = DDGOXNLPOISSON_LAP * Vnew  + T0; 
      
      ## Apply boundary conditions
      A (Dnodes,:) = [];
      A (:,Dnodes) = [];
      R(Dnodes)    = [];
      
      ## Compute | R_{k+1} | for the convergence test
      normrnew = norm(R,inf);
      
      ## Check if more damping is needed
      if (normrnew > normr(newtit))
	tk = tk/dampcoeff;
      else
	if (verbose>0)
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
    reldVnorm = dVnorm / norm(V,inf);
    if (reldVnorm <= toll)
      if(verbose>0)
	fprintf(1,"\nexiting newton cycle because reldVnorm= %e \n",reldVnorm);
      endif
      break
    endif
    
  endfor

  res   = normr;
  niter = newtit;

endfunction 