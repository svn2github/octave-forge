 P = [ 0 0.4 0.6 0; \
       0.2 0 0.2 0.6; \
       0 0 0 1; \
       0 0 0 0 ];
 lambda = [0.1 0 0 0.3];
 V = qnvisits(P,lambda);
 S = [2 1 2 1.8];
 m = [3 1 1 2];
 [U R Q X] = qnopensingle( sum(lambda), S, V, m );