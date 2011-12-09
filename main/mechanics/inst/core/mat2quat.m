function q = mat2quat(R)

  if all(R == eye(3))
    q = [1 0 0 0];
    return
  end
  
  %% Angle
  phi = acos((trace(R)-1)/2);
  
  %% Axis
  x = [R(3,2)-R(2,3) R(1,3)-R(3,1) R(2,1)-R(1,2)];
  x = x/sqrt(sumsq(x));

  q = [ cos(phi/2) sin(phi/2)*x];
  
endfunction
