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

## [x,v,nev,h,args] = d2_min(f,d2f,args,ctl,code) - Newton-like minimization
##
## Minimize f(x) using 1st and 2nd derivatives. Any function w/ second
## derivatives can be minimized, as in Newton. f(x) decreases at each
## iteration, as in Levenberg-Marquardt. This function is inspired from the
## Levenberg-Marquardt algorithm found in the book "Numerical Recipes".
##
## ARGUMENTS :
## f    : string : Cost function's name
##
## d2f  : string : Name of function returning the cost (1x1), its
##                 differential (1xN) and its second differential or it's
##                 pseudo-inverse (NxN) (see ctl(5) below) :
##
##                 [v,dv,d2v] = d2f (x).
##
## args : list   : f and d2f's arguments. By default, minimize the 1st
##     or matrix : argument.
##
## ctl  : vector : Control arguments (see below)
##
## code : string : code will be evaluated after each outer loop that
##                 produced some (any) improvement. Variables visible from
##                 "code" include "x", the best parameter found, "v" the
##                 best value and "args", the list of all arguments. All can
##                 be modified. This option can be used to change the 
##                 parameterization of argument space while optimizing.
##
## CONTROL VARIABLE ctl :
## ctl(1)    : 1 or 2 : Select stopping criterion amongst :
##
## ctl(1)==1 : Stop search when value doesn't improve, as tested by
##
##              ctl(2) > Deltaf/max(|f(x)|,1)
##
##             where Deltaf is the decrease in f observed in the last
##             iteration (each iteration consists R*C line searches).
##
## ctl(1)==2 : Stop search when updates are small, as tested by
##
##              ctl(2) > max { dx(i)/max(|x(i)|,1) | i in 1..N }
##
##             where  dx is the change in the x that occured in the last
##             iteration.
##
## ctl(1)==3 : Stop search when derivative is small, as tested by
##
##              ctl(2) > norm (dv)
##
##                                                            Default=1
##
##    NOTE : For whatever value of ctl(1), if the derivative's norm is
##           smaller than eps, the algorithm exits.
##
## ctl(2)    : Threshold used in stopping tests.          Default=10*eps^1/2
## ctl(3)    : Position of the minimized argument in args Default=1 
## ctl(4)    : Maximum number of function evaluations     Default=inf
## ctl(5)    : 0 if d2f returns the 2nd derivatives, 1 if Default=0
##             it returns its pseudo-inverse.
##
## ctl may have length smaller than 5. Default values will be used if ctl is
## not passed or if nan values are given.
##
function [xbest,vbest,nev,hbest,args] = d2_min (f,d2f,args,ctl,code)

## Author : Etienne Grossmann <etienne@isr.ist.utl.pt>
##

static d2_min_warn = 1;
if d2_min_warn, warning("d2_min interface subject to change."); endif
d2_min_warn = 0;


maxouter = inf;
maxinner = 30 ;
gtol = eps ;

tcoeff = 0.5 ;			# Discount on total weight
ncoeff = 0.5 ;			# Discount on weight of newton
ocoeff = 1.5 ;			# Factor for outwards searching

report = 0 ;			# Never report
verbose = 0 ;			# Be quiet
prudent = 1 ;			# Check coherence of d2f and f?

niter = 0 ;

crit = 1;			# Default control variables
tol = 10*sqrt (eps);
narg = 1;
maxev = inf;
id2f = 0;

if nargin >= 4			# Read arguments
  if length (ctl)>=1 && !isnan (ctl(1)), crit  = ctl(1); end
  if length (ctl)>=2 && !isnan (ctl(2)), tol   = ctl(2); end
  if length (ctl)>=3 && !isnan (ctl(3)), narg  = ctl(3); end
  if length (ctl)>=4 && !isnan (ctl(4)), maxev = ctl(4); end
  if length (ctl)>=5 && !isnan (ctl(5)), id2f  = ctl(5); end
end

