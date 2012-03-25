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
## @deftypefn {Function File} {@var{b}} = Ubernoulli(@var{x},@var{sg})
##
## Compute Bernoulli function for vector x:
##
## @itemize @minus
## @item @var{b} = @var{x}/(exp(@var{x})-1) if @var{sg} == 1
## @item @var{b} = @var{x} + B( @var{x} ) if @var{sg} == 0
## @end itemize
##
## @end deftypefn

function b=Ubernoulli(x,sg)
  
  for count=1:length(x)
    [bp,bn] = Ubern(x(count));
    bernp(count,1)=bp;
    bernn(count,1)=bn;
  endfor
  
  if (sg ==1)
    b=bernp;
  elseif (sg ==0)
    b=bernn;
  endif
  
endfunction