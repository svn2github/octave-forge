function [vv, theta] = q2rot (q)

  if (nargin ~= 1 || nargout ~= 2)
    print_usage ();
  end

  if (abs (norm (q) - 1) > 1e-12)
    warning ('quaternion: ||q||=%e, setting=1 for vv, theta', norm (q));
    q = q / norm (q);
  end

  s = q.s;
  x = q.x;
  y = q.y;
  z = q.z;

  theta = acos (s) * 2;

  if (abs (theta) > pi)
    theta = theta - sign (theta) * pi;
  end

  sin_th_2 = norm ([x, y, z]);

  if (sin_th_2 ~= 0)
    vv = [x, y, z] / sin_th_2;
  else
    vv = [x, y, z];
  end

end