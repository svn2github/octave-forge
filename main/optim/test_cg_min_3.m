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


## ok = test_cg_min       - Test that cg_min works with extra
##                                arguments 
##
## Defines some simple functions and verifies that calling
## 
## cg_min on them returns the correct minimum.
##
## Sets 'ok' to 1 if success, 0 otherwise

## The name of the optimizing function
optim_func = "cg_min";

ok = 1;

if ! exist ("verbose"), verbose = 0; end

if 0,
  P = 10+floor(30*rand(1)) ;	# Nparams
  R = P+floor(30*rand(1)) ;	# Nobses
else
  P = 2;
  R = 3;
end

noise = 0 ;
obsmat = randn(R,P) ;

truep = randn(P,1) ;
xinit = randn(P,1) ;

global obses ;
obses = obsmat*truep ;
if noise, obses = adnois(obses,noise); end

extra = list (obsmat, obses);


function v = ff(x, obsmat, obses)
  v = mean ( (obses - obsmat*x)(:).^2 ) + 1 ;
endfunction


function dv = dff(x, obsmat, obses)
  er = -obses + obsmat*x ;
  dv = 2*er'*obsmat / rows(obses) ;
  ## dv = 2*er'*obsmat ;
endfunction



if verbose
  printf ("test_cg_min_3 : Check that extra arguments are accepted\n");
  printf ("  Tested function : %s\n",optim_func);
  printf ("  Nparams = P = %i,  Nobses = R = %i\n",P,R);
end


mytic() ;
## [xlev,vlev,nlev] = feval (optim_func, "ff", "dff", xinit, "extra", extra) ;
[xlev,vlev,nlev] = feval \
    (optim_func, "ff", "dff", list (xinit, obsmat, obses));
tlev = mytic() ;


if max (abs(xlev-truep)) > 100*sqrt (eps),
  if verbose, 
    printf ("Error is too big : %8.3g\n", max (abs (xlev-truep)));
  end
  ok = 0;
end
if verbose,
  printf ("  Costs :     init=%8.3g, final=%8.3g, best=%8.3g\n",\
	  ff(xinit,obsmat,obses), vlev, ff(truep,obsmat,obses));    
end
if verbose
    printf ( "   time : %8.3g\n",tlev);
end
if verbose && ok
    printf ( "All tests ok\n");
end

