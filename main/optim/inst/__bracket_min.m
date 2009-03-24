## [a, b, ga, gb, nev] = semi_bracket (f, dx, a, narg, args)
##
## Find an interval containing a local minimum of the function 
## g : h in reals ---> f (x+h*dx) where x = args{narg}
##
## a < b.
## nev is the number of function evaluations

## Author : Etienne Grossmann <etienne@isr.ist.utl.pt>
## Modified by: Levente Torok <TorokLev@gmail.com>
## This software is distributed under the terms of the GPL

function [a, b, ga, gb, n] = __bracket_min (f, dx, narg, args)

    [a,b, ga,gb, n] = __semi_bracket (f, dx, 0, narg, args);

    if a != 0, return; end

    [a2,b2, ga2,gb2, n2] = __semi_bracket (f, -dx, 0, narg, args);

    n += n2;

    if a2 == 0,
        a = -b2; ga = gb2;
    else
    a = -b2;
    b = -a2;
    ga = gb2;
    gb = ga2;
end
