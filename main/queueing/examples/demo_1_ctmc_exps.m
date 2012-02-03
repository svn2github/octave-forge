 lambda = 0.5;
 N = 4;
 birth = lambda*linspace(1,N-1,N-1);
 death = zeros(1,N-1);
 Q = diag(birth,1)+diag(death,-1);
 Q -= diag(sum(Q,2));
 tt = linspace(0,10,100);
 p0 = zeros(1,N); p0(1)=1;
 L = ctmc_exps(Q,tt,p0);
 plot( tt, L(:,1), ";State 1;", "linewidth", 2, \
       tt, L(:,2), ";State 2;", "linewidth", 2, \
       tt, L(:,3), ";State 3;", "linewidth", 2, \
       tt, L(:,4), ";State 4 (absorbing);", "linewidth", 2);
 legend("location","northwest");
 xlabel("Time");
 ylabel("Expected sojourn time");