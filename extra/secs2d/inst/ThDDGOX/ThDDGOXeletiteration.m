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
## @deftypefn {Function File} {@var{},@var{}} = @
## ThDDGOXeletiteration(@var{imesh},@var{Dsides},@var{Simesh},@var{Sinodes},@var{Sielements},@var{SiDsides},@
##                      @var{idata},@var{toll},@var{maxit},@var{ptoll},@var{pmaxit},@var{verbose})
##
## @end deftypefn

function [odata,nrm]=ThDDGOXeletiteration(imesh,Dsides,Simesh,Sinodes,Sielements,SiDsides,idata,toll,maxit,ptoll,pmaxit,verbose)
  
  global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
 
  ## RRE param
  RREnnit      = [1,2];
  RRErank      = 7;  
  RREpattern   = URREcyclingpattern(RREnnit,RRErank,maxit);

  odata   = idata;
  V(:,1)  = idata.V;
  Fn(:,1) = idata.Fn;
  Fp(:,1) = idata.Fp;
  n(:,1)  = idata.n;
  p(:,1)  = idata.p;
  Tl      = idata.Tl;
  Tn      = idata.Tn;
  Tp      = idata.Tp;
  
  ## Set list of nodes with Dirichlet BCs
  Dnodes   = Unodesonside(imesh,Dsides);
  SiDnodes = Unodesonside(Simesh,SiDsides);

  SiNelements  = columns(Simesh.t);
  D            = idata.D;
  nrm          = 1;

  for ielet=1:maxit

    if (verbose>=1)
      fprintf(1,"*** start of inner iteration number: %d\n",ielet);
    endif
    
    if (verbose>=1)
      fprintf(1,"\t*** solving non linear poisson equation\n");
    endif

    Fnshift =  log(idata.ni) .* (1-Tn);
    Fpshift = -log(idata.ni) .* (1-Tp);
    
    [V(:,2),n(:,2),p(:,2)] = ThDDGOXnlpoisson (imesh,Dsides,Sinodes,SiDnodes,Sielements,...
					       V(:,1),Tn,Tp,...
					       n(:,1),p(:,1),Fn(:,1)+Fnshift,Fp(:,1)+Fpshift,D,...
					       idata.l2,idata.l2ox,ptoll,pmaxit,verbose-1);
    V(Dnodes,2)            = idata.V(Dnodes);
    
    if (verbose>=1)
      fprintf (1,"\t***\tupdating electron qfl\n");
    endif
    
    odata.V = V(:,2);
    odata.n = n(:,2);
    odata.p = p(:,2);
    mobn0   = idata.mobn0(imesh,Simesh,Sinodes,Sielements,odata);
    mobp0   = idata.mobp0(imesh,Simesh,Sinodes,Sielements,odata);
    mobn1   = idata.mobn1(imesh,Simesh,Sinodes,Sielements,odata);
    mobp1   = idata.mobp1(imesh,Simesh,Sinodes,Sielements,odata);
    n(:,3)  = ThDDGOXelectron_driftdiffusion(Simesh,SiDnodes,n(:,2),p(:,2),...
					     V(Sinodes,2),Tn,mobn0,mobn1,...
					     idata.tn,idata.tp,idata.ni,idata.ni);
    
    Fn(:,2) = V(Sinodes,2) - Tn .* log(n(:,3)) - Fnshift;

    n(SiDnodes,3)  = idata.n(SiDnodes);
    Fn(SiDnodes,2) = idata.Fn(SiDnodes);
    
    if (verbose>=1)
      fprintf(1,"\t***\tupdating hole qfl\n");
    endif
    
    p(:,3) = ThDDGOXhole_driftdiffusion(Simesh,SiDnodes,n(:,3),p(:,2),...
					V(Sinodes,2),Tp,mobp0,mobp1,...
					idata.tn,idata.tp,idata.ni,idata.ni);
    
    Fp(:,2)        = V(Sinodes,2) + Tp .* log(p(:,3)) - Fpshift;
    p(SiDnodes,3)  = idata.p(SiDnodes);
    Fp(SiDnodes,2) = idata.Fp(SiDnodes);
    
    ## Store result for RRE
    if RREpattern(ielet)>0
      Fermistore(:,RREpattern(ielet)) = [Fn(:,2);Fp(:,2)];
      if RREpattern(ielet+1)==0 % Apply RRE extrapolation
	if (verbose>=1)		
	  fprintf(1,"\n\t**********\n\tRRE EXTRAPOLATION STEP\n\t**********\n\n");
	endif
	Fermi   = Urrextrapolation(Fermistore);
	Fn(:,2) = Fermi(1:rows(Fn));
	Fp(:,2) = Fermi(rows(Fn)+1:end);
      endif
    endif
    
    if (verbose>=1)
      fprintf(1,"*** checking for convergence: ");
    endif
    
    nrfn       = norm (Fn(:,2)-Fn(:,1),inf);
    nrfp       = norm (Fp(:,2)-Fp(:,1),inf);
    nrv        = norm (V(:,2)-V(:,1),inf);
    nrm(ielet) = max([nrfn;nrfp;nrv]);
    
    if (verbose>=1)
      subplot(1,3,3);
      semilogy(nrm)
      pause(.1)
    endif
    
    if (verbose>=1)
      fprintf (1," max(|dFn|,|dFp|,|dV| )= %g\n\n",nrm(ielet));
    endif

    if (nrm(ielet)<toll)
      break
    endif
    
    V(:,1)  = V(:,2);
    n(:,1)  = n(:,3);
    p(:,1)  = p(:,3);
    Fn(:,1) = Fn(:,2);
    Fp(:,1) = Fp(:,2);
    
  endfor

  if (verbose>0)
    fprintf(1,"\n*** DD simulation over: # of electrical Gummel iterations = %d\n\n",ielet);
  endif

  odata      = idata;
  odata.n    = n(:,end);
  odata.p    = p(:,end);
  odata.V    = V(:,end);
  odata.Fn   = Fn(:,end);
  odata.Fp   = Fp(:,end);

endfunction