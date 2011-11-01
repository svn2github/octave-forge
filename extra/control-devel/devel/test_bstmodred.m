A =  [ -0.04165  0.0000  4.9200  -4.9200  0.0000  0.0000  0.0000
       -5.2100  -12.500  0.0000   0.0000  0.0000  0.0000  0.0000
        0.0000   3.3300 -3.3300   0.0000  0.0000  0.0000  0.0000
        0.5450   0.0000  0.0000   0.0000 -0.5450  0.0000  0.0000
        0.0000   0.0000  0.0000   4.9200 -0.04165 0.0000  4.9200
        0.0000   0.0000  0.0000   0.0000 -5.2100 -12.500  0.0000
        0.0000   0.0000  0.0000   0.0000  0.0000  3.3300 -3.3300 ];

B =  [  0.0000   0.0000
        12.500   0.0000
        0.0000   0.0000
        0.0000   0.0000
        0.0000   0.0000
        0.0000   12.500
        0.0000   0.0000 ];

C =  [  1.0000   0.0000  0.0000   0.0000  0.0000  0.0000  0.0000
        0.0000   0.0000  0.0000   1.0000  0.0000  0.0000  0.0000
        0.0000   0.0000  0.0000   0.0000  1.0000  0.0000  0.0000 ];

D =  [  0.0000   0.0000
        0.0000   0.0000
        0.0000   0.0000 ];

sys = ss (A, B, C, D, "scaled", true);

sysr = bstmodred (sys, "beta", 1.0, "tol1", 0.1, "tol2", 0.0)
[Ao, Bo, Co, Do] = ssdata (sysr);