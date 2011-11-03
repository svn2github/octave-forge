q = rot2q ([0, 0, 1], pi/4)

% [vv, theta] = q2rot (q)

x = quaternion (0, 1, 1, 0)  % nicht normiert
              % s  x  y  z

rx = q * x * conj (q)  % q x q^-1

% [vv, theta] = q2rot (rx)
