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
## 'prefix' , int    : If false, only accept whole opt names. Otherwise, <0>
##                     recognize opt from first chars, and choose 
##                     shortest if many opts start alike.
## 'nocase' , int    : If set, ignore case in option names               <0>
## 'quiet'  , int    : Behavior when a non-string or unknown opt is met  <0>
##              0    - Produce an error
##              1    - Return quietly (can be diagnosed by checking 'nread')
## 'skipnan', int    : Ignore NaNs if there is a default value.
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
## s = read_options (list (all_va_args), "op0",op0,"default",default)
##
##                              # Create variables w/ same name as options
##
## [is_man, is_plane, flies] = getfield (s,"is_man", "is_plane", "flies")
## pre 2.1.39 function [op,nread] = read_options (args, ...)
function [op,nread] = read_options (args, varargin) ## pos 2.1.39


verbose = 0;

op = setfield ();		# Empty struct
op0 = op1 = " ";
skipnan = prefix = quiet = nocase = quiet = 0;

nargin--;
if rem (nargin, 2), error ("odd number of optional args"); end


## beginpos 2.1.39
i=1;
while i<nargin
  if ! isstr (tmp = nth (varargin,i++)), error ("non-string option"); end
  if     strcmp (tmp, "op0")    , op0     = nth (varargin, i++);
  elseif strcmp (tmp, "op1")    , op1     = nth (varargin, i++);
  elseif strcmp (tmp, "default"), op      = nth (varargin, i++);
  elseif strcmp (tmp, "prefix") , prefix  = nth (varargin, i++);
  elseif strcmp (tmp, "nocase") , nocase  = nth (varargin, i++);
  elseif strcmp (tmp, "quiet")  , quiet   = nth (varargin, i++);
  elseif strcmp (tmp, "skipnan"), skipnan = nth (varargin, i++);
  elseif strcmp (tmp, "verbose"), verbose = nth (varargin, i++);
  else 
    error ("unknown option '%s' for option-reading function!",tmp);
  end
end
## endpos 2.1.39
## beginpre 2.1.39
# while nargin
#   nargin -= 2;
#   if ! isstr (tmp = va_arg ()), error ("non-string option"); end
#   if     strcmp (tmp, "op0")    , op0     = va_arg ();
#   elseif strcmp (tmp, "op1")    , op1     = va_arg ();
#   elseif strcmp (tmp, "default"), op      = va_arg ();
#   elseif strcmp (tmp, "prefix") , prefix  = va_arg ();
#   elseif strcmp (tmp, "nocase") , nocase  = va_arg ();
#   elseif strcmp (tmp, "quiet")  , quiet   = va_arg ();
#   else 
#     error ("unknown option '%s' for option-reading function!",tmp);
#   end
# end
## endpre 2.1.39

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

  ii = findstr ([" ",name], opts);
  
  if isempty (ii)		# Whoa! Unknown option name
    if quiet, nread--; return;
    else      error ("unknown option '%s'",oname);
    end
  end
  ii++;

  if length (ii) > 1		# Ambiguous option name

    fullen = zeros (1,length (ii)); # Full length of each optio
    tmp = correct = "";
    j = 0;
    for i = ii
      fullen(++j) = spi(find (spi > i)(1))-i ;
      tmp = [tmp,"', '",opts(i:i+fullen(j)-1)];
    end
    tmp = tmp(5:length(tmp));

    if sum (fullen == min (fullen)) > 1 || \
	  ((min (fullen) != length(name)) && ! prefix) ,
      error ("ambiguous option '%s'. Could be '%s'",oname,tmp);
    end
    j = find (fullen == min (fullen))(1);
    ii = ii(j);
  end

				# Full name of option (w/ correct case)

  fullname = opts_orig(ii:spi(find (spi > ii)(1))-1);
  if ii < iend
    if verbose, printf ("read_options : found boolean '%s'\n",fullname); end
    op = setfield (op, fullname, 1);
  else
    if verbose, printf ("read_options : found '%s'\n",fullname); end
    if nread < length (args)
      tmp = nth (args,++nread);
      if verbose, printf ("read_options : size is %i x %i\n",size(tmp)); end
      if !isnumeric (tmp) || !all (isnan (tmp(:))) || \
	    !struct_contains (op, fullname)
	op = setfield (op, fullname, tmp);
      else
	if verbose, printf ("read_options : ignoring nan\n"); end
      end
    else
      error ("options end before I can read value of option '%s'",oname);
    end
  end
end
