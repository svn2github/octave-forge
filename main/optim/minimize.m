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
##
## Extra arguments are either a succession of option-value pairs or a single
## list or struct of option-value pairs (for unary options, the value in the
## struct is ignored).
## 
## OPTIONS : DERIVATIVES   Derivatives may be used if one of these options
## ---------------------   uesd. Otherwise, the Nelder-Mean (see
##                         nelder_mead_min) method is used.
## 
## 'df' , df      : Name of a function that returns the derivatives of f
##                  in x : dfx = feval (df, x) where dfx is 1x(M*N). A
##                  variable metric method (see bfgs) will be used.
##
## 'jac'          : Use [fx, dfx] = leval(f, args) to compute derivatives
##                  and use a variable metric method (bfgs).
##
## 'd2f', d2f     : Name of a function that returns the value of f, of its
##                  1st and 2nd derivatives : [fx,dfx,d2fx] = feval (d2f, x)
##                  where fx is a real number, dfx is 1x(M*N) and d2fx is
##                  (M*N)x(M*N). A Newton-like method (d2_min) will be used.
##
## 'hess'         : Use [fx,dfx,d2fx] = leval (f, args) to compute 1st and
##                  2nd derivatives, and use a Newton-like method (d2_min).
##
## 'd2i', d2i     : Name of a function that returns the value of f, of its
##                  1st and pseudo-inverse of second derivatives : 
##                  [fx,dfx,id2fx] = feval (d2i, x) where fx is a real
##                  number, dfx is 1x(M*N) and d2ix is (M*N)x(M*N).
##                  A Newton-like method will be used (see d2_min).
##
## 'ihess'        : Use [fx,dfx,id2fx] = leval (f, args) to compute 1st
##                  derivative and the pseudo-inverse of 2nd derivatives,
##                  and use a Newton-like method (d2_min).
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
## 'maxev', m     : Maximum number of function evaluations             <inf>
##
## 'narg' , narg  : Position of the minimized argument in args           <1>
## 'isz'  , step  : Initial step size (only for 0 and 1st order method)  <1>
##                  Should correspond to expected distance to minimum
## 'verbose'      : Display messages during execution
##
## 'backend'      : Instead of performing the minimization itself, return
##                  [backend, control], the name and control argument of the
##                  backend used by minimize(). Minimimzation can then be
##                  obtained without the overhead of minimize by calling, if
##                  a 0 or 1st order method is used :
##
##              [x,v,nev] = feval (backend, args, control)
##                   
##                  or, if a 2nd order method is used :
##
##              [x,v,nev] = feval (backend, control.d2f, args, control)
##
function [x,v,nev,...] = minimize (f,args,...)

static minimize_warn = 1;
if minimize_warn
  warning ("minimize() interface subject to change.");
endif
minimize_warn = 0;

# ####################################################################
# Read the options ###################################################
# ####################################################################
# Options with a value
op1 = " ftol utol dtol df d2f d2i order narg maxev isz ";
# Boolean options 
op0 = " verbose backend jac hess ihess" ;

default = setfield ("backend",0,"verbose",0,\
		    "df","", "df","","d2f","","d2i","",  \
		    "hess", 0,  "ihess", 0,  "jac", 0,   \
		    "ftol" ,nan, "utol",nan, "dtol", nan,\
		    "order",nan, "narg",nan, "maxev",nan,\
		    "isz",  nan);

if nargin == 3			# Accomodation to struct and list optional
				# args
  tmp = va_arg ();

  if is_struct (tmp)
    opls = list ();
    for [v,k] = tmp		# Treat separately unary and binary opts
      if findstr ([" ",k," "],op0)
	opls = append (opls, k);
      else
	opls = append (opls, k, v);
      end
    end
  elseif is_list (tmp)
    opls = tmp;
  else
    opls = list (tmp);
  end
else
  opls = list (all_va_args);
end
ops = read_options (opls,\
		    "op0",op0, "op1",op1, "default",default);

[backend,verbose,   \
 df, df, d2f, d2i,  \
 hess, ihess, jac,  \
 ftol, utol, dtol,  \
 order, narg, maxev,\
 isz] = getfield (ops, "backend","verbose",\
		  "df", "df","d2f", "d2i", \
		  "hess", "ihess", "jac",  \
		  "ftol" , "utol", "dtol", \
		  "order", "narg", "maxev",\
		  "isz");


				# Basic coherence checks #############

