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
## {@var{w}} = QDDGOXcompdens(@var{mesh},@var{Dsides},@var{win},@var{vin},@var{fermiin},@var{d2},@var{toll},@var{maxit},@var{verbose})
##
## @end deftypefn

function w = QDDGOXcompdens(mesh,Dsides,win,vin,fermiin,d2,toll,maxit,verbose);

  global QDDGOXCOMPDENS_LAP QDDGOXCOMPDENS_MASS QDDGOXCOMPDENS_RHS 
  ## Set some usefull constants
  VErank = 4;

  ## Convert input vectors to columns
  if Ucolumns(win)>Urows(win)
    win = win';
  endif
  if Ucolumns(vin)>Urows(vin)
    vin = vin';
  endif
  if Ucolumns(fermiin)>Urows(fermiin)
    fermiin = fermiin';
  endif

  ## Convert grid info to FEM form
  nodes     = mesh.p;
  Nnodes    = size(nodes,2);
  elements  = mesh.t(1:3,:);
  Nelements = size(elements,2);
  Dedges    = [];

  for ii = 1:length(Dsides)
    Dedges = [Dedges,find(mesh.e(5,:)==Dsides(ii))];
  endfor

  ## Set list of nodes with Dirichelet BCs
  Dnodes   = mesh.e(1:2,Dedges);
  Dnodes   = [Dnodes(1,:) Dnodes(2,:)];
  Dnodes   = unique(Dnodes);
  Dvals    = win(Dnodes);
  Varnodes = setdiff([1:Nnodes],Dnodes);

  ## Initialization:
  ## -\delta^2 \Lap w_{k+1} + B'(w_k) \delta w_{k+1} =  2 * w_k

  ## Set w_1 = win
  w    = win;
  wnew = win;
  ## Compute FEM approximation of L = - \aleph \frac{d^2}{x^2}
  if (isempty(QDDGOXCOMPDENS_LAP))
    QDDGOXCOMPDENS_LAP = Ucomplap(mesh,ones(Nelements,1));
  endif
  L = d2*QDDGOXCOMPDENS_LAP;

  ## Compute G_k = F - V  + 2 V_{th} log(w)
  if (isempty(QDDGOXCOMPDENS_MASS))
    QDDGOXCOMPDENS_MASS = Ucompmass2 (mesh,ones(Nnodes,1),ones(Nelements,1));
  endif
  G    = fermiin - vin  + 2*log(w);
  Bmat = QDDGOXCOMPDENS_MASS*sparse(diag(G));
  nrm  = 1;


  ## Newton iteration start
  converged = 0;
  for jnewt =1:ceil(maxit/VErank)
    for k=1:VErank
      [w(:,k+1),converged,G,L,Bmat] = ...
	  onenewtit(w(:,k),G,fermiin,vin,L,Bmat,jnewt,mesh,Dnodes,Varnodes,Dvals,Nnodes,Nelements,toll);
      if converged
	break
      endif
    endfor
    if converged
      break
    endif
    w = Urrextrapolation(w);
  endfor
  ## Newton iteration end

  w = w(:,end);

endfunction


function [w,converged,G,L,Bmat] = onenewtit(w,G,fermiin,vin,L,Bmat,jnewt,mesh,Dnodes,Varnodes,Dvals,Nnodes,Nelements,toll);
  ## One newton iteration
  
  global QDDGOXCOMPDENS_LAP QDDGOXCOMPDENS_MASS QDDGOXCOMPDENS_RHS 
  dampit    = 5;
  dampcoeff = 2;
  converged = 0;
  wnew      =  w;
  res0      = norm((L + Bmat) * w,inf);
  
  
  ## Chose t_k to ensure positivity of w
  mm  = -min(G);
  pause(1)

  if (mm>2)
    tk = max( 1/(mm));
  else
    tk = 1;
  endif

  tmpmat = QDDGOXCOMPDENS_MASS*2;
  if (isempty(QDDGOXCOMPDENS_RHS))
    QDDGOXCOMPDENS_RHS = Ucompconst (mesh,ones(Nnodes,1),ones(Nelements,1));
  endif
  tmpvect= 2*QDDGOXCOMPDENS_RHS.*w;
  
  ## Damping iteration start
  for idamp = 1:dampit
    ## Compute B1mat = \frac{2}{t_k} and the (lumped) mass matrix
    ## B1mat(w_k)
    B1mat = tmpmat/tk;
    
    ## Build LHS matrix and RHS of the linear system for 1st Newton step
    A = L + B1mat + Bmat;
    b = tmpvect/tk;
    
    ## Apply boundary conditions
    A (Dnodes,:) = 0;
    b (Dnodes)   = 0;
    b            = b - A (:,Dnodes) * Dvals;
    A(Dnodes,:)  = [];
    A(:,Dnodes)  = [];
    b(Dnodes)	 = [];
    
    wnew(Varnodes) =  A\b;	
    
    ## Compute G_{k+1} = F - V  + 2 V_{th} log(w)
    G    = fermiin - vin  + 2*log(wnew);
    Bmat = QDDGOXCOMPDENS_MASS*sparse(diag(G));
    res   = norm((L + Bmat) * wnew,inf);
    
    if (res<res0)
      break
    else
      tk = tk/dampcoeff;
    endif
  endfor	
  ## Damping iteration end

  nrm = norm(wnew-w);
  
  if (nrm < toll)
    w= wnew;
    converged = 1;
  else
    w=wnew;
  endif
  
endfunction