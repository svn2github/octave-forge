function [sysr, nr] = hnamodred (sys, varargin)

  if (nargin == 0)
    print_usage ();
  endif
  
  if (! isa (sys, "lti"))
    error ("hnamodred: first argument must be an LTI system");
  endif
  
  [a, b, c, d, tsam, scaled] = ssdata (sys);
  dt = isdt (sys);
  
  ## default arguments
  av = bv = cv = dv = [];
  jobv = 0;
  aw = bw = cw = dw = [];
  jobw = 0;
  jobinv = 2;
  tol1 = 1e-1; 
  tol2 = 1e-14;
  alpha = 0.0;
  ordsel = 1;
  nr = 0

  for k = 1 : 2 : (nargin-1)
    prop = lower (varargin{k});
    val = varargin{k+1};
    switch (prop)
      case {"left", "v"}
        val = ss (val);  # val could be non-lti, therefore ssdata would fail
        [av, bv, cv, dv, tsamv] = ssdata (val);
        jobv = 1;

      case {"right", "w"}
        val = ss (val);
        [aw, bw, cw, dw, tsamw] = ssdata (val);
        jobw = 1;
        ## TODO: check ct/dt

      case {"order", "n", "nr"}
        if (! issample (val, 0) || val != round (val))
          error ("hnamodred: argument %s must be an integer >= 0", varargin{k});
        endif
        nr = val;
        ordsel = 0;

      case "tol1"
        if (! is_real_scalar (val))
          error ("hnamodred: argument %s must be a real scalar", varargin{k});
        endif
        tol1 = val;

      case "tol2"
        if (! is_real_scalar (val))
          error ("hnamodred: argument %s must be a real scalar", varargin{k});
        endif
        tol2 = val;

      case "alpha"
        if (! is_real_scalar (val))
          error ("hnamodred: argument %s must be a real scalar", varargin{k});
        endif
        if (dt)  # discrete-time
          if (val < 0 || val > 1)
            error ("hnamodred: argument %s must be 0 <= ALPHA <= 1", varargin{k});
          endif
        else     # continuous-time
          if (val > 0)
            error ("hnamodred: argument %s must be ALPHA <= 0", varargin{k});
          endif
        endif
        alpha = val;


      otherwise
        error ("hnamodred: invalid property name");
    endswitch
  endfor
  


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

