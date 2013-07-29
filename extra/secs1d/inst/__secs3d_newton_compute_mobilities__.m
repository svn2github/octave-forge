function [mobilityn, mobilityp] = __secs3d_newton_compute_mobilities__ ...
                                    (device, material, constants, 
                                     algorithm, V, n, p)
  
  Fp = V + constants.Vth * log (p ./ device.ni);
  Fn = V - constants.Vth * log (n ./ device.ni);
  
  [Ex,Ey,Ez] = bim3c_pde_gradient(device.msh, -V);
  Emag=sqrt(Ex .^ 2 + Ey .^ 2 + Ez .^ 2)(:);
  
  mobilityn = secs1d_mobility_model_noscale ...
                (device, material, constants, algorithm, Emag, 
                 V, n, p, Fn, Fp, 'n');
  
  mobilityp = secs1d_mobility_model_noscale ...
                (device, material, constants, algorithm, Emag, 
                 V, n, p, Fn, Fp, 'p');
  
endfunction
