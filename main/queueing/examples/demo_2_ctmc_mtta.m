 N = 100;
 birth = death = ones(1,N-1); birth(1) = death(N-1) = 0;
 Q = diag(birth,1)+diag(death,-1); 
 Q -= diag(sum(Q,2));
 t = zeros(1,N/2);
 initial_state = 1:(N/2);
 for i=initial_state
   p = zeros(1,N); p(i) = 1;
   t(i) = ctmc_mtta(Q,p);
 endfor
 plot(initial_state,t,"+");
 xlabel("Initial state");
 ylabel("MTTA");