## [a, b, ga, gb, nev] = semi_bracket (f, dx, a, narg, args)
##
## Find an interval containing a local minimum of the function 
## g : h in [a, inf[ ---> f (x+h*dx) where x = nth (args, narg)
##
## The local minimum may be in a.
## a < b.
## nev is the number of function evaluations.

## Author : Etienne Grossmann <etienne@isr.ist.utl.pt>
## Modified by: Levente Torok <TorokLev@gmail.com>
## This software is distributed under the terms of the GPL

function [a,b,ga,gb,n] = __semi_bracket (f, dx, a, narg, args)

step = 1;

x = nth (args, narg);
args{narg} =  x+a*dx; ga = feval (f, args );
b = a + step;
args{narg} =  x+b*dx; gb = feval (f, args );
n = 2;

if gb >= ga, return ; end

while 1,

  c = b + step;
  args{narg} = x+c*dx; gc = feval( f, args );
  n++;

  if gc >= gb,			# ga >= gb <= gc
    gb = gc; b = c;
    return;
  end
  step *= 2;
  a = b; b = c; ga = gb; gb = gc;
end
