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
## @deftypefn {Function File} {@var{xmin} =} nrm(@var{f},@var{x0})
## Using @var{x0} as a starting point find a minimum of the scalar
## function @var{f}.  The Newton-Raphson method is used.  
## @end deftypefn

## Author: Ben Sapp <bsapp@lanl.gov>
## Reference: David G Luenberger's Linear and Nonlinear Programming

function x = nrm(func,x)
  velocity = 1;
  acceleration = 1;
  
  i = 0;
  while(abs(velocity) > 0.0001)
    velocity = deriv(func,x,0.01,2,1);
    acceleration = deriv(func,x,0.01,2,2);
    if(velocity > 0)
      x = x-abs(velocity/acceleration);
    else
      x = x+abs(velocity/acceleration);
    endif
  endwhile
endfunction
