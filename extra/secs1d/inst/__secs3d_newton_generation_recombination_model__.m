function [Rn, Rp, Gn, Gp, II] = __secs3d_newton_generation_recombination_model__ ...
                                  (device, material, constants,
                                   algorithm, mobilityn, mobilityp, 
                                   V, n, p)
  
  [Rn_srh, Rp_srh, Gn_srh, Gp_srh] = secs1d_srh_recombination_noscale ...
                                       (device, material, constants, 
                                        algorithm, n, p);

  [Rn_aug, Rp_aug, G_aug] = secs1d_auger_recombination_noscale ...
                              (device, material, constants, 
                               algorithm, n, p);
  
  Rn = Rn_srh + Rn_aug;
  Rp = Rp_srh + Rp_aug;
  
  Gp = Gn = Gn_srh + G_aug;

  Fp = V + constants.Vth * log (p ./ device.ni);
  Fn = V - constants.Vth * log (n ./ device.ni);

  [Ex,Ey,Ez] = bim3c_pde_gradient(device.msh, -V);
  Emag=sqrt(Ex .^ 2 + Ey .^ 2 + Ez .^ 2)(:);

  [Jn, Jp] = __secs3d_newton_compute_currents__ ...
               (device, material, constants, algorithm, 
                mobilityn, mobilityp, V, n, p, Fn, Fp);

  II = secs1d_impact_ionization_noscale ...
         (device, material, constants, algorithm, 
          Emag, Jn.mag, Jp.mag, V, n, p, Fn, Fp);

endfunction
