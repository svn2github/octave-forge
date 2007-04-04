function phip = DDGp2phip (V,p);

% phip = DDGp2phip (V,p);
% computes the qfl for holes using Maxwell-Boltzmann statistics
 
% This file is part of 
%
%            MNME1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
%         -------------------------------------------------------------------
%            Copyright (C) 2004  Carlo de Falco
%
%
%
%  MNME1D is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or
%  (at your option) any later version.
%
%  MNME1D is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with MNME1D; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
  
% load constants

  pmin = 0;
    
  p    = p .* (p>pmin) + pmin * (p<=pmin);
  phip = V + log(p) ;
  

  % Last Revision:
  % $Author$
  % $Date$
