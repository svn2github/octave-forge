## Copyright (C) 2000 Ben Sapp.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{xmin} =} dfp(@var{f},@var{x0})
## Use the Davidon-Flecther-Powell method to find the minimum of a
## multivariable function @var{f}
## @end deftypefn 

function x = dfp(func,x)
  global __quasi_d__;
  global __quasi_x0__;
  global __quasi_f__;
  __quasi_f__  = func;

  H = eye(max(size(x)));
  g = bs_gradient(func,x);
  while(norm(g) > 0.000001)
    d = -H*g;
    __quasi_d__ = d;
    __quasi_x0__ = x;
    min = nrm('__quasi_func__',0);
    p = min*d;
    x = x+p;
    g_new = bs_gradient(func,x);
    q = g_new-g;
    g = g_new;
    H = H+(p*p')/(p'*q)-(H*q*q'*H)/(q'*H*q);
  endwhile
endfunction