if nargin < 5, code = "" ; end

if is_list (args)		# List of arguments 
  x = nth (args, narg);
else				# Single argument
  x = args;
  args = list (args); 
end

############################## Checking ##############################
if narg > length (args)
  error ("d2_min : narg==%i, length (args)==%i\n",
	 narg, length (args));
end

if tol <= 0
  printf ("d2_min : tol=%8.3g <= 0\n",tol) ;
  keyboard
end

if !isstr (d2f) || !isstr (f)
  printf ("d2_min : I need f and d2f to be strings!\n");
  keyboard
end

if crit == 3, gtol = max (tol, gtol); end

sz = size (x); N = prod (sz);

v = leval (f, args);
nev = [1,0];

## keyboard

xbest = x = x(:);
vold = vbest = nan ;		# Values of f
hbest = nan ;			# Inv. Hessian

if verbose
    printf ( "d2_min : Initially, v=%8.3g\n",v);
end

while niter++ <= maxouter

  [v,d,h] = leval (d2f, splice (args, narg, 1, list (reshape (x,sz))));
  nev(2)++;
  if ! id2f, h = pinv (h); end
  d = d(:);

  if prudent
    v2 = leval (f, splice (args, narg, 1, list (reshape (x,sz))));
    nev(1)++;
    if abs(v2-v) > 0.001 * sqrt(eps) * max (abs(v2), 1)
      printf ("d2_min : f and d2f disagree %8.3g\n",abs(v2-v));
      keyboard
    end
  end

  xbest = x ;
  if ! isnan (vbest)		# Check that v ==vbest 
    if abs (vbest - v) > 1000*eps * max (vbest, 1)
      printf ("d2_min : vbest changed at beginning of outer loop\n");
      vbest - v
      keyboard
    end
  end
  vold = vbest = v ;
  hbest = h ;

  if length (code), abest = args; end # Eventually stash all args

  if verbose || report && (rem(niter,max(report,1)) == 1)
    printf ("d2_min : niter=%d, v=%8.3g\n",niter,v );
  end

  if norm (d) < gtol		# Check for small derivative
    if verbose || report 
      printf ("d2_min : exiting 'cause low gradient\n");
    end
    ## keyboard
    break			# Exit outer loop
  end

  dnewton = -h*d ;		# Newton step
  wn = 1 ;			# Weight of Newton step
  wt = 1 ;			# Total weight
  
  ninner = done_inner = 0;	# 0=not found. 1=Ready to quit inner.
  
				# ##########################################
  while ninner++ < maxinner	# Inner loop ###############################

				# Proposed step
    dx = wt*(wn*dnewton - (1-wn)*d) ;
    xnew = x+dx ;

    if verbose
      printf (["Weight : total=%8.3g, newtons's=%8.3g  vbest=%8.3g ",...
	       "Norm:Newton=%8.3g, deriv=%8.3g\n"],...
	      wt,wn,vbest,norm(wt*wn*dnewton),norm(wt*(1-wn)*d));
    end
    if any(isnan(xnew))
      printf ("d2_min : Whoa!! any(isnan(xnew)) (1)\n"); 
      keyboard
    end

    vnew = leval (f, splice (args, narg, 1, list (reshape (xnew,sz))));
    nev(1)++ ;

    if vnew<vbest		# Stash best values
      dbest = dx ; 
      vbest = vnew; 
      xbest = xnew; 

      done_inner = 1 ;		# Will go out at next increase
      if verbose
          printf ( "d2_min : going down\n");
      end
      
    elseif done_inner == 1	# Time to go out
      if verbose
          printf ( "d2_min : quitting %d th inner loop\n",niter);
      end
      break			# out of inner loop
    end
    wt = wt*tcoeff ;		# Reduce norm of proposed step
    wn = wn*ncoeff ;		# And bring it closer to derivative

  end				# End of inner loop ########################
				# ##########################################

  wbest = 0;			# Best coeff for dbest

  if ninner >= maxinner		# There was a problem
    if verbose
        printf ( "d2_min : inner looping forever (vnew=%8.3g)\n",vnew);
    end

				# ##########################################
  else				# Look for improvement along dbest
    wn = ocoeff ;
    xnew = x+wn*dbest;
    if any(isnan(xnew)),
      printf ("d2_min : Whoa!! any(isnan(xnew)) (1)\n"); 
      keyboard
    end
    vnew = leval (f, splice (args, narg, 1, list (reshape (xnew,sz))));
    nev(1)++;

    while vnew < vbest,
      vbest = vnew;		# Stash best values
      wbest = wn;
      xbest = xnew; 
      wn = wn*ocoeff ;
      xnew = x+wn*dbest;
      vnew = leval (f, splice (args, narg, 1, list (reshape (xnew,sz))));
      if verbose
          printf ( "Looking farther : v = %8.3g\n",vnew);
      end
      nev(1)++;
    end
  end				# End of improving along dbest
				# ##########################################

  if verbose || rem(niter,max(report,1)) == 1
    if vold,
      if verbose
	printf ("d2_min : inner : vbest=%8.5g, vbest/vold=%8.5g\n",\
		vbest,vbest/vold);
      end
    else
      if verbose
        printf ( "d2_min : inner : vbest=%8.5g, vold=0\n", vbest);
      end
    end
  end

  if vbest < vold
    ## "improvement found"
    if prudent
      tmpv = leval (f, splice (args, narg, 1, list (reshape (xbest,sz))));
      nev(1)++;

      if abs(tmpv-vbest)>eps
	printf ("d2_min : Whoa! best value is changing\n");
	keyboard
      end
    end
    v = vbest; x = xbest;
    if ! isempty (code)
      if verbose
          printf ("d2_min : Gonna eval(\"%s\"\n",code);
      end

      xstash = xbest;
      astash = abest;
      args = abest;		# Here : added 2001/11/07. Is that right?
      x = xbest;
      eval (code);
      xbest = x; 
      abest = args;
				# Check whether eval (code) changes value
      if prudent
	tmpv = leval (f, splice (args, narg, 1, list (reshape (x,sz))));
	nev(1)++;
	if abs (tmpv-vbest) > max (min (100*eps,0.00001*abs(vbest)), eps) ,
	  printf ("d2_min : Whoa! best value changes after eval (code)\n");
	  keyboard
	end
      end
    end
  end

  if crit == 1 && tol > (vold-vbest)/max(vold,1), 
    if verbose || report ,
      printf ("d2_min : quitting, niter=%-3d v=%8.3g, ",niter,v);
      if vold, printf ("v/vold=%8.3g \n",v/vold);
      else     printf ("vold  =0     \n",v);
      end
    end
    ## keyboard
    break ;    			# out of outer loop

  elseif crit == 2 && tol > max (abs (wbest*dbest))/max(abs (xbest),1),
    if verbose || report ,
      printf ("d2_min : quitting, niter=%-3d v=%8.3g, ",niter,v);
      if vold, printf ("v/vold=%8.3g \n",v/vold);
      else     printf ("vold  =0     \n",v);
      end
    end
    ## keyboard
    break ;			# out of outer loop
  end   
end				# End of outer loop ##################

xbest = reshape (xbest, sz);
args0 = args;
if length (code), 
  args = abest;
  args(narg) = xbest; 
end

if niter >= maxouter ,
  if verbose
      printf ( "d2_min : outer looping forever\n");
  end
end

				# HERE This should be if prudent, ...
err = leval (f, splice (args, narg, 1, list (reshape (xbest,sz))));
nev(1)++;

if abs (err-vbest) > eps,
  printf ("d2_min : Whoa!! xbest does not eval to vbest\n");
  printf ("       : %8.3e - %8.3e = %8.3e != 0\n",err,vbest,err-vbest);
  keyboard
end
