## wpolyfitdemo(p)
## Generate some random data for the polynomial p, then fit that
## data.  If p ends with 0, then the fit will be constrained to
## go through the origin.  
##
## To force a variety of weights, poisson statistics are used to 
## estimate the variance on the individual points, but gaussian 
## statistics are used to generate new values within that variance.
function wpolyfitdemo(pin)
  if (nargin == 0) pin = [3 -1 2]'; endif
  x = [-3:0.1:3];
  y = polyval(pin,x);
  ## poisson weights
  % dy = sqrt(abs(y));
  ## uniform weights in [0.5,1]
  dy = 0.5 + 0.5*rand(size(y));

  y = y + randn(size(y)).*dy;
  printf("Original polynomial: %s\n", polyout(pin,'x'));
  if (pin(length(pin)) == 0)
    wpolyfit(x,y,dy,length(pin)-1,'origin');
  else
    wpolyfit(x,y,dy,length(pin)-1);
  endif
endfunction
