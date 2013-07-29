function Jacob = __secs3d_newton_jacobian__ ...
                   (device, material, constants, 
                    algorithm, V, n, p, F, 
                    deltat, A, B, C, r, pins,
                    indexing, dnodes, inodes);

  nnodes    = columns (device.msh.p);
  Nelements = columns (device.msh.t);
  alldnodes = setdiff (1:nnodes, inodes);

  Nextvars  = numel(F);
  [mobilityn, mobilityp] = ...
  compute_mobilities (device, material, constants, algorithm, V, n, p);
  
  [Rn, Rp, Gn, Gp, II] = ...
  generation_recombination_model (device, material, constants, algorithm, 
                                  mobilityn, mobilityp, V, n, p);

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
  aaa = diag(A11);
  JVV = sparse(alldnodes,alldnodes,aaa(alldnodes),nnodes,nnodes);
  JVV(inodes,:) += A11(inodes,:);
  
  [iii, jjj, vvv] = find (JVV);
  Jacob{1, 1} = sparse(indexing1(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(1), totN, totN);

  JVn = constants.q * bim3a_reaction (device.msh, 1, 1);
  JVn(alldnodes, :) = 0;
  [iii, jjj, vvv] = find (JVn);
  Jacob{1, 2} = sparse(indexing1(iii), indexing2(jjj), 
                       Cscale(2) * vvv / Rscale(1), totN, totN);

  Jacob{1, 3} = sparse(indexing1(iii), indexing3(jjj), 
                       -Cscale(3) * vvv / Rscale(1), totN, totN);
  
  Jacob{1, 4} = sparse (totN, totN);
  Jacob{1, 4}(indexing1, indexing4(pins)) += ... 
              Cscale(4) * (-diag(aaa) * dnodes') / Rscale(1);
  
  A21 = - bim3a_osc_laplacian (device.msh, mobilityn .* nm);
  JnV = A21; JnV(alldnodes,:) = 0;
  [iii, jjj, vvv] = find (JnV);
  Jacob{2, 1} = sparse(indexing2(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(2), totN, totN);

  A22 = bim3a_osc_advection_diffusion (device.msh, mobilityn * constants.Vth, 
                                   V / constants.Vth);
  
  Jnn = A22 + bim3a_reaction (device.msh, 1, Rn + (1 / deltat));
  aaa = diag(Jnn);
  Jnn(alldnodes,:) = 0;
  Jnn += sparse(alldnodes,alldnodes,aaa(alldnodes),nnodes,nnodes);
  [iii, jjj, vvv] = find (Jnn);
  Jacob{2, 2} = sparse(indexing2(iii), indexing2(jjj),
                       Cscale(2) * vvv / Rscale(2), totN, totN);
  
  Jnp = bim3a_reaction (device.msh, 1, Rp);
  Jnp(alldnodes, :) = 0; 
  [iii, jjj, vvv] = find (Jnp);
  Jacob{2, 3} = sparse(indexing2(iii), indexing3(jjj), 
                       Cscale(3) * vvv / Rscale(2), totN, totN);
  
  Jacob{2, 4} = sparse (totN, totN);

  A31 = bim3a_osc_laplacian (device.msh, mobilityp .* pm);
  JpV = A31; JpV(alldnodes,:) = 0;
  [iii, jjj, vvv] = find (JpV);
  Jacob{3, 1} = sparse(indexing3(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(3), totN, totN);

  Jpn = bim3a_reaction (device.msh, 1, Rn);
  Jpn(alldnodes, :) = 0;
  [iii, jjj, vvv] = find (Jpn);
  Jacob{3, 2} = sparse(indexing3(iii), indexing2(jjj), 
                       Cscale(2) * vvv / Rscale(3), totN, totN);


  A33 = bim3a_osc_advection_diffusion (device.msh, mobilityp * constants.Vth, 
                                   - V / constants.Vth);
  
  Jpp = A33 + bim3a_reaction (device.msh, 1, Rp + (1 / deltat));
  aaa = diag(Jpp);
  Jpp(alldnodes,:) = 0;
  Jpp += sparse(alldnodes,alldnodes,aaa(alldnodes),nnodes,nnodes);
  [iii, jjj, vvv] = find (Jpp);
  Jacob{3, 3} = sparse(indexing3(iii), indexing3(jjj), 
                       Cscale(3) * vvv / Rscale(3), totN, totN);

  Jacob{3, 4} = sparse (totN, totN);

  circuit_scaling = eye(size(A));

  JxV = sparse (circuit_scaling * r * dnodes * ...
        (A11 + constants.q * (- A21 + A31)));
        %(A11(alldnodes, :) + constants.q * (- A21(alldnodes, :) + A31(alldnodes, :))));
  [iii, jjj, vvv]  = find (JxV);
  Jacob{4, 1} = sparse(indexing4(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(4), totN, totN);

  Jxn = sparse (circuit_scaling * r * dnodes * 
                (-constants.q) * A22);
                %(-constants.q) * A22(alldnodes, :));
  [iii, jjj, vvv] = find(Jxn);
  Jacob{4, 2} = sparse(indexing4(iii), indexing2(jjj), 
                       Cscale(2) * vvv / Rscale(4), totN, totN);
  
  Jxp = sparse (circuit_scaling * r * dnodes *
                   constants.q * A33);
                   %constants.q * A33(alldnodes, :));
  [iii, jjj, vvv] = find(Jxp);
  Jacob{4, 3} = sparse(indexing4(iii), indexing3(jjj), 
                       Cscale(3) * vvv / Rscale(4), totN, totN);
  
  Jxx =   sparse (circuit_scaling * (A / deltat) + B);
  [iii, jjj, vvv] = find(Jxx);
  Jacob{4, 4} = sparse(indexing4(iii), indexing4(jjj), 
                       Cscale(4) * vvv / Rscale(4), totN, totN);

endfunction
