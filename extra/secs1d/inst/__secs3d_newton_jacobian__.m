function Jacob = __secs3d_newton_jacobian__ ...
                (
                  device,
                  material,
                  constants, 
                  algorithm,
                  V,
                  n,
                  p,
                  F,
                  deltat,
                  A,
                  B,
                  C,
                  r,
                  pins,
                  indexing,
                  dnodes,
                  inodes
                );


  nnodes    = columns (device.msh.p);
  Nelements = columns (device.msh.t);
  alldnodes = setdiff (1:nnodes, inodes);

  Nextvars  = numel(F);
  [mobilityn, mobilityp] = ...
  __secs3d_newton_compute_mobilities__ ...
    (device, material, constants, algorithm, V, n, p);
  
  [Rn, Rp, Gn, Gp, II] = ...
  __secs3d_newton_generation_recombination_model__ ...
    (device, material, constants, algorithm, mobilityn, mobilityp, V, n, p);

  nm = 3 ./ sum(1 ./ n(device.msh.t(1:3, :)),1)(:);
  pm = 3 ./ sum(1 ./ p(device.msh.t(1:3, :)),1)(:);

  epsilon    = material.esi * ones (Nelements, 1);
  
  indexing1 = indexing.V;
  indexing2 = indexing.n; 
  indexing3 = indexing.p;
  indexing4 = indexing.ext; 
  totN = indexing4(end);

  Cscale = algorithm.colscaling;
  Rscale = algorithm.rowscaling;


  A11 = bim3a_osc_laplacian (device.msh, epsilon);
  aaa = diag (A11)(alldnodes); %% scaling for dirichlet nodes

  Fdnodes = (dnodes (:, alldnodes))' * F (pins);
  DV  = (Fdnodes - V(alldnodes)) / constants.Vth;
  pExp = device.ni(alldnodes) .* exp (DV) / constants.Vth;
  nExp = device.ni(alldnodes) .* exp (-DV) / constants.Vth;
  
  JVV = sparse (alldnodes, alldnodes,
                aaa .* (nExp - pExp),
                nnodes, nnodes);

  JVx = -JVV * dnodes'; %% only valid on dirichlet nodes
  JVV(inodes, :) += A11(inodes, :);
  
  JVn = constants.q * bim3a_reaction (device.msh, 1, 1);
  JVn(alldnodes, :) = 0;
 
  
  [iii, jjj, vvv] = find (JVV);
  Jacob{1, 1} = sparse (indexing1(iii), indexing1(jjj), 
                        Cscale(1) * vvv / Rscale(1), 
                        totN, totN);

  [iii, jjj, vvv] = find (JVn);
  Jacob{1, 2} = sparse (indexing1(iii), indexing2(jjj), 
                        Cscale(2) * vvv / Rscale(1), 
                        totN, totN);

  Jacob{1, 3} = sparse (indexing1(iii), indexing3(jjj), 
                       -Cscale(3) * vvv / Rscale(1), 
                       totN, totN);

  [iii, jjj, vvv] = find (JVx);
  Jacob{1, 4} = sparse (indexing1(iii), indexing4(pins(jjj)(:)), 
                        Cscale(4) * vvv / Rscale(1), 
                        totN, totN);
  

  A21 = - bim3a_osc_laplacian ...
            (device.msh, mobilityn .* nm);

  A22 = bim3a_osc_advection_diffusion ...
          (device.msh, mobilityn * constants.Vth,
           V / constants.Vth);
  
  Jnn = A22 + ...
        bim3a_reaction (device.msh, 1, Rn + (1 / deltat));

  aaa = diag (Jnn)(alldnodes); %% scaling for dirichlet nodes

  Jnn(alldnodes, :) = 0;
  Jnn += sparse (alldnodes, alldnodes, aaa, nnodes, nnodes);

  JnV = sparse (alldnodes, alldnodes, %% dirichlet nodes term
                - aaa .* nExp,
                nnodes, nnodes);

  Jnx = -JnV * dnodes'; %%only valid on dirichlet nodes

  JnV(inodes,:) += A21(inodes,:);
  Jnp = bim3a_reaction (device.msh, 1, Rp);
  Jnp(alldnodes, :) = 0; 
  

  [iii, jjj, vvv] = find (JnV);
  Jacob{2, 1} = sparse (indexing2(iii), indexing1(jjj), 
                        Cscale(1) * vvv / Rscale(2), totN, totN);

  [iii, jjj, vvv] = find (Jnn);
  Jacob{2, 2} = sparse (indexing2(iii), indexing2(jjj),
                        Cscale(2) * vvv / Rscale(2), totN, totN);

  [iii, jjj, vvv] = find (Jnp);
  Jacob{2, 3} = sparse (indexing2(iii), indexing3(jjj), 
                        Cscale(3) * vvv / Rscale(2), totN, totN);

  [iii, jjj, vvv] = find (Jnx);
  Jacob{2, 4} = sparse (indexing2(iii), indexing4(pins(jjj)),
                        Cscale(4) * vvv / Rscale(2), totN, totN);


  A31 = bim3a_osc_laplacian (device.msh, mobilityp .* pm);
  A33 = bim3a_osc_advection_diffusion (device.msh, 
                                       mobilityp * constants.Vth, 
                                       - V / constants.Vth);

  Jpp = A33 + bim3a_reaction (device.msh, 1, Rp + (1 / deltat));
  aaa = diag (Jpp)(alldnodes); %% scaling for dirichlet nodes
  Jpp(alldnodes,:) = 0;
  Jpp += sparse (alldnodes, alldnodes, aaa, nnodes, nnodes);
  JpV = sparse (alldnodes, alldnodes, %%dirichlet nodes term
                aaa .* pExp,
                nnodes, nnodes); 
  Jpx = -JpV * dnodes'; %%only valid on dirichlet nodes

  JpV(inodes,:) += A31(inodes,:);
  Jpn = bim3a_reaction (device.msh, 1, Rn);
  Jpn(alldnodes, :) = 0;


  [iii, jjj, vvv] = find (JpV);

  Jacob{3, 1} = sparse (indexing3(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(3), totN, totN);

  [iii, jjj, vvv] = find (Jpn);
  Jacob{3, 2} = sparse (indexing3(iii), indexing2(jjj), 
                       Cscale(2) * vvv / Rscale(3), totN, totN);

  [iii, jjj, vvv] = find (Jpp);
  Jacob{3, 3} = sparse (indexing3(iii), indexing3(jjj), 
                       Cscale(3) * vvv / Rscale(3), totN, totN);

  [iii, jjj, vvv] = find (Jpx);
  Jacob{3, 4} = sparse (indexing3(iii), indexing4(pins(jjj)), 
                       Cscale(4) * vvv / Rscale(3), totN, totN);

  JxV = r * dnodes * (A11 / deltat + constants.q * (- A21 + A31));

  Jxn = r * dnodes * (-constants.q) * A22;

  Jxp = r * dnodes * constants.q * A33;

  Jxx = (A / deltat) + B;


  [iii, jjj, vvv]  = find (JxV);
  Jacob{4, 1} = sparse(indexing4(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(4), totN, totN);

  [iii, jjj, vvv] = find(Jxn);
  Jacob{4, 2} = sparse(indexing4(iii), indexing2(jjj), 
                       Cscale(2) * vvv / Rscale(4), totN, totN);

  [iii, jjj, vvv] = find(Jxp);
  Jacob{4, 3} = sparse(indexing4(iii), indexing3(jjj), 
                       Cscale(3) * vvv / Rscale(4), totN, totN);

  [iii, jjj, vvv] = find(Jxx);
  Jacob{4, 4} = sparse(indexing4(iii), indexing4(jjj), 
                       Cscale(4) * vvv / Rscale(4), totN, totN);

endfunction
