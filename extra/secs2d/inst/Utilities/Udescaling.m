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
## {@var{odata},@var{omesh}} = Udescaling(@var{imesh},@var{idata})
##
## Descale @var{idata} and return the output in @var{odata}
##
## @end deftypefn

function [odata,omesh] = Udescaling(imesh,idata);

  load (file_in_path(path,"constants.mat"));

  omesh = imesh;
  odata = idata;

  ## Scaled quantities
  odata.D     = idata.D*odata.ns;
  odata.n     = idata.n*odata.ns;
  odata.p     = idata.p*odata.ns;
  odata.Fn    = (idata.Fn+log(ni/odata.ns))*odata.Vs;
  odata.Fp    = (idata.Fp-log(ni/odata.ns))*odata.Vs;
  odata.V     = idata.V*odata.Vs;

  if (isfield(idata,"G"))
    odata.G = idata.G*odata.Vs;
  endif
  if (isfield(idata,"dt"))
    odata.dt = idata.dt*odata.ts;
  endif

  if (isfield(idata,"un"))    
    odata.un    = idata.un*odata.us;  
  else
    odata.un    = un;
  endif

  if (isfield(idata,"n0"))    
    odata.n0    = idata.n0*odata.ns;  
    odata.p0    = idata.p0*odata.ns;  
  else
    odata.p0    = ni;
    odata.n0    = ni;
  endif

  if (isfield(idata,"up"))
    odata.up    = idata.up*odata.us;
  else
    odata.up    = up;
  endif
  if (isfield(idata,"FDn"))    
    odata.FDn    = idata.FDn*odata.Vs;  
  endif
  if (isfield(idata,"FDp"))    
    odata.FDp    = idata.FDp*odata.Vs;  
  endif

  if (isfield(idata,"Tl"))    
    odata.Tl    = idata.Tl*odata.Ts;  
  endif

  if (isfield(idata,"Tn"))    
    odata.Tn    = idata.Tn*odata.Ts;  
  endif

  if (isfield(idata,"Tp"))    
    odata.Tp    = idata.Tp*odata.Ts;  
  endif

  omesh.p     = imesh.p*odata.xs;
endfunction