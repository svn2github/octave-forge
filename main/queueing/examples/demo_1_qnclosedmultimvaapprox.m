 S = [ 1, 1, 1, 1; 2, 1, 3, 1; 4, 2, 3, 3 ];
 V = ones(3,4);
 N = [10 5 1];
 m = [1 0 1 1];
 [U R Q X] = qnclosedmultimvaapprox(N,S,V,m);