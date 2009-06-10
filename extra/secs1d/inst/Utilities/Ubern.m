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
## @deftypefn {Function File} {@var{bp},@var{bn}} = Ubern(@var{x})
##
## Compute Bernoulli function for scalar x:
##
## @itemize @minus
## @item @var{bp} = @var{x}/(exp(@var{x})-1)
## @item @var{bn} = @var{x} + B( @var{x} )
## @end itemize
##
## @end deftypefn

function [bp,bn] = Ubern(x)
     
xlim=1e-2;
ax=abs(x);

  ## Compute Bernoulli function for x = 0

if (ax == 0)
   bp=1.;
   bn=1.;
   return
  endif

  ## Compute Bernoulli function for asymptotic values

  if (ax > 80)
    if (x > 0)
      bp=0.;
      bn=x;
      return
   else
      bp=-x;
      bn=0.;
      return
    endif
  endif

  ## Compute Bernoulli function for intermediate values

  if (ax > xlim)
   bp=x/(exp(x)-1);
   bn=x+bp;
   return
else
    ## Compute Bernoulli function for small x
    ## via Taylor expansion

   ii=1;
   fp=1.;
   fn=1.;
   df=1.;
   segno=1.;
   while (abs(df) > eps),
     ii=ii+1;
     segno=-segno;
     df=df*x/ii;
     fp=fp+df;
     fn=fn+segno*df;
     bp=1./fp;
     bn=1./fn;
    endwhile
   return
  endif

endfunction