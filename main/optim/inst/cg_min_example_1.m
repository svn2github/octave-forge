## ok = test_conjgrad_min       - Test that conjgrad_min works
##
## Defines some simple functions and verifies that calling
## 
## conjgrad_min on them returns the correct minimum.
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
  P = 15;
  R = 20;			# must have R >= P
end

noise = 0 ;
global obsmat ;
obsmat = randn(R,P) ;
global truep ;
truep = randn(P,1) ;
xinit = randn(P,1) ;

global obses ;
obses = obsmat*truep ;
if noise, obses = adnois(obses,noise); end

function s = msq(x)
    try
    	s = mean(x(find(!isnan(x))).^2);
   	catch
		s = nan;
	end
endfunction
                        
function v = ff(x)
  global obsmat;
  global obses;
  v = msq( obses - obsmat*x{1} ) + 1 ;
endfunction


function dv = dff(x)
  global obsmat;
  global obses;
  er = -obses + obsmat*x{1} ;
  dv = 2*er'*obsmat / rows(obses) ;
  dv = dv';
  ## dv = 2*er'*obsmat ;
endfunction

printf("gonna test : %s\n",optim_func);
if verbose,
  printf ("Nparams = P = %i,  Nobses = R = %i\n",P,R);
end


tic;
[xlev,vlev,nlev] = feval(optim_func, "ff", "dff", xinit) ;
toc;


if max (abs(xlev-truep)) > 100*sqrt (eps),
  if verbose, 
    printf ("Error is too big : %8.3g\n", max (abs (xlev-truep)));
  end
  ok = 0;
end
if verbose,
  printf ("  Costs :     init=%8.3g, final=%8.3g, best=%8.3g\n",\
	  ff(xinit), vlev, ff(truep));    
end
if (ok) printf("All tests ok\n"); endif

