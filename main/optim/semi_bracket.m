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

## [a, b, ga, gb, nev] = semi_bracket (f, dx, a, narg, args)
##
## Find an interval containing a local minimum of the function 
## g : h in [a, inf[ ---> f (x+h*dx) where x = nth (args, narg)
##
## The local minimum may be in a.
## a < b.
## nev is the number of function evaluations.

function [a,b,ga,gb,n] = semi_bracket (f, dx, a, narg, args)

step = 1;

x = nth (args, narg);

ga = leval (f, splice (args, narg, 1, list (x+a*dx)));

b = a + step;

gb = leval (f, splice (args, narg, 1, list (x+b*dx)));
n = 2;

if gb >= ga, return ; end

while 1,

  c = b + step;

  gc = leval (f,  splice (args, narg, 1, list (x+c*dx)));
  n++;

  if gc >= gb,			# ga >= gb <= gc
    gb = gc; b = c;
    return;
  end
  step *= 2;
  a = b; b = c; ga = gb; gb = gc;
end









