function res_full = __secs3d_newton_residual__ ...
                      (device, material, constants, 
                       algorithm, V, n, p, F, 
                       V0, n0, p0, F0, deltat, 
                       A, B, C, r, pins,
                       indexing, dnodes, inodes);
  
  nnodes    = columns (device.msh.p);
  Nelements = columns (device.msh.t);
  Nextvars  = numel(F);

  indexing1 = indexing.V;
  indexing2 = indexing.n; 
  indexing3 = indexing.p;
  indexing4 = indexing.ext; 
  totN = indexing4(end);
  
  [mobilityn, mobilityp] = compute_mobilities ...
                           (device, material, constants, 
                            algorithm, V, n, p);  
  
  [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
                           (device, material, constants, 
                            algorithm, mobilityn, mobilityp, 
                            V, n, p);
  
  epsilon = material.esi * ones (Nelements, 1);
  
  A11 = bim3a_osc_laplacian (device.msh, epsilon);
  res1  = A11 * V;
  res1 += bim3a_rhs (device.msh, 1, constants.q * (n - p - device.D));

  A22 = bim3a_osc_advection_diffusion ...
          (device.msh, mobilityn * constants.Vth, V / constants.Vth);
  res2 = A22 * n;
  res2 += bim3a_rhs (device.msh, 1, 
                     (Rn  + 1/deltat) .* n - (Gn + n0 * 1/ deltat));

  A33 = bim3a_osc_advection_diffusion ...
          (device.msh, mobilityp * constants.Vth, - V / constants.Vth);
  res3  = A33 * p;
  res3 += bim3a_rhs (device.msh, 1, (Rp + 1/deltat) .* p - 
                                  (Gp + p0 * 1/ deltat));
  for iii = 1 : numel(pins)
    thisdnodes = find(dnodes(iii,:));
    res1(thisdnodes) = diag(A11(thisdnodes,thisdnodes)) .* ...
            (V(thisdnodes) + 
             constants.Vth * log (p(thisdnodes) ./ device.ni(thisdnodes)) -
             F(pins(iii)));
    res2(thisdnodes) = diag(A22(thisdnodes,thisdnodes)) .* ...
            (n(thisdnodes) - n0(thisdnodes));
    res3(thisdnodes) = diag(A33(thisdnodes,thisdnodes)) .* ...
            (p(thisdnodes) - p0(thisdnodes));
    Jn(iii) = sum(-constants.q * A22(thisdnodes,:) * n);
    Jp(iii) = sum(constants.q * A33(thisdnodes, :) * p);
    Jd(iii) = sum(A11(thisdnodes, :) * ((V-V0) / deltat));
  endfor

  Jtot = Jn + Jp + Jd;

  circuit_scaling = eye(size(A));
  res4 = ((A * (F - F0)) / deltat ...
         + B * F ...
         + C ...
         + r * Jtot(:));
  res4 = circuit_scaling * res4;

  res_full = zeros(totN, 1);
  res_full(indexing1) = res1 / algorithm.rowscaling(1);
  res_full(indexing2) = res2 / algorithm.rowscaling(2);
  res_full(indexing3) = res3 / algorithm.rowscaling(3);
  res_full(indexing4) = res4 / algorithm.rowscaling(4);

endfunction
