## Copyright (C) 2002 Etienne Grossmann.  All rights reserved.
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

## test_fminunc_1              - Test that fminunc and optimset work
##
## A quadratic function is fminuncd. Various options are tested. Options
## are passed incomplete (to see if properly completed) and
## case-insensitive.

ok = 1;				# Remains set if all ok. Set to 0 otherwise
cnt = 0;			# Test counter
page_screen_output = 0;
page_output_immediately = 1;
do_fortran_indexing = 1;
warn_fortran_indexing = 0;

if ! exist ("verbose"), verbose = 0; end

N = 2;

x0 = randn(N,1) ;
y0 = randn(N,1) ;

## Return value
function v = ff(x,y,t)
  A = [1 -1;1 1]; M = A'*diag([100,1])*A;
  v = ((x - y)(1:2))'*M*((x-y)(1:2)) + 1;
endfunction


## Return value, diff and 2nd diff
function [v,dv,d2v] = d2ff(x,y,t)
  if nargin < 3, t = 1; end
  if t == 1, N = length (x); else N = length (y); end
  A = [1 -1;1 1]; M = A'*diag([100,1])*A;
  v = ((x - y)(1:2))'*M*((x-y)(1:2)) + 1;
  dv = 2*((x-y)(1:2))'*M;
  d2v = zeros (N); d2v(1:2,1:2) = 2*M;
  if N>2, dv = [dv, zeros(1,N-2)]; end
  if t == 2, dv = -dv; end
endfunction


## PRint Now
function prn (varargin), printf (varargin{:}); fflush (stdout); end


if verbose
  prn ("\n   Testing that fminunc() works as it should\n\n");
  prn ("  Nparams = N = %i\n",N);
  fflush (stdout);
end

## Plain run, just to make sure ######################################
## Minimum wrt 'x' is y0
opt = optimset ();
[xlev,vlev] = fminunc ("ff",x0,opt,y0,1);

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end

## See what 'backend' gives in that last case ########################
opt = optimset ("backend","on");
[method,ctl] = fminunc ("ff",x0, opt, y0,1);

cnt++;
if ! isstr (method) || ! strcmp (method,"nelder_mead_min")
  if verbose
    if isstr (method)
      prn ("Wrong method '%s' != 'nelder_mead_min' was chosen\n", method);
    else
      prn ("fminunc pretends to use a method that isn't a string\n");
    end
    return
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end

[xle2,vle2,nle2] = feval (method, "ff",list (x0,y0,1), ctl);
cnt++;
				# nelder_mead_min is not very repeatable
				# because of restarts from random positions
if max (abs (xlev-xle2)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-xle2)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end


## Run, w/ differential returned by function ('jac' option) ##########
## Minimum wrt 'x' is y0

opt = optimset ("GradO","on");
[xlev,vlev,nlev] = fminunc ("d2ff",x0,opt,y0,1);

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end


## Use the 'hess' option, when f can return 2nd differential #########
## Minimum wrt 'x' is y0
opt = optimset ("hessian","on");
[xlev,vlev,nlev] = fminunc ("d2ff",x0,opt,y0,1);

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end


if verbose && ok
  prn ( "All tests ok\n");
end

