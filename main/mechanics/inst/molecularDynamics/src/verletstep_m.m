function [P V F] = verletstep_m(P, V, M, dt, force)

  [Npart Ndims] = size(P);
  PP = repmat(P,1,Npart);
  VV = repmat(V,1,Npart);
  MM = repmat(M,1,Ndims);
  
  [F1 F2] = arrayfun (force, PP, PP', VV, VV');
  F = sum (triu (F1, 1) + triu (F2, 1).', 2) ./ MM;

  
  V = V + F * dt/2;
  P = P + V * dt;
  
  PP = repmat(P,1,Npart);
  VV = repmat(V,1,Npart);

  [F1 F2] = arrayfun (force, PP, PP', VV, VV');
  F = sum (triu (F1, 1) + triu (F2, 1).', 2) ./ MM;

  V = V + F * dt/2;

end
