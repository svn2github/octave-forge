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

## [s,v,n] = brent_line_min (f,dx,args,ctl) - Line minimization of f
##
## Find minimum of f on line { args(nmin) + dx*w | a < w < b } by
## bracketing. a and b are passed through argument ctl.
##
## ARGUMENTS
## f     : string : Name of function. Must return a real value
## args  : list   : Arguments passed to f.
##      or RxC    : f's only argument.
## ctl   : 5      : (optional) Control variables, described below.
## 
## RETURNED VALUES
## s   : 1        : Minimum is at x + s*dx
## v   : 1        : Value of f at x + s*dx
## nev : 1        : Number of function evaluations
##
## CONTROL VARIABLES
## ctl(1)       : Upper bound for error on s              Default=sqrt(eps)
## ctl(2)       : Position of minimized argument in args  Default= 1
## ctl(3)       : Maximum number of function evaluations  Default= inf
## ctl(4)       : a                                       Default=-inf
## ctl(5)       : b                                       Default= inf
##
## Default values will be used if ctl is not passed or if nan values are
## given.
function [s,gs,nev] = brent_line_min (f,dx,args,ctl)

verbose = 0;

seps = sqrt (eps);

				# Default control variables
tol = 10*eps; # sqrt (eps); 
narg = 1;
maxev = inf;
a = -inf;
b = inf;

if nargin >= 4,			# Read arguments
  if !isnan (ctl (1)), tol = ctl(1); end
  if length (ctl)>=2 && !isnan (ctl(2)), narg = ctl(2); end
  if length (ctl)>=3 && !isnan (ctl(3)), maxev = ctl(3); end
  if length (ctl)>=4 && !isnan (ctl(4)), a = ctl(4); end
  if length (ctl)>=5 && !isnan (ctl(5)), b = ctl(5); end

end				# Otherwise, use defaults, def'd above

if a>b, tmp=a; a=b; b=tmp; end

if narg > length (args),
  printf ("brent_line_min : narg==%i > length (args)==%i",\
	  narg, length (args));
  keyboard
end

if ! is_list (args), args = list (args); end

x = nth (args, narg);

[R,C] = size (x);
N = R*C;			# Size of argument


gs0 = gs = leval (f, args);
nev = 1;

				# Initial value
s = 0;

if all (dx==0), return; end	# Trivial case

				# If any of the bounds is infinite, find
				# finite bounds that bracket minimum
if !isfinite (a) || !isfinite (b),
  if !isfinite (a) && !isfinite (b),
    [a,b, ga,gb, n] = bracket_min (f, dx, narg, args);
  elseif !isfinite (a),
    [a,b, ga,gb, n] = semi_bracket (f, -dx, -b, narg, args);
    tmp = a;  a = -b; b = -tmp;
    tmp = ga; ga = gb; gb = tmp;
  else
    [a,b, ga,gb, n] = semi_bracket (f,  dx, a, narg, args);
  end
  nev += n;
else
  ga = leval (f, splice (args, narg, 1, list (x + a*dx)));
  gb = leval (f, splice (args, narg, 1, list (x + b*dx)));
  nev += 2;
end				# End of finding bracket for minimum


if a > b,			# Check assumptions
  printf ("brent_line_min : a > b\n");
  keyboard
end

s = 0.5*(a+b);
gs = leval (f, splice (args, narg, 1, list (x + s*dx)));
nev++;

if verbose,
  printf ("[a,s,b]=[%.3e,%.3e,%.3e], [ga,gs,gb]=[%.3e,%.3e,%.3e]\n",\
	  a,s,b,ga,gs,gb);
end

maxerr = 2*tol;

while (b-a > maxerr) && nev < maxev,

  if gs > ga && gs > gb,	# Check assumptions
    printf ("brent_line_min : gs > ga && gs > gb\n");
    keyboard
  end
  
  if ga == gb && gb == gs, break end

				# Don't trust poly_2_ex for glued points
				# (see test_poly_2_ex).

  ## if min (b-s, s-a) > 10*seps,

				# If s is not glued to a or b and does not
				# look linear 
  ## mydet = sum (l([2 3 1]).*f([3 1 2])-l([3 1 2]).*f([2 3 1]))
  mydet = sum ([s b a].*[gb ga gs] - [b a s].*[gs gb ga]);
  if min (b-s, s-a) > 10*seps && abs (mydet) > 10*seps && \
	(t = poly_2_ex ([a,s,b], [ga, gs, gb])) < b && t > a,

				# t has already been set

    ## if t>=b || t<=a,
    ##  printf ("brent_line_min : t is not in ]a,b[\n");
    ##  keyboard
    ## end

				# Otherwise, reduce the biggest of the
				# intervals, but not too much
  elseif s-a > b-s,
    t = max (0.5*(a+s), s-100*seps);
  else
    t = min (0.5*(s+b), s+100*seps);
  end

  if abs (t-s) < 0.51*maxerr,
    if verbose
        printf ( "ungluing t and s\n");
    end
    t = s + (1 - 2*(s-a > b-s))*0.49*maxerr ; 
  end

  if a > s || s > b,		# Check assumptions
    printf ("brent_line_min : a > s || s > b\n");
    keyboard
  end

  gt = leval (f, splice (args, narg, 1, list (x + t*dx)));
  nev++;

  if verbose,
    printf ("t = %.3e, gt = %.3e\n",t,gt);
  end

  if t<s,			# New point is in ]a,s[

    if gt > ga + seps,		# Check assumptions
      printf ("brent_line_min : gt > ga\n");
      keyboard
    end

    if gt < gs,
      b = s; gb = gs;
      s = t; gs = gt;
    else
      a = t; ga = gt;
    end
  else				# New point is in ]s,b[
    if gt > gb + seps,		# Check assumptions
      printf ("brent_line_min : gt > gb\n");
      keyboard
    end

    if gt < gs,
      a = s; ga = gs;
      s = t; gs = gt;
    else
      b = t; gb = gt;
    end
  end

  if verbose,
    printf ("[a,s,b]=[%.3e,%.3e,%.3e], [ga,gs,gb]=[%.3e,%.3e,%.3e]\n",\
	    a,s,b,ga,gs,gb);
  end
  ## keyboard
  ## [b-a, maxerr]
end

s2 = 0.5*(a+b);
gs2 = leval (f, splice (args, narg, 1, list (x + s2*dx)));
nev++;

if gs2 < gs,
  s = s2; gs = gs2;
end

if gs > gs0,
  printf ("brent_line_min : goes uphill by %8.3e\n",gs-gs0);
  keyboard
end