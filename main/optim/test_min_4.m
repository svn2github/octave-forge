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

## test_bfgs              - Test that bfgs works
##
## Check that bfgs treats struct options correctly
##
## Sets 'ok' to 1 if success, 0 otherwise

## The name of the optimizing function
if ! exist ("optim_func"), optim_func = "bfgs"; end

ok = 1;
cnt = 0;

if ! exist ("verbose"), verbose = 0; end

N = 2;

x0 = randn(N,1) ;
y0 = randn(N,1) ;

function v = ff(x,y,t)
  A = [1 -1;1 1]; M = A'*diag([100,1])*A;
  v = ((x - y)(1:2))'*M*((x-y)(1:2)) + 1;
endfunction


function dv = dff(x,y,t)
  if nargin < 3, t = 1; end
  if t == 1, N = length (x); else N = length (y); end
  A = [1 -1;1 1]; M = A'*diag([100,1])*A;
  dv = 2*((x-y)(1:2))'*M;
  if N>2, dv = [dv, zeros(1,N-2)]; end
  if t == 2, dv = -dv; end
endfunction


if verbose
  printf ("\n   Testing that %s accepts struct control variable\n\n",\
	  optim_func);

  printf (["     Set 'optim_func' to the name of the optimization\n",\
	   "     function you want to test (must have same synopsis\n",\
	   "     as 'bfgs')\n\n"]);

  printf ("  Nparams = N = %i\n",N);
  fflush (stdout);
end

## Plain run, just to make sure ######################################
## Minimum wrt 'x' is y0
## [xlev,vlev,nlev] = feval (optim_func, "ff", "dff", list (x0,y0,1));
ctl.df = "dff";
[xlev,vlev,nlev] = feval (optim_func, "ff", list (x0,y0,1), ctl);

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    printf ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  printf ("ok %i\n",cnt);
end

## Minimize wrt 2nd arg ##############################################
## Minimum wrt 'y' is x0
ctl = struct ("narg", 2,"df","dff");
## ctl = [nan,nan,2];
## [xlev,vlev,nlev] = feval (optim_func, "ff", list (x0,y0,2),ctl);
[xlev,vlev,nlev] = feval (optim_func, "ff", list (x0,y0,2),ctl);

cnt++;
if max (abs (xlev-x0)) > 100*sqrt (eps)
  if verbose
    printf ("Error is too big : %8.3g\n", max (abs (xlev-x0)));
  end
  ok = 0;
elseif verbose,  printf ("ok %i\n",cnt);
end

## Set the verbose option ############################################
## Minimum wrt 'x' is y0
ctl = struct ("narg", 1,"verbose",verbose, "df", "dff");
## ctl = [nan,nan,2];
## [xlev,vlev,nlev] = feval (optim_func, "ff", "dff", list (x0,y0,1),ctl);
[xlev,vlev,nlev] = feval (optim_func, "ff", list (x0,y0,1),ctl);

cnt++;
if max (abs (xlev-y0)) > 100*sqrt (eps)
  if verbose
    printf ("Error is too big : %8.3g\n", max (abs (xlev-y0)));
  end
  ok = 0;
elseif verbose,  printf ("ok %i\n",cnt);
end




if verbose && ok
  printf ( "All tests ok\n");
end

