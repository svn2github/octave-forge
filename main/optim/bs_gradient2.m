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
##
## Changelog :
## 2002/04/24 Etienne Grossmann <etienne@isr.ist.utl.pt>
##    - Copy bs_gradient.m
##    - Remove everything except 1st derivative calculation
##    - Do modifs to take args, narg as arguments

## [dx, nev] = bs_gradient2 (f, args, narg)
function [dx,nev] = bs_gradient2(f, args, narg)

  nev = 2*prod (sz = size (x0 = x1 = nth (args,narg)));

  h = 0.00000001;
  dx = zeros (1, prod (sz));
  for i = 1:prod(sz)
    tmp = x0(i);
    x0(i) += h; x1(i) -= h;
    dx(i) = \
	leval (f, splice (args, narg, 1, list (x0))) - \
	leval (f, splice (args, narg, 1, list (x1)));
    x0(i) = x1(i) = tmp;
  endfor
  dx ./= 2*h;
endfunction

