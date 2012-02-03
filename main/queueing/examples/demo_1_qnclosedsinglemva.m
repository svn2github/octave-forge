 S = [ 0.125 0.3 0.2 ];
 V = [ 16 10 5 ];
 N = 20;
 m = ones(1,3);
 Z = 4;
 [U R Q X] = qnclosedsinglemva(N,S,V,m,Z);
 X_s = X(1)/V(1); # System throughput
 R_s = dot(R,V); # System response time
 printf("\t    Util      Qlen     RespT      Tput\n");
 printf("\t--------  --------  --------  --------\n");
 for k=1:length(S)
   printf("Dev%d\t%8.4f  %8.4f  %8.4f  %8.4f\n", k, U(k), Q(k), R(k), X(k) );
 endfor
 printf("\nSystem\t          %8.4f  %8.4f  %8.4f\n\n", N-X_s*Z, R_s, X_s );