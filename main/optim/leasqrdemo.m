## Copyright (C) 1992-1994 Richard Shrager, Arthur Jutan and Ray Muzic
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## leasqrdemo
##
## An example showing how to use non-linear least squares to fit 
## simulated data to the function:
##
##      y = a e^{-bx}

## 2001-02-05 Paul Kienzle
##   * collected example into a single script

1; # Force this to be a script

function y = leasqrfunc(x,p)
  ##sprintf('called leasqrfunc(x,[%e %e]\n', p(1),p(2))
  ## y = p(1)+p(2)*x;
  y=p(1)*exp(-p(2)*x);
endfunction

function y = leasqrdfdp(x,f,p,dp,func)
  ## y = [0*x+1, x];
  y= [exp(-p(2)*x), -p(1)*x.*exp(-p(2)*x)];
endfunction

## generate test data
t = [1:100]';
p = [1; 0.1];
data = leasqrfunc (t, p);

## add noise
## wt1 = 1 /sqrt of variances of data
## 1 / wt1 = sqrt of var = standard deviation
wt1 = (1 + 0 * t) ./ sqrt (data); 
data = data + 0.05 * randn (100, 1) ./ wt1; 

## Note by Thomas Walter <walter@pctc.chemie.uni-erlangen.de>:
##
## Using a step size of 1 to calculate the derivative is WRONG !!!!
## See numerical mathbooks why.
## A derivative calculated from central differences need: s 
##     step = 0.001...1.0e-8
## And onesided derivative needs:
##     step = 1.0e-5...1.0e-8 and may be still wrong

F = "leasqrfunc";
dFdp = "leasqrdfdp"; # exact derivative
% dFdp = "dfdp";     # estimated derivative
dp = [0.001; 0.001];
pin = [.8; .05]; 
stol=0.001; niter=50;
minstep = [0.01; 0.01];
maxstep = [0.8; 0.8];
options = [minstep, maxstep];

global verbose;
verbose=1;
[f1, p1, kvg1, iter1, corp1, covp1, covr1, stdresid1, Z1, r21] = ...
    leasqr (t, data, pin, F, stol, niter, wt1, dp, dFdp, options);
