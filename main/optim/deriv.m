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

## deriv(f,x0[,h,O,N])

## Reference -> Numerical Methods for Mathematics, Science, and
## Engineering by John H. Mathews.

function dx = deriv(f,x0,varargin)

  if(nargin < 2)
    error("not enough arguments\n");
  endif
  if(!isstr(f))
    error("The first argument must be a string\n");
  endif
  if(!is_scalar(x0))
    error("The second argument must be a scalar.\n");
  endif
  if(nargin >= 3)
    va_arg_cnt = 1;
    h = nth (varargin, va_arg_cnt++);
    if(!is_scalar(h))
      error("h must be a scalar.");
    endif
    if(nargin >= 4)
      O = nth (varargin, va_arg_cnt++);
      if((O != 2) && (O != 4))
	error("Only order 2 or 4 is supported.\n");
      endif
      if(nargin >= 5)
	N = nth (varargin, va_arg_cnt++);
	if((N > 4)||(N < 1))
	  error("Only 1st,2nd,3rd or 4th order derivatives are acceptable.\n");
	endif
	if(nargin >= 6)
	  warning("Ignoring arguements beyond the 5th.\n");
	endif
      endif
    endif
  else
    h = 0.0000001;
    O = 2;
  endif

  switch O
    case (2)
      switch N
	case (1)
	  dx = (feval(f,x0+h)-feval(f,x0-h))/(2*h);
	case (2)
	  dx = (feval(f,x0+h)-2*feval(f,x0)+feval(f,x0-h))/(h^2);
	case (3)
	  dx = (feval(f,x0+2*h)-2*feval(f,x0+h)+2*feval(f,x0-h)-feval(f,x0-2*h))/(2*h^3);
	case (4)
	  dx = (feval(f,x0+2*h)-4*feval(f,x0+h)+6*feval(f,x0)-4*feval(f,x0-h)+feval(f,x0-2*h))/(h^4);
	otherwise
	  error("I can only take the 1st,2nd,3rd or 4th derivative\n");
      endswitch
    case (4)
      switch N
	case (1)
	  dx = (-feval(f,x0+2*h)+8*feval(f,x0+h)-8*feval(f,x0-h)+feval(f,x0-2*h))/(12*h);
	case (2)
	  dx = (-feval(f,x0+2*h)+16*feval(f,x0+h)-30*feval(f,x0)+16*feval(f,x0-h)-feval(f,x0-2*h))/(12*h^2);
	case (3)
	  dx = (-feval(f,x0+3*h)+8*feval(f,x0+2*h)-13*feval(f,x0+h)+13*feval(f,x0-h)-8*feval(f,x0-2*h)+feval(f,x0-3*h))/(8*h^3);
	case (4)
	  dx = (-feval(f,x0+3*h)+12*feval(f,x0+2*h)-39*feval(f,x0+h)+56*feval(f,x0)-39*feval(f,x0-h)+12*feval(f,x0-2*h)-feval(f,x0-3*h))/(6*h^4);
	otherwise
	  error("I can only take the 1st,2nd,3rd or 4th derivative\n");
      endswitch  
    otherwise
      error("Only order 4 or 2 supported\n");
  endswitch
endfunction
