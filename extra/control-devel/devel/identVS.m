function [sys, x0] = identVS (dat, s = [], nn = [])

n=nn;

  %nobr = 15;
  meth = 3-1; %1-1;
  alg = 1-1;
  jobd = 2-1;
  batch = 4-1;
  conct = 2-1;
  %ctrl = 0;
  rcond = 0.0;
  tol = -1.0;
  
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

nobr  
  %nsmp = ns(1)
  %nobr = fix ((nsmp+1)/(2*(m+l+1)))
  % nsmp >= 2*(m+l+1)*nobr - 1
  % nobr <= (nsmp+1)/(2*(m+l+1))
%nobr = 10
  [r, sv, n] = slident_a (dat.y{1}, dat.u{1}, nobr, n, meth, alg, jobd, batch, conct, ctrl, rcond, tol);

%r
sv

n
n = nn;
  [a, b, c, d, q, ry, s, k] = slident_b (dat.y{1}, dat.u{1}, nobr, n, meth, alg, jobd, batch, conct, ctrl, rcond, tol, \
                                         r, sv, n);

  x0 = slident_c (dat.y{1}, dat.u{1}, nobr, n, meth, alg, jobd, batch, conct, ctrl, rcond, tol, \
                    a, b, c, d);

  sys = ss (a, b, c, d, -1);

endfunction
