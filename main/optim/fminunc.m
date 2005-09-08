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

## [x,v,flag,out,df,d2f] = fminunc (f,x,opt,...) - M*tlab-like optimization
##
## Imitation of m*tlab's fminunc(). The optional 'opt' argument is a struct,
## e.g. produced by 'optimset()'.
##
## Supported options
## -----------------
## Diagnostics, [off|on] : Be verbose
## Display    , [off|iter|notify|final]
##                       : Be verbose unless value is "off"
## GradObj    , [off|on] : Function's 2nd return value is derivatives
## Hessian    , [off|on] : Function's 2nd and 3rd return value are
##                         derivatives and Hessian.
## TolFun     , scalar   : Termination criterion (see 'ftol' in minimize())
## TolX       , scalar   : Termination criterion (see 'utol' in minimize())
## MaxFunEvals, int      : Max. number of function evaluations
## MaxIter    , int      : Max. number of algorithm iterations
##
## These non-m*tlab are provided to facilitate porting code to octave:
## -----------------------
## "MinEquiv" , [off|on] : Don't minimize 'fun', but instead return the
##                         option passed to minimize().
##
## "Backend"  , [off|on] : Don't minimize 'fun', but instead return
##                         [backend, opt], the name of the backend
##                         optimization function that is used and the
##                         optional arguments that will be passed to it. See
##                         the 'backend' option of minimize().
##
## This function is a front-end to minimize().
function [x,fval,flag,out,df,d2f] = fminunc (fun,x0,opt,varargin)

if nargin < 3, opt = setfield (); end
if nargin > 3, 
  args = list (x0, varargin{:});
else 
  args = list (x0);
end

## Do some checks ####################################################
ws = es = "";

## Check for unknown options
## All known options
opn = [" DerivativeCheck Diagnostics DiffMaxChange DiffMinChange",\
       " Display GoalsExactAchieve GradConstr GradObj Hessian HessMult",\
       " HessPattern HessUpdate Jacobian JacobMult JacobPattern",\
       " LargeScale LevenbergMarquardt LineSearchType MaxFunEvals MaxIter",\
       " MaxPCGIter MeritFunction MinAbsMax PrecondBandWidth TolCon",\
       " TolFun TolPCG TolX TypicalX ",\
       " MinEquiv Backend "];

for [v,k] = opt
  if ! findstr ([" ",k," "],opn)
    es = [es,sprintf("Unknown option '%s'\n",k)];
  end
end

## Check for ignored options
## All ignored options
iop = [" DerivativeCheck DiffMaxChange DiffMinChange",\
       " Display GoalsExactAchieve GradConstr HessMult",\
       " HessPattern HessUpdate JacobMult JacobPattern",\
       " LargeScale LevenbergMarquardt LineSearchType",\
       " MaxPCGIter MeritFunction MinAbsMax PrecondBandWidth TolCon",\
       " TolPCG TypicalX "];
for [v,k] = opt
  if ! findstr ([" ",k," "],iop)
    ws = [ws,sprintf("Ignoring option '%s'\n",k)];
  end
end

if length (ws) && ! length (es), warn (ws);
elseif              length (es), error ([ws,es]);
end

## Transform fminunc options into minimize() options

opm = struct();		# minimize() options

equiv = struct ("TolX"       , "utol"   , "TolFun"     , "ftol",\
		"MaxFunEvals", "maxev"  , "MaxIter"    , "maxit",\
		"GradObj    ", "jac"    , "Hessian"    , "hess",\
		"Display"    , "verbose", "Diagnostics", "verbose",\
		"Backend"    , "backend");

for [v,k] = equiv
  if struct_contains (opt,k), opm = setfield (opm, getfield(equiv,k),v); end
end

				# Transform "off" into 0, other strings into
				# 1.
for [v,k] = opm
  if ischar (v)
    if strcmp (v,"off")
      opm = setfield (opm, k,0);
    else
      opm = setfield (opm, k,1);
    end
  end
end

unary_opt = " hess jac backend verbose ";
opml = list ();
for [v,k] = opm
  if findstr ([" ",k," "], unary_opt)
    opml = append (opml, list (k));
  else
    opml = append (opml, list (k, v));
  end
end
				# Return only options to minimize() ##
if struct_contains (opt, "MinEquiv")
  x = opml;			
  if nargout > 1
    warn ("Only 1 return value is defined with the 'MinEquiv' option");
  end
  return
				# Use the backend option #############
elseif struct_contains (opm, "backend")
  [x,fval] = minimize (fun, args, opml);
  if nargout > 2
    warn ("Only 2 return values are defined with the 'Backend' option");
  end
  return
else  				# Do the minimization ################
  [x,fval,out] = minimize (fun, args, opml);
  
  if struct_contains (opm, "maxev")
    flag = out(1) < maxev;
  else
    flag = 1;
  end
  
  if nargout > 4
    args = splice (args, 1, 1, list (x));
    [dummy,df,d2f] = leval (fun, args);
  elseif nargout > 3
    args = splice (args, 1, 1, list (x));
    [dummy,df] = leval (fun, args);
  end
end
