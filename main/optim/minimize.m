## [x,v,nev,...] = minimize (f,args,...) - Minimize f
##
## ARGUMENTS
## f    : string  : Name of function. Must return a real value
## args : list or : List of arguments to f (by default, minimize the first)
##        matrix  : f's only argument
##
## RETURNED VALUES
## x   : matrix  : Local minimum of f. Let's suppose x is M-by-N.
## v   : real    : Value of f in x0
## nev : integer : Number of function evaluations 
##     or 1 x 2  : Number of function and derivative evaluations (if
##                 derivatives are used)
## 
## OPTIONS : DERIVATIVES   You may provide one of the following options.
## ---------------------   Otherwise, the Nelder-Mean (see nelder_mead_min)
##                         method is used.
## 
## 'df' , df      : Name of a function that returns the derivatives of f
##                  in x : [dfx] = feval (df, x) where dfx is 1x(M*N). The
##                  conjugate gradient method (see cg_min) will be used.
##
## 'd2f', d2f     : Name of a function that returns the value of f, of its
##                  1st and 2nd derivatives : [fx,dfx,d2fx] = feval (d2f, x)
##                  where fx is a real number, dfx is 1x(M*N) and d2fx is
##                  (M*N)x(M*N). A Newton-like method (d2_min) will be used.
##
##
## 'd2i', d2i     : Name of a function that returns the value of f, of its
##                  1st and pseudo-inverse of second derivatives : 
##                  [fx,dfx,id2ix] = feval (d2i, x) where fx is a real
##                  number, dfx is 1x(M*N) and d2ix is (M*N)x(M*N).
##                  A Newton-like method will be used (see d2_min).
##
##            NOTE : df, d2f or d2i take the same arguments as f.
## 
## 'order', n     : Use derivatives of order n. If the n'th order derivative
##                  is not specified by 'df', 'd2f' or 'd2i', it will be
##                  computed numerically. Currently, only order 1 works.
## 
## OPTIONS : STOPPING CRITERIA  Default is to use 'tol'
## ---------------------------
## 'ftol', ftol   : Stop search when value doesn't improve, as tested by
##
##              ftol > Deltaf/max(|f(x)|,1)
##
##                 where Deltaf is the decrease in f observed in the last
##                 iteration.                                 Default=10*eps
##
## 'utol', utol   : Stop search when updates are small, as tested by
##
##              tol > max { dx(i)/max(|x(i)|,1) | i in 1..N }
##
##                 where  dx is the change in the x that occured in the last
##                 iteration.
##
## 'dtol',dtol    : Stop search when derivatives are small, as tested by
##
##              dtol > max { df(i)*max(|x(i)|,1)/max(v,1) | i in 1..N }
##
##                 where x is the current minimum, v is func(x) and df is
##                 the derivative of f in x. This option is ignored if
##                 derivatives are not used in optimization.
##
## MISC. OPTIONS
## -------------
## 'maxev', m     : Maximum number of function evaluations     Default=inf
##
## 'narg',  narg  : Position of the minimized argument in args Default=1
##
## 'backend'      : Instead of performing the minimization itself, return
##                  [backend, control], the name and control argument of the
##                  backend used by minimize(). Minimimzation can then be
##                  obtained without the overhead of minimize by calling :
##
##                  [x,v,nev] = feval (backend, args, ctl)
##
function [x,v,nev,...] = minimize (f,args,...)

static minimize_warn = 1;
if minimize_warn
  warning ("minimize() interface subject to change.");
endif
minimize_warn = 0;

verbose = 0;

df = d2f = d2i = "";
tol = utol = dtol = nan;

order = crit = tol = narg = maxev = nan;

# ####################################################################
# Read the options ###################################################
# ####################################################################
# Options with a value
opt1 = " tol utol dtol df d2f d2i maxev narg order " ;
# Boolean options 
opt0 = " verbose backend " ;
filename = "minimize";

va_start() ;
nargin = nargin - 2 ;

read_options

if     ! isnan (tol) , crit = 1;
elseif ! isnan (utol), crit = 2; tol = utol;
elseif ! isnan (dtol), crit = 3; tol = dtol;
end


if     length (d2i), method = "d2_min"; 
elseif length (d2f), method = "d2_min", 
elseif length (df),  method = "cg_min";
else                 method = "nelder_mead_min";
end

				# Choose method by specifying order ########

must_clear_ndiff = 0;		# Flag telling to clear ndiff function

if ! isnan (order)

  if order == 0, method = "nelder_mead_min";
  elseif order == 1
    if ! length (df)		# If necessary, define numerical diff

      df = temp_name (["d",f]);	# Choose a name
				# Define the function
      eval (cdiff (f, narg, length (args), df));
      must_clear_ndiff = 1;
    end
  else
    error ("minimize : 'order' option only implemented for order<2\n");
  end
end				# EOF choose method by specifying order ####


ctl = nan*zeros (1,6);
ctl(1) = crit;
ctl(2) = tol;
ctl(3) = narg;
ctl(4) = maxev;

if strcmp (method, "d2_min"),
  ctl = ctl(1:5); 
  if length (d2i), ctl(5) = 1; d2f = d2i; end

  if backend, x = "d2_min"; v = ctl; return; end

  [x, v, nev, h] = d2_min (f, d2f, args, ctl);
  if nargout > 3, vr_val (h); end
  
elseif strcmp (method, "cg_min")
  ctl = ctl(1:4);

  if backend, x = "cg_min"; v = ctl; return; end

  [x, v, nev] = cg_min (f, df, args, ctl);
else 

  if backend, x = "nelder_mead_min"; v = ctl; return; end

  [x, v, nev] = nelder_mead_min (f, args, ctl);
end

if must_clear_ndiff, clear(df); end
