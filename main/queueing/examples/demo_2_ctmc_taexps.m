 sec = 1;
 min = sec*60;
 hour = 60*min;
 day = 24*hour;

 # state space enumeration {2, RC, RB, 1, 0}
 a = 1/(10*min);    # 1/a = duration of reboot (10 min)
 b = 1/(30*sec);    # 1/b = reconfiguration time (30 sec)
 g = 1/(5000*hour); # 1/g = processor MTTF (5000 hours)
 d = 1/(4*hour);    # 1/d = processor MTTR (4 hours)
 c = 0.9;           # coverage
 Q = [ -2*g 2*c*g 2*(1-c)*g      0  0; \
          0    -b         0      b  0; \
          0     0        -a      a  0; \
          d     0         0 -(g+d)  g; \
          0     0         0      d -d];
 p = ctmc(Q);
 printf("System availability: %f\n",p(1)+p(4));
 TT = linspace(1e-5,1*day,101);
 PP = ctmc_taexps(Q,TT,[1 0 0 0 0]);
 A = At = Abart = zeros(size(TT));
 A(:) = p(1) + p(4); # steady-state availability
 for n=1:length(TT)
   t = TT(n);
   p = ctmc(Q,t,[1 0 0 0 0]);
   At(n) = p(1) + p(4); # instantaneous availability
   Abart(n) = PP(n,1) + PP(n,4); # interval base availability
 endfor
 semilogy(TT,A,";Steady-state;", \
      TT,At,";Instantaneous;", \
      TT,Abart,";Interval base;");
 ax = axis();
 ax(3) = 1-1e-5;
 axis(ax);