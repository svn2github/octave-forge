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

## Test whether d2_min() functions correctly, with two args
##
## Gives a simple quadratic programming problem (function ff below).
##
## Sets a ok variable to 1 in case of success, 0 in case of failure
##
## If a variables "verbose" is set, then some comments are output.

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>

1 ;

ok = 0;

if ! exist ("verbose"), verbose = 0; end

P = 10+floor(30*rand(1)) ;	# Nparams
R = P+floor(30*rand(1)) ;	# Nobses
noise = 0 ;
obsmat = randn(R,P) ;
truep = randn(P,1) ;
xinit = randn(P,1) ;

obses = obsmat*truep ;
if noise, obses = adnois(obses,noise); end

y.obses = obses;
y.obsmat = obsmat;

function v = ff (x, y)
  v = msq( y.obses - y.obsmat*x ) ;
endfunction


function [v,dv,d2v] = d2ff (x, y)
  er = -y.obses + y.obsmat*x ;
  dv = er'*y.obsmat ;
  v = msq( er ) ;
  d2v = pinv( y.obsmat'*y.obsmat ) ;
endfunction

##       dt = mytic()
##
## Returns the cputime since last call to 'mytic'.

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: October 2000
function dt = mytic()
   static last_mytic = 0 ;
   [t,u,s] = cputime() ;
   dt = t - last_mytic ;
   last_mytic = t ;
endfunction

## s = msq(x)                   - Mean squared value, ignoring nans
##
## s == mean(x(:).^2) , but ignores NaN's

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: October 2000

function s = msq(x)
try
  s = mean(x(find(!isnan(x))).^2);
catch
  s = nan;
end
endfunction


ctl = nan*zeros(1,5); ctl(5) = 1;

if verbose
    printf ( "gonna do : d2_min\n");
end
mytic() ;
[xlev,vlev,nev] = d2_min ("ff", "d2ff", list (xinit,y), ctl) ;
tlev = mytic ();

if verbose,
  printf("d2_min should find in one iteration + one more to check\n");
  printf(["d2_min :  niter=%-4d  nev=%-4d  nobs=%-4d  nparams=%-4d\n",\
	  "  time=%-8.3g errx=%-8.3g   minv=%-8.3g\n"],...
         nev([2,1]), R, P, tlev, max (abs (xlev-truep)), vlev);
end

ok = 1;
if nev(2) != 2,
  if verbose
      printf ( "Too many iterations for this function\n");
  end
  ok = 0;
end

if max (abs(xlev-truep )) > sqrt (eps),
  if verbose
      printf ( "Error is too big : %-8.3g\n", max (abs (xlev-truep)));
  end
  ok = 0;
end

if verbose && ok
    printf ( "All tests ok\n");
end