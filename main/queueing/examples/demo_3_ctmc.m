 sec  = 1;
 min  = 60*sec;
 hour = 60*min;
 day  = 24*hour;
 year = 365*day;
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
 A = p(1) + p(4); 
 printf("System availability   %9.2f min/year\n",A*year/min);
 printf("Mean time in RB state %9.2f min/year\n",p(3)*year/min);
 printf("Mean time in RC state %9.2f min/year\n",p(2)*year/min);
 printf("Mean time in 0 state  %9.2f min/year\n",p(5)*year/min);
 Q(3,:) = Q(5,:) = 0; # make states 3 and 5 absorbing
 p0 = [1 0 0 0 0];
 MTBF = ctmc_mtta(Q, p0) / hour;
 printf("System MTBF %.2f hours\n",MTBF);