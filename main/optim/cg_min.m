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

## [x0,v,nev] = cg_min (f,df,args,ctl) - Conjugate gradient minimization
##
## ARGUMENTS
## f     : string   : Name of function. Takes a RxC matrix as input and
##                    returns a real value.
## df    : string   : Name of f's derivative. Returns a (R*C) x 1 vector
## args  : list     : Arguments passed to f.
##      or matrix   : f's only argument
## ctl   : 4-vec    : (Optional) Control variables, described below
##
## RETURNED VALUES
## x0    : matrix   : Local minimum of f
## v     : real     : Value of f in x0
## nev   : 1 x 2    : Number of evaluations of f and of df
## 
## CONTROL VARIABLES 
## ctl(1)       : 1 or 2 : Select stopping criterion amongst :
## ctl(1)==1    : Stopping criterion : Stop search when value doesn't
##                improve, as tested by 
##
##              ctl(2) > Deltaf/max(|f(x)|,1)
##
##                where Deltaf is the decrease in f observed in the last
##                iteration (each iteration consists R*C line searches). 
## ctl(1)==2    : Stopping criterion : Stop search when updates are small,
##                as tested by 
##
##              ctl(2) > max { dx(i)/max(|x(i)|,1) | i in 1..N }
##
##                where  dx is the change in the x that occured in the last
##                iteration.
##                                                            Default=1
##
## ctl(2)       : Threshold used in stopping tests.           Default=10*eps
## ctl(3)       : Position of the minimized argument in args  Default=1
## ctl(4)       : Maximum number of function evaluations      Default=inf
##
## ctl may have length smaller than 4. Default values will be used if ctl is
## not passed or if nan values are given.
##
function [x,v,nev] = cg_min (f, dfn, args, ctl)

## Author : Etienne Grossmann <etienne@isr.ist.utl.pt>
## This software is distributed under the terms of the GPL

verbose = 0;

crit = 1;			# Default control variables
tol = 10*eps;
narg = 1;
maxev = inf;

if nargin >= 4,			# Read arguments
  if                    !isnan (ctl(1)), crit = ctl(1); end
  if length (ctl)>=2 && !isnan (ctl(2)), tol = ctl(2); end
  if length (ctl)>=3 && !isnan (ctl(3)), narg = ctl(3); end
  if length (ctl)>=4 && !isnan (ctl(4)), maxev = ctl(4); end
end

if is_list (args),		# List of arguments 
  x = nth (args, narg);
else				# Single argument
  x = args;
  args = list (args); 
end

if narg > length (args),	# Check
  error ("cg_min : narg==%i, length (args)==%i\n",
	 narg, length (args));
end

[R, C] = size(x);
N = R*C;
x = reshape (x,N,1) ;

nev = [0, 0];

v = leval (f, args);
nev(1)++;

xi = h = df = -leval (dfn, args)(:)' ;
nev(2)++;

done = 0;

## TEMP
## tb = ts = zeros (1,100);

				# Control params for line search
ctlb = [10*sqrt(eps), narg, maxev];
if crit == 2, ctlb(1) = tol; end

x0 = x;
v0 = v;

nline = 0;

while nev(1) <= maxev ,
  ## xprev = x ;

  ctlb(3) = maxev - nev(1);	# Update # of evals
  [w, vnew, nev0] = brent_line_min (f, reshape (xi,R,C), args, ctlb);
  nev(1) += nev0;

  x = x + w*xi' ;

  if nline >= N,
    if crit == 1,
      done = tol > (v0 - vnew) / max (1, abs (v0));
    else
      done = tol > norm ((x-x0)(:));
    end
    nline = 1;
    x0 = x;
    v0 = vnew;
  else
    nline++;
  end
  if done || nev(1) >= maxev,  x = reshape (x, R,C); return  end
  
  if vnew > v + eps ,
    printf("cg_min: step increased cost function\n");
    keyboard
  end
  
  ## if abs(1-(x-xprev)'*xi'/norm(xi)/norm(x-xprev))>1000*eps,
  ##  printf("cg_min: step is not in the right direction\n");
  ##  keyboard
  ## end
  args = splice (args, narg, 1, list (reshape (x, R, C)));
  v = leval (f, args);
  nev(1)++;

  if verbose, printf("cg_min : nev=%4i, v=%8.3g\n",nev(1),v) ; end

  xi = leval (dfn, args)(:)';
  nev(2)++;

  gg = df*df' ;
  if gg == 0,
    x = reshape (x, R,C);
    return
  end
  dgg = (df+xi)*xi' ;
  gam = dgg/gg ;
  df = -xi ;
  xi = h = df+gam*h ;
end
x = reshape (x, R,C);

if verbose, printf ("cg_min: Too many evaluatiosn!\n"); end
