 Ntot = 100; # total population size
 b = linspace(0.1,0.9,10); # fractions of class-1 requests
 S = [20 80 31 14 23 12; \
      90 30 33 20 14 7];
 V = ones(size(S));
 X1 = X1 = XX = zeros(size(b));
 R1 = R2 = RR = zeros(size(b));
 for i=1:length(b)
   N = [fix(b(i)*Ntot) Ntot-fix(b(i)*Ntot)];
   # printf("[%3d %3d]\n", N(1), N(2) );
   [U R Q X] = qnclosedmultimva( N, S, V );
   X1(i) = X(1,1) / V(1,1);
   X2(i) = X(2,1) / V(2,1);
   XX(i) = X1(i) + X2(i);
   R1(i) = dot(R(1,:), V(1,:));
   R2(i) = dot(R(2,:), V(2,:));
   RR(i) = Ntot / XX(i);
 endfor
 subplot(2,1,1);
 plot(b, X1, "linewidth", 2, \
      b, X2, "linewidth", 2, \
      b, XX, "linewidth", 2 );
 legend("location","south");
 ylabel("Throughput");
 subplot(2,1,2);
 plot(b, R1, ";Class 1;", "linewidth", 2, \
      b, R2, ";Class 2;", "linewidth", 2, \
      b, RR, ";System;", "linewidth", 2 );
 legend("location","south");
 xlabel("Population mix \\beta for Class 1");
 ylabel("Resp. Time");