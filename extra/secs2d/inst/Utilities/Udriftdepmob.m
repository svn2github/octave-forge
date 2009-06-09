## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
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
## {@var{mob}} = Udriftdepmob(@var{imesh},@var{u0},@var{F},@var{V},@var{vsat},@var{b})
##
## Compute drift dependent mobility
##
## @itemize @minus
## @item @var{imesh}: input mesh structure
## @item @var{u0}: reference mobility value
## @item @var{F}: 
## @item @var{V}: electric potential
## @item @var{vsat}: saturation velocity
## @item @var{b}: correction coefficient
## @end itemize
##
## @end deftypefn

function mob = Udriftdepmob(imesh,u0,F,V,vsat,b)

  [Ex,Ey]= Updegrad(imesh,-V);
  [Fx,Fy]= Updegrad(imesh,F);
  fnmod  = sqrt(Fx.^2+Fy.^2);
  ef     = abs(Fx.*Ex+Fy.*Ey)./fnmod;
  
  if Ucolumns(ef)>Urows(ef)
    ef = ef';
  endif
  
  mob = u0 ./ (1+(u0 .* ef ./ vsat).^b).^(1/b);

endfunction