
## ok = test_conjgrad_min       - Test that conjgrad_min works with extra
##                                arguments 
##
## Defines some simple functions and verifies that calling
## 
## conjgrad_min on them returns the correct minimum.
##
## Sets 'ok' to 1 if success, 0 otherwise

## The name of the optimizing function
optim_func = "cg_min";

ok = 1;
verbose = true;

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

function [v,stddev] = addnoise(u,db)

    if ! isfinite (db), v = u; stddev = 0; return; end

    if prod(size(u)) == 0,
        error("adnois called with void signal");
    end
    n = randn(size(u));

    dbn = 1;

    ## dbu = cov(u(:));
    dbu = msq( u(:) ) - mean( u(find(!isnan(u(:)))) )^2 ;

    stddev = 10^(-db/20)*sqrt(dbu) ; 

    v = u+n*stddev;
    % noislev(u,v)
endfunction                                                

if noise, obses = addnoise(obses,noise); end

extra = list (obsmat, obses);

function v = ff( xx )
  x = xx{1};
  obsmat = xx{2};
  obses = xx{3};
  v = msq( obses - obsmat*x ) + 1 ;
endfunction


function dv = dff( xx )
  x = xx{1};
  obsmat = xx{2};
  obses = xx{3};
  er = -obses + obsmat*x ;
  dv = 2*er'*obsmat / rows(obses) ;
  dv = dv';
  ## dv = 2*er'*obsmat ;
endfunction


printf( "gonna test : %s\n",optim_func);
if verbose,
  printf ("Nparams = P = %i,  Nobses = R = %i\n",P,R);
end


tic;
## [xlev,vlev,nlev] = feval (optim_func, "ff", "dff", xinit, "extra", extra) ;
x = {xinit, obsmat, obses};
[xlev,vlev,nlev] = feval \
    (optim_func, "ff", "dff", x);
toc;


if max (abs(xlev-truep)) > 100*sqrt (eps),
  if verbose, 
    printf ("Error is too big : %8.3g\n", max (abs (xlev-truep)));
  end
  ok = 0;
end

if verbose,
  xinit_ = {xinit,obsmat,obses};
  xtrue_ = {truep,obsmat,obses};
  printf ("  Costs :     init=%8.3g, final=%8.3g, best=%8.3g\n",\
	  ff(xinit_), vlev, ff(xtrue_));
end

if (ok) 
	printf("All tests ok\n");
endif

