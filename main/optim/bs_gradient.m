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

## bs_gradient(f, x0, [h, O]) 
##

function dx = bs_gradient(f, x0, ...)

  if(nargin < 2)
    error("not enough arguements\n");
  endif
  if(!isstr(f))
    error("The first arguement must be a string\n");
  endif
  if(!is_vector(x0))
    error("The second arguement must be a vector.\n");
  endif
  if(nargin >= 3)
    va_start();
    h = va_arg();
    if(!is_scalar(h))
      if(is_vector(h))
	if(size(x0) != size(h))
	  error("If h is not a scalar it must be the same size as x0.\n");
	endif
      endif
    else
      h = size(x0)*h;
    endif
    if(nargin >= 4)
      O = va_arg()
      if((O != 2) && (O != 4))
	error("Only order 2 or 4 is supported.\n");
      endif
      if(nargin >= 5)
	warning("ignoring arguements beyond the 4th.\n");
      endif
    endif
  else
    h = size(x0)*0.0000001;
    O = 2;
  endif

  
  dx = zeros(size(x0));
  if(O == 2)
    for i = 1:max(size(x0))
      del = zeros(size(x0));
      del(i) = h(i);
      dx(i) = (feval(f,x0+del)-feval(f,x0-del))./(2*h(i));
    endfor
  elseif(O ==4)
    for i = 1:max(size(x0))
      del = zeros(size(x0));
      del(i) = h(i);
      dx(i) = (-feval(f,x0+2*del)+8*feval(f,x0+del)-8*feval(f,x0-del)+feval(f,x0-2*del))./(12*h(i));
    endfor	  
  endif
endfunction

