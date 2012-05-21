function [sys, x0] = __slicot_identification__ (method, dat, n = [])

  switch (method)
    case "moesp"
      meth = 0;
    case "n4sid"
      meth = 1;
    case "moen4"
      meth = 2;
    otherwise
      error ("ident: invalid method");  # should never happen
  endswitch
  
  if (! isa (dat, "iddata"))
    error ("%s: first argument must be an 'iddata' dataset", method);
  endif

  ## default arguments
  alg = 0;
  conct = 1;    # no connection between experiments
  ctrl = 1;     # don't confirm order n
  rcond = 0.0;
  tol = -1.0; % 0;
  
  [ns, l, m, e] = size (dat);
  
  s = min (2*n, n+10);                  # upper bound for n
  nsmp = sum (ns);                      # total number of samples
  nobr = fix ((nsmp+1)/(2*(m+l+1)));
  if (e > 1)
    nobr = min (nobr, fix (min (ns) / 2));
  endif
  nobr = min (nobr, s)

%{
  
  if (isempty (s) && isempty (n))
    nsmp = ns(1);
    nobr = fix ((nsmp+1)/(2*(m+l+1)));
    ctrl = 0;  # confirm system order estimate
    n = 0;
    % nsmp >= 2*(m+l+1)*nobr - 1
    % nobr <= (nsmp+1)/(2*(m+l+1))
  elseif (isempty (s))
    s = min (2*n, n+10);
    nsmp = ns(1);
    nobr = fix ((nsmp+1)/(2*(m+l+1)));
    nobr = min (nobr, s);
    ctrl = 1;  # no confirmation
  elseif (isempty (n))
    nobr = s;
    ctrl = 0;  # confirm system order estimate
    n = 0;
  else         # s & n non-empty
    nsmp = ns(1);
    nobr = fix ((nsmp+1)/(2*(m+l+1)));
    if (s > nobr)
      error ("ident: s > nobr");
    endif
    nobr = s;
    ctrl = 1;
    ## TODO: specify n for IB01BD
  endif
%}
  
  [a, b, c, d, q, ry, s, k, x0] = slident (dat.y, dat.u, nobr, n, meth, alg, conct, ctrl, rcond, tol);

  sys = ss (a, b, c, d, dat.tsam{1});

  if (numel (x0) == 1)
    x0 = x0{1};
  endif

endfunction
