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

## opt = optimset (...)         - manipulate m*tlab-style options structure
## 
## This function returns a m*tlab-style options structure that can be used
## with the fminunc() function.
##
## INPUT : Input consist in one or more structs followed by option-value
## pairs. The option that can be passed are those of m*tlab's 'optimset'.
## Whether fminunc() accepts them is another question (see fminunc()).
## 
## Two extra options are supported which indicate how to use directly octave
## optimization tools (such as minimize() and other backends):
##
## "MinEquiv", [on|off] : Tell 'fminunc()' not to minimize 'fun', but
##                        instead return the option passed to minimize().
##
## "Backend", [on|off] : Tell 'fminunc()' not to minimize 'fun', but
##                       instead return the [backend, opt], the name of the
##                       backend optimization function that is used and the
##                       optional arguments that will be passed to it. See
##                       the 'backend' option of minimize().
## 
function opt = optimset (...)

## Diagnostics  , ["on"|{"off"}] : 
## DiffMaxChange, [scalar>0]     : N/A (I don't know what it does)
## DiffMinChange, [scalar>0]     : N/A (I don't know what it does)
## Display      , ["off","iter","notify","final"] 
##                               : N/A

args = list (all_va_args);

opt = setfield ();

				# Integrate all leading structs

while length (args) && is_struct (o = nth (args, 1))

  args = args(2:length(args)); 	# Remove 1st element of args
				# Add key/value pairs
  for [v,k] = o, opt = set_field (opt,k,v); end    
end

## All the option
op1 = [" DerivativeCheck Diagnostics DiffMaxChange DiffMinChange",\
       " Display GoalsExactAchieve GradConstr GradObj Hessian HessMult",\
       " HessPattern HessUpdate Jacobian JacobMult JacobPattern",\
       " LargeScale LevenbergMarquardt LineSearchType MaxFunEvals MaxIter",\
       " MaxPCGIter MeritFunction MinAbsMax PrecondBandWidth TolCon",\
       " TolFun TolPCG TolX TypicalX ",\
       " MinEquiv Backend "];

opt = read_options (args, "op1",op1, "default",opt,"prefix",1,"nocase",1);