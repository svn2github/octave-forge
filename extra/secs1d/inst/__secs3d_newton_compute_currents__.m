function [Jn, Jp] = __secs3d_newton_compute_currents__ ...
                      (device, material, constants, algorithm, 
                       mobilityn, mobilityp, V, n, p, Fn, Fp)
  
  [Fnx,Fny,Fnz] = bim3c_pde_gradient (device.msh, Fn);
  [Fpx,Fpy,Fpz] = bim3c_pde_gradient (device.msh, Fp);

  nelemental = sum (n(device.msh.t(1:4, :)), 1)(:) / 4;
  pelemental = sum (p(device.msh.t(1:4, :)), 1)(:) / 4;

  tmp  = -constants.q * mobilityn .* nelemental;
  Jn.x = tmp(:) .* Fnx(:);
  Jn.y = tmp(:) .* Fny(:); 
  Jn.z = tmp(:) .* Fnz(:);
 
  Jn.mag = sqrt (Jn.x .^2 + Jn.y .^2 + Jn.z .^2);

  tmp  = -constants.q * mobilityp .* pelemental;
  Jp.x = tmp(:) .* Fpx(:);
  Jp.y = tmp(:) .* Fpy(:);
  Jp.z = tmp(:) .* Fpz(:);

  Jp.mag = sqrt (Jp.x .^2 + Jp.y .^2 + Jp.z .^2);
  
endfunction
