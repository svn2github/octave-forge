 P = [0 0.3 0.7; 1 0 0; 1 0 0]; # Transition probability matrix
 S = [1 0.6 0.2]; # Average service times
 m = ones(1,3); # All centers are single-server
 Z = 2; # External delay
 N = 15; # Maximum population to consider

 V = qnvisits(P); # Compute number of visits from P
 D = V .* S; # Compute service demand from S and V
 X_bsb_lower = X_bsb_upper = zeros(1,N);
 X_ab_lower = X_ab_upper = zeros(1,N);
 X_mva = zeros(1,N);
 for n=1:N
   [X_bsb_lower(n) X_bsb_upper(n)] = qnclosedbsb(n, D, Z);
   [X_ab_lower(n) X_ab_upper(n)] = qnclosedab(n, D, Z);
   [U R Q X] = qnclosed( n, S, V, m, Z );
   X_mva(n) = X(1)/V(1);
 endfor
 close all;
 plot(1:N, X_ab_lower,"g;Asymptotic Bounds;", \
      1:N, X_bsb_lower,"k;Balanced System Bounds;", \
      1:N, X_mva,"b;MVA;", "linewidth", 2, \
      1:N, X_bsb_upper,"k", \
      1:N, X_ab_upper,"g" );
 axis([1,N,0,1]);
 xlabel("Number of Requests n");
 ylabel("System Throughput X(n)");
 legend("location","southeast");