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
## Changelog : (changes by etienne@isr.ist.utl.pt, 2002 / 04)
## - Require user-provided diff rather than using bs_gradient
## - Use tmp = p*q'*H
## - Accept list of args, and narg=position of minimized arg. No more global
##   variables or __pseudo_func__
## - Terminate if q'*p (denominator in update formula) is small
## - Add option treatment stuff
## - Allow non-vector optimized argument
## - Add help text from cg_min.

## [x0,v,nev] = bfgs (f,df,args,ctl) - Variable metric minimization
##
## ARGUMENTS --------
## f     : string   : Name of function. Takes a RxC matrix as input and
##                    returns a real value.
## df    : string   : Name of f's derivative. Returns a (R*C) x 1 vector
## args  : list     : Arguments passed to f.
##      or matrix   : f's only argument
## ctl   : 5-vec    : (Optional) Control variables, described below
##      or struct   :
##
## RETURNED VALUES --
## x0    : matrix   : Local minimum of f
## v     : real     : Value of f in x0
## nev   : 1 x 2    : Number of evaluations of f and of df
## 
## CONTROL VARIABLE ctl : (optional). A struct or a vector of length 4 or
## ---------------------- less where NaNs are ignored. Default values are
##                        written <value>.
## FIELD  VECTOR
## NAME    POS
##
## ftol, f N/A    : Stop search when value doesn't improve, as tested by
##
##                   f > Deltaf/max(|f(x)|,1)
##
##             where Deltaf is the decrease in f observed in the last
##             iteration.                                     <10*sqrt(eps)>
##
## utol, u N/A    : Stop search when updates are small, as tested by
##
##                   u > max { dx(i)/max(|x(i)|,1) | i in 1..N }
##
##             where  dx is the change in the x that occured in the last
##             iteration.                                              <NaN>
##
## dtol, d N/A    : Stop search when derivative is small, as tested by
## 
##                   d > norm (dv)                                     <1e7>
##
## crit, c ctl(1) : Set one stopping criterion, 'ftol' (c=1), 'utol' (c=2)
##                  or 'dtol' (c=3) to the value of by the 'tol' option. <1>
##
## tol, t  ctl(2) : Threshold in termination test chosen by 'crit'  <10*eps>
##
## argn, n ctl(3) : Position of the minimized argument in args           <1>
## maxev,m ctl(4) : Maximum number of function evaluations             <inf>
function [x,fmin,nev] = bfgs (func, dfunc, args, ctl)

  crit = 0;			# Default control variables
  ftol  = 10*sqrt (eps);
  utol = tol = nan;
  dtol = 1e-6;
  narg = 1;
  maxev = inf;
  step = nan;

  if nargin >= 4,			# Read arguments
    if isnumeric (ctl)
      if length (ctl)>=1 && !isnan (ctl(1)), crit  = ctl(1); end
      if length (ctl)>=2 && !isnan (ctl(2)), tol   = ctl(2); end
      if length (ctl)>=3 && !isnan (ctl(3)), narg  = ctl(3); end
      if length (ctl)>=4 && !isnan (ctl(4)), maxev = ctl(4); end
      if length (ctl)>=5 && !isnan (ctl(5)), step  = ctl(5); end
    elseif is_struct (ctl)
      if struct_contains (ctl, "crit")   , crit    = ctl.crit   ; end
      if struct_contains (ctl, "tol")    , tol     = ctl.tol    ; end
      if struct_contains (ctl, "narg")   , narg    = ctl.narg   ; end
      if struct_contains (ctl, "maxev")  , maxev   = ctl.maxev  ; end
      if struct_contains (ctl, "isz")    , step    = ctl.isz    ; end
    else 
      error ("The 'ctl' argument should be either a vector or a struct");
    end
  end
  
  if     crit == 1, ftol = tol;
  elseif crit == 2, utol = tol;
  elseif crit == 3, dtol = tol;
  elseif crit, error ("crit is %i. Should be 1,2 or 3.\n");
  end


  if is_list (args),		# List of arguments 
    x = nth (args, narg);
  else				# Single argument
    x = args; args = list (args); 
  end
  sz = size (x);

  H = eye (prod (sz = size (x)));
  g = leval (dfunc, args)';
  nev = [0,1];

  if norm(g) <= dtol, nev(1)=1; fmin = leval (func, args); break; end

  flast = inf;

  while 1			# Termination is tested when needed inside
				# the loop
    d = -H*g;
    [min,fmin,nev2] = line_min (func, reshape (d,sz), args, narg);
    nev(1) += nev2;
    p = min*d;
    x += reshape (p,sz);

    if ! isnan (ftol) && (abs (fmin - flast)/max(1,abs (flast))) < ftol || \
	  ! isnan (utol) && (norm (p) / max (1,norm (x(:)))) < utol || \
	  nev(1) > maxev;
      break;
    end

    flast = fmin;

    args = splice (args, narg, 1, list (x));
    g_new = leval (dfunc, args)';
    nev(2)++;

    q = g_new-g;
    g = g_new;

    if (norm(g) <= dtol) || abs (q'*p) < 1e-7, break; end

    H += (1+(q'*H*q)/(q'*p))*((p*p')/(q'*p))-((p*q'*H+H*q*p')/(q'*p));
  endwhile
endfunction