ws = "";			# Warning string
es = "";			# Error string

				# Warn if more than 1 differential is given
if !!length (df) + !!length (d2f) + !!length (d2i) + jac + hess + ihess > 1
				# Order of preference of 
  if length (d2i), ws = [ws,"d2i='",d2i,"', "]; end
  if length (d2f), ws = [ws,"d2f='",d2f,"', "]; end
  if length (df),  ws = [ws,"df='",df,"', "]; end
  if hess       ,  ws = [ws,"hess=1, "]; end
  if ihess      ,  ws = [ws,"ihess=1, "]; end
  if jac        ,  ws = [ws,"jac=1, "]; end
  ws = ws(1:length(ws)-2);
  ws = ["Options ",ws," were passed. Only one will be used\n"]
end

				# Check that enough args are passed to call
				# f(), unless backend is specified, in which
				# case I don't need to call f()
if ! isnan (narg) && ! backend
  if is_list (args)
    if narg > length (args)
      es = [es,sprintf ("narg=%i > length(args)=%i\n",narg, length(args))];
    end
  elseif narg > 1
    es = [es,sprintf ("narg=%i, but a single argument was passed\n",narg)];
  end
end

if length (ws), warn (ws); end
if length (es), error (es); end	# EOF Basic coherence checks #########


op = 0;				# Set if any option is passed and should be
				# passed to backend

if ! isnan (ftol)   , ctls.ftol    = ftol;  op = 1; end
if ! isnan (utol)   , ctls.utol    = utol;  op = 1; end
if ! isnan (dtol)   , ctls.dtol    = dtol;  op = 1; end
if ! isnan (maxev)  , ctls.maxev   = maxev; op = 1; end
if ! isnan (narg)   , ctls.narg    = narg;  op = 1; end
if ! isnan (isz)    , ctls.isz     = isz;   op = 1; end
if         verbose  , ctls.verbose = 1;     op = 1; end

				# defaults That are used in this function :
if isnan (narg), narg = 1; end

				# ##########################################
				# Choose method according to available
				# derivatives (overriden below)
if     ihess, d2f = f;  ctls.id2f = 1; op = 1;
elseif hess,  d2f = f;
end
  

if     length (d2i), method = "d2_min"; ctls.id2f = 1; op = 1; d2f = d2i;
elseif length (d2f), method = "d2_min";
elseif length (df) , method = "bfgs"  ; ctls.df  = df; op = 1;
elseif jac         , method = "bfgs"  ; ctls.jac = 1 ; op = 1;
else                 method = "nelder_mead_min";
end

if verbose
  printf ("minimize(): Using '%s' as back-end\n",method);
end
				# ##########################################
				# Choose method by specifying order ########

if ! isnan (order)

  if     order == 0, method = "nelder_mead_min";
  elseif order == 1
    method = "bfgs";

  elseif order == 2
    if ! (length (d2f) || length (d2i))
      error ("minimize(): 'order' is 2, but 2nd differential is missing\n");
    end
  else
    error ("minimize(): 'order' option only implemented for order<=2\n");
  end
end				# EOF choose method by specifying order ####

				# More checks ##############################
ws = "";
if !isnan (isz) && strcmp (method,"d2_min")
  ws = [ws,"option 'isz' is passed to method that doesn't use it"];
end
if length (ws), warn (ws); end
				# EOF More checks ##########################

if     strcmp (method, "d2_min"), all_args = list (f, d2f, args);
elseif strcmp (method, "bfgs"),   all_args = list (f, args);
else                              all_args = list (f, args);
end
				# Eventually add ctls to argument list
if op, all_args = append (all_args, list (ctls)); end

if ! backend			# Call the backend ###################
  if strcmp (method, "d2_min"),
    [x,v,nev,h] = leval (method, all_args);
				# Eventually return inverse of Hessian
    if nargout > 3, vr_val (h); end 
  else
    [x,v,nev] = leval (method, all_args);
  end

else				# Don't call backend, just return its name
				# and arguments. 

  x = method;
  if op, v = ctls; else v = []; end
end


