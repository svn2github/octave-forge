function [sysr, nr] = hnamodred (sys, nr = 0, sysv = [], sysw = [])

  [a, b, c, d, tsam, scaled] = ssdata (sys);
  dt = isdt (sys);
  
  if (isempty (sysv))
    av = bv = cv = dv = [];
    jobv = 0;
  else
    sysv = ss (sysv);
    [av, bv, cv, dv] = ssdata (sysv);
    jobv = 1;
  endif

  if (isempty (sysw))
    aw = bw = cw = dw = [];
    jobw = 0;
  else
    sysw = ss (sysw);
    [aw, bw, cw, dw] = ssdata (sysw);
    jobw = 1;
  endif

  jobinv = 2;
  tol1 = 1e-1; 
  tol2 = 1e-14;
  alpha = 0.0;
  ordsel = 1;

  [ar, br, cr, dr, nr] = slab09jd (a, b, c, d, dt, scaled, nr, ordsel, alpha, \
                                   jobv, av, bv, cv, dv, \
                                   jobw, aw, bw, cw, dw, \
                                   jobinv, tol1, tol2);

  sysr = ss (ar, br, cr, dr, tsam);

endfunction


%!shared Mo, Me
%! a =  [ -3.8637   -7.4641   -9.1416   -7.4641   -3.8637   -1.0000
%!         1.0000,         0         0         0         0         0
%!              0    1.0000         0         0         0         0
%!              0         0    1.0000         0         0         0
%!              0         0         0    1.0000         0         0
%!              0         0         0         0    1.0000         0 ];
%!
%! b =  [       1
%!              0
%!              0
%!              0
%!              0
%!              0 ];
%!
%! c =  [       0         0         0         0         0         1 ];
%!
%! d =  [       0 ];
%!
%! sys = ss (a, b, c, d);
%!
%! av = [  0.2000   -1.0000
%!         1.0000         0 ];
%!
%! bv = [       1
%!              0 ];
%!
%! cv = [ -1.8000         0 ];
%!
%! dv = [       1 ];
%!
%! sysv = ss (av, bv, cv, dv);
%!
%! sysr = hnamodred (sys, 0, sysv, []);
%! [ao, bo, co, do] = ssdata (sysr);
%!
%! ae = [ -0.2391   0.3072   1.1630   1.1967
%!        -2.9709  -0.2391   2.6270   3.1027
%!         0.0000   0.0000  -0.5137  -1.2842
%!         0.0000   0.0000   0.1519  -0.5137 ];
%!
%! be = [ -1.0497
%!        -3.7052
%!         0.8223
%!         0.7435 ];
%!
%! ce = [ -0.4466   0.0143  -0.4780  -0.2013 ];
%!
%! de = [  0.0219 ];
%!
%! Mo = [ao, bo; co, do];
%! Me = [ae, be; ce, de];
%!
%!assert (Mo, Me, 1e-4);

