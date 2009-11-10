## There's a bug in __tzero__.m as well as in the 
## original function tzero.m from the OCST (control-1.0.17)


## Results from the "Dark Side" 7.5 and 7.8
##
##  -13.2759
##   12.5774
##  -0.0155


## Results from Scilab 5.2.0b1 (trzeros)
##
##  - 13.275931  
##    12.577369  
##  - 0.0155265


%!shared z, z_exp
%! A = [   -0.7   -0.0458     -12.2        0
%!            0    -0.014   -0.2904   -0.562
%!            1   -0.0057      -1.4        0
%!            1         0         0        0 ];
%!
%! B = [  -19.1      -3.1
%!      -0.0119   -0.0096
%!        -0.14     -0.72
%!            0         0 ];
%!
%! C = [      0         0        -1        1
%!            0         0     0.733        0 ];
%!
%! D = [      0         0
%!       0.0768    0.1134 ];
%!
%! sys = ss (A, B, C, D);
%! z = sort (zero (sys));
%!
%! z_exp = sort ([-13.2759; 12.5774; -0.0155]);
%!
%!assert (z, z_exp, 1e-4);