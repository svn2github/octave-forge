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


##
## Test inline.m
##

ok = 1;

if ! exist ("verbose"), verbose = 0; end

if verbose
  printf ("\n   Testing 'inline'\n\n");
end

fn = inline ("x.^2 + 1","x");
        


if  feval (fn, 6) != 37
  ok = 0;
  if verbose, printf ("not ok 1\n"); end
elseif verbose, printf ("ok 1\n");
end

if verbose
  if ok, printf ("All tests ok\n");
  else   printf ("Whoa!! Some test(s) failed\n");
  end
end

