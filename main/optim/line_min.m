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

## [a,fx,nev] = line_min (f, dx, args, narg) - Minimize f() along dx
##
## INPUT ----------
## f    : string  : Name of minimized function
## dx   : matrix  : Direction along which f() is minimized
## args : list    : List of argument of f
## narg : integer : Position of minimized variable in args.  Default=1
##
## OUTPUT ---------
## a    : scalar  : Value for which f(x+a*dx) is a minimum (*)
## fx   : scalar  : Value of f(x+a*dx) at minimum (*)
## nev  : integer : Number of function evaluations
##
## (*) The notation f(x+a*dx) assumes that args == list (x).

## Author: Ben Sapp <bsapp@lanl.gov>
## Reference: David G Luenberger's Linear and Nonlinear Programming
##
## Changelog : -----------
## 2002-01-28 Paul Kienzle
## * save two function evaluations by inlining the derivatives
## * pass through varargin{:} to the function
## 2002-03-13 Paul Kienzle
## * simplify update expression
## 2002-04-17 Etienne Grossmann <etienne@isr.ist.utl.pt>
## * Rename nrm.m to line_min.m (in order not to break dfp, which uses nrm)
## * Use list of args, suppress call to __pseudo_func__
## * Add nargs argument, assume args is a list
## * Change help text
function [a,fx,nev] = line_min (f, dx, args, narg)
  velocity = 1;
  acceleration = 1;

  if nargin < 4, narg = 1; end

  nev = 0;
  h = 0.001;			# Was 0.01 here
  x = nth (args,narg);
  a = 0;
				# was 1e-4
  while (abs (velocity) > 0.000001)
    fx = leval (f,splice (args, narg, 1, list (x+a*dx)));
    fxph = leval (f,splice (args, narg,1,list (x+(a+h)*dx)));
    fxmh = leval (f,splice (args, narg,1,list (x+(a-h)*dx)));

    velocity = (fxph - fxmh)/(2*h);
    acceleration = (fxph - 2*fx + fxmh)/(h^2);
    if abs(acceleration) <= eps, acceleration = 1; end # Don't do div by zero
				# Use abs(accel) to avoid problems due to
				# concave function
    a = a - velocity/abs(acceleration);
    nev += 3;
  endwhile
endfunction

## Rem : Although not clear from the code, the returned a always seems to
## correspond to (nearly) optimal fx.