function [sys, x0] = ident (dat, nobr)

  %nobr = 15;
  meth = 2;
  alg = 0;
  jobd = 1;
  batch = 3;
  conct = 1;
  ctrl = 0; %1;
  rcond = 0.0;
  tol = -1.0;
  
  [n, l, m, e] = size (dat);
  
  nsmp = n(1)
  nobr = fix ((nsmp+1)/(2*(m+l+1)))
  % nsmp >= 2*(m+l+1)*nobr - 1
  % nobr <= (nsmp+1)/(2*(m+l+1))
%nobr = 10
  [a, b, c, d, q, ry, s, k, x0] = slident (dat.y{1}, dat.u{1}, nobr, meth, alg, jobd, batch, conct, ctrl, rcond, tol);

  sys = ss (a, b, c, d, -1);

endfunction
