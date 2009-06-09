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
## @deftypefn {Function File} {@var{bp},@var{bn}} = Ubern(@var{x})
##
## Compute Bernoulli function for vector x:
##
## @itemize @minus
## @item @var{bp} = @var{x}/(exp(@var{x})-1)
## @item @var{bn} = @var{x} + B( @var{x} )
## @end itemize
##
## @end deftypefn


function [bp,bn] = Ubern(x)

  xlim = 1e-2;
  ax   = abs(x);
  bp   = zeros(size(x));
  bn   = bp;

  block1  = find(~ax);
  block21 = find((ax>80)&x>0);
  block22 = find((ax>80)&x<0);
  block3  = find((ax<=80)&(ax>xlim));
  block4  = find((ax<=xlim)&(ax~=0));

  ## Compute Bernoulli function for x = 0
  bp(block1) = 1.;
  bn(block1) = 1.;

  ## Compute Bernoulli function for asymptotic values of x
  bp(block21) = 0.;
  bn(block21) = x(block21);
  bp(block22) = -x(block22);
  bn(block22) = 0.;

  ## Compute Bernoulli function for intermediate values of x
  bp(block3)=x(block3)./(exp(x(block3))-1);
  bn(block3)=x(block3)+bp(block3);

  ## Compute Bernoulli function for small values of x via Taylor expansion
  if(any(block4))jj=1;
    fp    = 1.*ones(size(block4));
    fn    = fp;
    df    = fp;
    segno = 1.;
    while (norm(df,inf) > eps),
      jj    = jj+1;
      segno = -segno;
      df    = df.*x(block4)/jj;
      fp    = fp+df;
      fn    = fn+segno*df;
    endwhile;
    bp(block4) = 1./fp;
    bn(block4) = 1./fn;
  endif

endfunction