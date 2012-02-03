 k = [1 2 0];
 K = sum(k); # Total population size
 S = [ 1/0.8 1/0.6 1/0.4 ];
 m = [ 2 3 1 ];
 V = [ 1 .667 .2 ];
 [U R Q X G] = qnconvolution( K, S, V, m );
 p = [0 0 0]; # initialize p
 # Compute the probability to have k(i) jobs at service center i
 for i=1:3
   p(i) = (V(i)*S(i))^k(i) / G(K+1) * \
          (G(K-k(i)+1) - V(i)*S(i)*G(K-k(i)) );
   printf("k(%d)=%d prob=%f\n", i, k(i), p(i) );
 endfor