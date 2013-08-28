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
## @deftypefn {Function File} {@var{odata},@var{ith},@var{res}} =@
## ThDDGOXgummelmap(@var{imesh},@var{Dsides},@var{Simesh},@var{Sinodes},@var{Sielements},@var{SiDsides},@
##                  @var{idata},@var{tol},@var{maxit},@var{ptol},@var{pmaxit},@var{thtol},@var{thmaxit},@
##                  @var{eltol},@var{elmaxit},@var{verbose})
##
## Solve the scaled stationary bipolar DD equation system using Gummel
## algorithm
##
## @end deftypefn

function [odata,ith,res] = ThDDGOXgummelmap (imesh,Dsides,Simesh,Sinodes,Sielements,SiDsides,idata,tol,maxit,ptol,pmaxit,thtol,thmaxit,eltol,elmaxit,verbose)
  
  clear  DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
  global DDGOXNLPOISSON_LAP DDGOXNLPOISSON_MASS DDGOXNLPOISSON_RHS DDG_RHS DDG_MASS
  
  eletdata  = idata;
  thermdata = idata;
  nrm       = 1;
  eletnrm   = [];
  thermnrm  = [];

  for ith = 1:maxit
    
    eletdata.Tl  = thermdata.Tl;
    eletdata.Tn  = thermdata.Tn;
    eletdata.Tp  = thermdata.Tp;
    
    if (verbose>=1)
      fprintf(1,"\n***\n***\tupdating potentials\n***\n");
    endif
    
    [eletdata,innrm1]=ThDDGOXeletiteration(imesh,Dsides,...
					   Simesh,Sinodes,Sielements,SiDsides,...
					   eletdata,eltol,elmaxit,ptol,pmaxit,verbose);
    eletnrm      = [eletnrm,innrm1];
    thermdata.n  = eletdata.n;
    thermdata.p  = eletdata.p;
    thermdata.V  = eletdata.V;

    if (verbose>=1)
      fprintf(1,"\n***\n***\tupdating temperatures\n***\n");
    endif
    
    [thermdata,innrm] = ThDDGOXthermaliteration(imesh,Dsides,...
						Simesh,Sinodes,Sielements,SiDsides,...
						thermdata,thtol,thmaxit,2);


    thermnrm = [eletnrm,innrm];
    nrm(ith) = max([innrm,innrm1]);
    if (verbose>=1)
      subplot(1,3,1);
      semilogy(nrm)
      pause(.1)
    endif
    if (nrm(ith)<tol)
      if (verbose>0)
	fprintf(1,"\n***\n***\tThDD simulation over: # of Global iterations = %d\n***\n",ith);
      endif
      break
    endif
  endfor
  
  res   = {nrm,eletnrm,thermnrm};  
  odata = thermdata;
  
endfunction