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

## [ops,nread] = read_options (args,...) - Read options
##
## INPUT -------------
## args     : list   : Options and values
##
## OPTIONS -------
## 'op0'    , string : Space-separated names of opt taking no argument  <''>
## 'op1'    , string : Space-separated names of opt taking one argument <''>
## 'default', struct : Struct holding default option values           <none>
## 'prefix' , int    : If set, recognize opt from first chars. Else,     <0>
##                     only accept whole opt names                       
## 'nocase' , int    : If set, ignore case in option names               <0>
## 'quiet'  , int    : Behavior when a non-string or unknown opt is met  <0>
##              0    - Produce an error
##              1    - Return quietly (can be diagnosed by checking 'rem')
##      
##     Note : At least one of 'op0' or 'op1' should be specified.
## 
## OUTPUT ------------
## ops      : struct : Struct whose key/values are option names/values
## nread    : int    : Number of elements of args that were read
##
## USAGE -------------
##
##                              # Define options and defaults
## op0 = "is_man is_plane flies"
## default = struct ("is_man",1, "flies",0);
##
##                              # Read the options
##
## s = read_opts (list (all_va_arg), "op0",op0,"default",default)
##
##                              # Create variables w/ same name as options
##
## [is_man, is_plane, flies] = getfield (s,"is_man", "is_plane", "flies")
function [op,nread] = read_options (args, ...)

op = setfield ();		# Empty struct
op0 = op1 = " ";
guess = quiet = nocase = quiet = 0;

nargin--;
if rem (nargin, 2), error ("odd number of optional args"); end

while nargin
  nargin -= 2;
  if ! isstr (tmp = va_arg ()), error ("non-string option"); end
  if     strcmp (tmp, "op0")    , op0     = va_arg ();
  elseif strcmp (tmp, "op1")    , op1     = va_arg ();
  elseif strcmp (tmp, "default"), op      = va_arg ();
  elseif strcmp (tmp, "prefix") , prefix  = va_arg ();
  elseif strcmp (tmp, "nocase") , nocase  = va_arg ();
  elseif strcmp (tmp, "quiet")  , quiet   = va_arg ();
  else 
    error ("unknown option '%s' for option-reading function!",tmp);
  end
end

if length (op0) + length (op1) < 3
  error ("Either 'op0' or 'op1' should be specified");
end

###

if length (op0)
  if op0(1) != " ", op0 = [" ",op0]; end;
  if op0(length(op0)) != " ", op0 = [op0," "]; end;
end

if length (op1)
  if op1(1) != " ", op1 = [" ",op1]; end;
  if op1(length(op1)) != " ", op1 = [op1," "]; end;
end

opts = [op0,op1];		# Join options
				# Before iend : opts w/out arg. After, opts
iend = length (op0);		# w/ arg

spi = find (opts == " ");

opts_orig = opts;

if nocase, opts = tolower (opts); end

nread = 0;
while nread < length (args)
  
  oname = name = nth (args, ++nread);
  if ! isstr (name)		# Whoa! Option name is not a string
    if quiet, nread--; return;
    else      error ("option name in pos %i is not a string",nread);
    end
  end
  if nocase, name = tolower (name); end
  
  ii = findstr (name, opts);
  
  if isempty (ii)		# Whoa! Unknown option name
    if quiet, nread--; return;
    else      error ("unknown option '%s'",oname);
    end
  end
  
  if length (ii) > 1		# Ambiguous option name
    tmp = "";
    for i = ii
      tmp = [tmp,"', '",opts(i:spi(find (spi > i)(1))-1)];
    end
    tmp = tmp(1:length(tmp)-3);
    error ("ambiguous option '%s'. Could be '%s'",oname,tmp);
  end

				# Full name of option (w/ correct case)

  fullname = opts_orig(ii:spi(find (spi > ii)(1))-1);

  if ii < iend
    op = setfield (op, fullname, 1);
  else
    if nread < length (args)
      op = setfield (op, fullname, nth (args,++nread));
    else
      error ("options end before I can read value of option '%s'",oname);
    end
  end
end
