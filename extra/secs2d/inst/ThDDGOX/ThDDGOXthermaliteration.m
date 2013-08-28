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
## {[@var{thermdata},@var{nrm}]} =@
## ThDDGOXthermaliteration(@var{imesh},@var{Dsides},@var{Simesh},@var{Sinodes},@
##                @var{Sielements},@var{SiDsides},@var{thermdata},@var{toll},@var{maxit},@var{verbose})
##
## @end deftypefn

function [thermdata,nrm] = ThDDGOXthermaliteration(imesh,Dsides,Simesh,Sinodes,Sielements,SiDsides,thermdata,toll,maxit,verbose)

  ## RRE param
  RREnnit    = [10,2];
  RRErank    = maxit;  
  RREpattern = URREcyclingpattern(RREnnit,RRErank,maxit);
  ## Set list of nodes with Dirichlet BCs
  Dnodes   = Unodesonside(imesh,Dsides);
  SiDnodes = Unodesonside(Simesh,SiDsides);

  Tl  = thermdata.Tl;
  Tn  = thermdata.Tn;
  Tp  = thermdata.Tp;
  
  tldampcoef = 1;
  tndampcoef = 10;
  tpdampcoef = 10;
  
  mobn0   = thermdata.mobn0(imesh,Simesh,Sinodes,Sielements,thermdata);
  mobp0   = thermdata.mobp0(imesh,Simesh,Sinodes,Sielements,thermdata);
  mobn1   = thermdata.mobn1(imesh,Simesh,Sinodes,Sielements,thermdata);
  mobp1   = thermdata.mobp1(imesh,Simesh,Sinodes,Sielements,thermdata);
  twn0    = thermdata.twn0 (imesh,Simesh,Sinodes,Sielements,thermdata);
  twp0    = thermdata.twp0 (imesh,Simesh,Sinodes,Sielements,thermdata);
  twn1    = thermdata.twn1 (imesh,Simesh,Sinodes,Sielements,thermdata);
  twp1    = thermdata.twp1 (imesh,Simesh,Sinodes,Sielements,thermdata);
  [Ex,Ey] = Updegrad(Simesh,-thermdata.V(Sinodes));
  E       = [Ex;Ey];  

  [jnx,jny] = Ufvsgcurrent3(Simesh,thermdata.n,...
			    mobn0,mobn1,Tn,thermdata.V(Sinodes)-Tn);
  [jpx,jpy] = Ufvsgcurrent3(Simesh,thermdata.p,...
			    -mobp0,mobp1,Tp,-thermdata.V(Sinodes)-Tp);

  Jn = [jnx;jny];
  Jp = [jpx;jpy];
  
  for ith=1:maxit
    
    if (verbose>=1)
      fprintf(1,"*** start of inner iteration number: %d\n",ith);
    endif

    if (verbose>=1)
      fprintf(1,"\t***updating electron temperature\n");
    endif
    
    Tn  =  ThDDGOXupdateelectron_temp(Simesh,SiDnodes,thermdata.Tn,...
     				      thermdata.n,thermdata.p,...
     				      thermdata.Tl,Jn,E,mobn0,...
                                      twn0,twn1,thermdata.tn,thermdata.tp,...
     				      thermdata.ni,thermdata.ni);
    dtn = norm(Tn-thermdata.Tn,inf);
    if (dtn>0) 
      tndampfact_n = log(1+tndampcoef*dtn)/(tndampcoef*dtn);
      Tn           = tndampfact_n * Tn + (1-tndampfact_n) * thermdata.Tn;
    endif
    
    if (verbose>=1)
      fprintf(1,"\t***updating hole temperature\n");
    endif

    Tp  = ThDDGOXupdatehole_temp(Simesh,SiDnodes,thermdata.Tp,...
   				 thermdata.n,thermdata.p,...
    				 thermdata.Tl,Jp,E,mobp0,...
                                 twp0,twp1,thermdata.tn,thermdata.tp,...
    				 thermdata.ni,thermdata.ni);

    dtp = norm(Tp-thermdata.Tp,inf);
    if (dtp>0) 
      tpdampfact_p = log(1+tpdampcoef*dtp)/(tpdampcoef*dtp);
      Tp           = tpdampfact_p * Tp + (1-tpdampfact_p) * thermdata.Tp;
    endif
    
    if (verbose>=1)
      fprintf(1,"\t***updating lattice temperature\n");
    endif
    
    ## Store result for RRE
    if RREpattern(ith)>0
      TEMPstore(:,RREpattern(ith)) = [Tn;Tp;Tl];
      if RREpattern(ith+1)==0 
	## Apply RRE extrapolation
	if (verbose>=1)		
	  fprintf(1,"\n\t**********\n\tRRE EXTRAPOLATION STEP\n\t**********\n\n");
	endif
	TEMP = Urrextrapolation(TEMPstore);
	Tn   = TEMP(1:rows(Tn));
	Tp   = TEMP(rows(Tn)+1:rows(Tn)+rows(Tp));
        Tl   = TEMP(rows(Tn)+rows(Tp)+1:end);
      endif
    endif

    Tl  = ThDDGOXupdatelattice_temp(Simesh,SiDnodes,thermdata.Tl,...
				    Tn,Tp,thermdata.n,...
				    thermdata.p,thermdata.kappa,thermdata.Egap,...
				    thermdata.tn,thermdata.tp,twn0,...
				    twp0,twn1,twp1,...
				    thermdata.ni,thermdata.ni);
    
    dtl = norm(Tl-thermdata.Tl,inf);
    if (dtl > 0)
      tldampfact = log(1+tldampcoef*dtl)/(tldampcoef*dtl);
      Tl         = tldampfact * Tl + (1-tldampfact) * thermdata.Tl; 
    endif
    
    if (verbose>=1)
      fprintf(1,"\t*** checking for convergence:\n ");
    endif
    
    nrm(ith) = max([dtl,dtn,dtp]);	
    
    if (verbose>=1)
      fprintf (1,"\t\t|dTL|= %g\n",dtl);
      fprintf (1,"\t\t|dTn|= %g\n",dtn);
      fprintf (1,"\t\t|dTp|= %g\n",dtp);
    endif
    
    thermdata.Tl = Tl;
    thermdata.Tn = Tn;
    thermdata.Tp = Tp;
    if (verbose>1)
      subplot(1,3,2);
      title("max(|dTl|,|dTn|,|dTn|)")
      semilogy(nrm)
      pause(.1)
    endif
    if nrm(ith)< toll
      if (verbose>=1)
	fprintf(1,"\n***\n***\texit from thermal iteration \n");
      endif
      
      break
    endif
    
  endfor

endfunction