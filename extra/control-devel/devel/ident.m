function [sys, x0] = ident (dat, nobr)

  %nobr = 15;
  meth = 2;
  alg = 0;
  jobd = 1;
  batch = 3;
  conct = 1;
  ctrl = 1;
  rcond = 0.0;
  tol = -1.0;

  [a, b, c, d, q, ry, s, k, x0] = slident (dat.y{1}, dat.u{1}, nobr, meth, alg, jobd, batch, conct, ctrl, rcond, tol)

  sys = ss (a, b, c, d, -1);

endfunction
