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

## ok = test_minimize           - Test that minimize works
##

ok = 1;
cnt = 0;

if ! exist ("verbose"), verbose = 0; end

N = 2;

x0 = randn(N,1) ;
y0 = randn(N,1) ;

## Return value
function v = ff(x,y,t)
  A = [1 -1;1 1]; M = A'*diag([100,1])*A;
  v = ((x - y)(1:2))'*M*((x-y)(1:2)) + 1;
endfunction

## Return differential
function dv = dff(x,y,t)
  if nargin < 3, t = 1; end
  if t == 1, N = length (x); else N = length (y); end
  A = [1 -1;1 1]; M = A'*diag([100,1])*A;
  dv = 2*((x-y)(1:2))'*M;
  if N>2, dv = [dv, zeros (1,N-2)]; end
  if t == 2, dv = -dv; end
endfunction

## Return value, diff and 2nd diff
function [v,dv,d2v] = d2ff(x,y,t)
  if nargin < 3, t = 1; end
  if t == 1, N = length (x); else N = length (y); end
  A = [1 -1;1 1]; M = A'*diag([100,1])*A;
  v = ((x - y)(1:2))'*M*((x-y)(1:2)) + 1;
  dv = 2*((x-y)(1:2))'*M;
  d2v = zeros (N); d2v(1:2,1:2) = 2*M;
  if N>2, dv = [dv, zeros (1,N-2)]; end
  if t == 2, dv = -dv; end
endfunction

## Return value, diff and inv of 2nd diff
function [v,dv,d2v] = d2iff(x,y,t)
  if nargin < 3, t = 1; end
  if t == 1, N = length (x); else N = length (y); end
  A = [1 -1;1 1]; M = A'*diag([100,1])*A;
  v = ((x - y)(1:2))'*M*((x-y)(1:2)) + 1;
  dv = 2*((x-y)(1:2))'*M;
  d2v = zeros (N); d2v(1:2,1:2) = inv (2*M);
  if N>2, dv = [dv, zeros (1,N-2)]; end
  if t == 2, dv = -dv; end
endfunction

## PRint Now
function prn (...), printf (all_va_args); fflush (stdout); end


if verbose
  prn ("\n   Testing that minimize() works as it should\n\n");
  prn ("  Nparams = N = %i\n",N);
  fflush (stdout);
end

## Plain run, just to make sure ######################################
## Minimum wrt 'x' is y0
[xlev,vlev,nlev] = minimize ("ff",list (x0,y0,1));

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end

## See what 'backend' gives in that last case ########################
[method,ctl] = minimize ("ff",list (x0,y0,1),"order",0,"backend");

cnt++;
if ! strcmp (method,"nelder_mead_min")
  if verbose
    prn ("Wrong method '%s' != 'nelder_mead_min' was chosen\n", method);
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


## Run, w/ differential, just to make sure ###########################
## Minimum wrt 'x' is y0
[xlev,vlev,nlev] = minimize ("ff",list (x0,y0,1),"df","dff");

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end

## Run, w/ 2nd differential, just to make sure #######################
## Minimum wrt 'x' is y0
[xlev,vlev,nlev] = minimize ("ff",list (x0,y0,1),"d2f","d2ff");

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end

## Run, w/ inverse of 2nd differential, just to make sure ############
## Minimum wrt 'x' is y0
[xlev,vlev,nlev] = minimize ("ff",list (x0,y0,1),"d2f","d2ff");

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end

## Run, w/ numerical differential ####################################
## Minimum wrt 'x' is y0
[xlev,vlev,nlev] = minimize ("ff",list (x0,y0,1),"order",1);

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end

## See what 'backend' gives in that last case ########################
[method,ctl] = minimize ("ff",list (x0,y0,1),"order",1,"backend");

cnt++;
if ! strcmp (method,"bfgs")
  if verbose
    prn ("Wrong method '%s' != 'bfgs' was chosen\n", method);
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end

[xle2,vle2,nle2] = feval (method, "ff",ctl.df,list (x0,y0,1), ctl);
cnt++;
if max (abs (xlev-xle2)) > 100*eps
  if verbose
    prn ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  prn ("ok %i\n",cnt);
end


if verbose && ok
  prn ( "All tests ok\n");
end

