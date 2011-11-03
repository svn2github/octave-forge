function q = rot2q (vv, theta)

  if (nargin ~= 2 || nargout ~= 1)
    print_usage ();
  end

  if (~ isvector (vv) || length (vv) ~= 3)
    error ('vv must be a length three vector');
  end

  if (~ isscalar (theta))
    error ('theta must be a scalar');
  end

  if (norm (vv) == 0)
    error ('quaternion: vv is zero');
  end

  if (abs (norm (vv) - 1) > 1e-12)
    warning ('quaternion: ||vv|| != 1, normalizing')
    vv = vv / norm (vv);
  end

  if (abs (theta) > 2*pi)
    warning ('quaternion: |theta| > 2 pi, normalizing')
    theta = rem (theta, 2*pi);
  end

  vv = vv * sin (theta / 2);
  d = cos (theta / 2);
  q = quaternion (d, vv(1), vv(2), vv(3));

end