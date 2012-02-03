 S = [ 0.125 0.3 0.2 ];
 V = [ 16 10 5 ];
 N = 30;
 m = ones(1,3);
 Z = 4;
 Xmva = Xapp = Rmva = Rapp = zeros(1,N);
 for n=1:N
   [U R Q X] = qnclosedsinglemva(n,S,V,m,Z);
   Xmva(n) = X(1)/V(1);
   Rmva(n) = dot(R,V);
   [U R Q X] = qnclosedsinglemvaapprox(n,S,V,m,Z);
   Xapp(n) = X(1)/V(1);
   Rapp(n) = dot(R,V);
 endfor
 subplot(2,1,1);
 plot(1:N, Xmva, ";Exact;", "linewidth", 2, 1:N, Xapp, "x;Approximate;", "markersize", 7);
 legend("location","southeast");
 ylabel("Throughput X(n)");
 subplot(2,1,2);
 plot(1:N, Rmva, ";Exact;", "linewidth", 2, 1:N, Rapp, "x;Approximate;", "markersize", 7);
 legend("location","southeast");
 ylabel("Response Time R(n)");
 xlabel("Number of Requests n");