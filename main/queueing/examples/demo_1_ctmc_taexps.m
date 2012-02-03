 lambda = 0.5;
 N = 4;
 birth = lambda*linspace(1,N-1,N-1);
 death = zeros(1,N-1);
 Q = diag(birth,1)+diag(death,-1);
 Q -= diag(sum(Q,2));
 t = linspace(1e-3,50,500);
 p = zeros(1,N); p(1)=1;
 M = ctmc_taexps(Q,t,p);
 plot(t, M(:,1), ";State 1;", "linewidth", 2, \
      t, M(:,2), ";State 2;", "linewidth", 2, \
      t, M(:,3), ";State 3;", "linewidth", 2, \
      t, M(:,4), ";State 4 (absorbing);", "linewidth", 2 );
 legend("location","east");
 xlabel("Time");
 ylabel("Time-averaged Expected sojourn time");