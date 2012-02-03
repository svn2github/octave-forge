 mu = 0.01;
 death = [ 3 4 5 ] * mu;
 Q = diag(death,-1);
 Q -= diag(sum(Q,2));
 t = ctmc_mtta(Q,[0 0 0 1])