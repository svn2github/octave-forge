## Copyright (C) 2000 Ben Sapp <bsapp@nua.lampf.lanl.gov>
## Copyright (C) 2011 Joaquín Ignacio Aramendía <samsagax@gmail.com>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 3, or (at your option) any
## later version.
##
## This is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.

## -*- texinfo -*-
## @deftypefn {Function File} {dx =} deriv (@var{f}, @var{x0})
## @deftypefnx {Function File} {dx =} deriv (@var{f}, @var{x0}, @var{h})
## @deftypefnx {Function File} {dx =} deriv (@var{f}, @var{x0}, @var{h}, @var{O})
## @deftypefnx {Function File} {dx =} deriv (@var{f}, @var{x0}, @var{h}, @var{O}, @var{N})
## Calculate derivate of function @var{f}.
##
## @var{f} must be a function handle and @var{x0} a scalar.The optional arguments
## @var{h}, @var{O} and @var{N} default to 1e-7, 2, and 1 respectively.
##
## Reference: Numerical Methods for Mathematics, Science, and Engineering by
## John H. Mathews.
## @end deftypefn

function dx = deriv (f, x0, h = 0.0000001, O = 2, N = 1)

  if (nargin < 2)
    error ("Not enough arguments.");
  elseif (!isa (f, 'function_handle'))
    error ("The first argument 'f' must be a function handle.");
  elseif (!isscalar (x0) || !isnumeric (x0))
    error ("The second argument 'x0' must be a scalar.");
  elseif (!isscalar (h) || !isnumeric (h))
    error ("The third argument 'h' must be a scalar.");
  elseif (!isscalar (O) || !isnumeric (O))
    error ("The fourth argument 'O' must be a scalar.");
  elseif (O != 2 && O != 4)
    error ("Only order 2 or 4 is supported.");
  elseif (!isscalar (N) || !isnumeric (N))
    error ("The fifth argument 'N' must be a scalar.");
  elseif ((N > 4) || (N < 1))
    error("Only 1st,2nd,3rd or 4th order derivatives are acceptable.");
  elseif (nargin > 5)
    warning("Ignoring arguements beyond the 5th.");
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
          error("Only 1st,2nd,3rd or 4th order derivatives are acceptable.");
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
          error("Only 1st,2nd,3rd or 4th order derivatives are acceptable.");
      endswitch
    otherwise
      error ("Only order 2 or 4 is supported.");
  endswitch
endfunction
