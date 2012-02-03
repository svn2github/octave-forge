 a = 0.2;
 b = 0.15;
 Q = [ -a a; b -b];
 T = linspace(0,14,50);
 pp = zeros(2,length(T));
 for i=1:length(T)
   pp(:,i) = ctmc(Q,T(i),[1 0]);
 endfor
 ss = ctmc(Q); # compute steady state probabilities
 plot( T, pp(1,:), "b;p_0(t);", "linewidth", 2, \
       T, ss(1)*ones(size(T)), "b;Steady State;", \
       T, pp(2,:), "r;p_1(t);", "linewidth", 2, \
       T, ss(2)*ones(size(T)), "r;Steady State;" );
 xlabel("Time");