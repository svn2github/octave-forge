function [sys, x0] = ident (dat, s = [], n = [])



  %nobr = 15;
  meth = 2; % 2    % geht: meth/alg  1/1, 
  alg = 0; % 0     % geht nicht: meth/alg  0/1
  conct = 1;
  ctrl = 0; %1;
  rcond = 0.0;
  tol = -1.0; % 0;
  
  [ns, l, m, e] = size (dat);
  
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
  
  %nsmp = ns(1)
  %nobr = fix ((nsmp+1)/(2*(m+l+1)))
  % nsmp >= 2*(m+l+1)*nobr - 1
  % nobr <= (nsmp+1)/(2*(m+l+1))
%nobr = 10
  [a, b, c, d, q, ry, s, k, x0] = slident (dat.y, dat.u, nobr, n, meth, alg, conct, ctrl, rcond, tol);

  sys = ss (a, b, c, d, dat.tsam{1});
  
  if (numel (x0) == 1)
    x0 = x0{1};
  endif

endfunction
