## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2012
## Version: 0.1

function sys = arx (dat, na, nb)

  if (nargin != 3)
    print_usage ();
  endif
  
  if (! isa (dat, "iddata"))
    error ("arx: ");
  endif
  
  if (! is_real_scalar (na, nb))
    error ("arx: ");
    ## Test for integers
  endif

  ## TODO: handle MIMO and multi-experiment data

  Y = dat.y{1};
  U = dat.u{1};
  Ts = dat.tsam{1};

  ## avoid warning: toeplitz: column wins anti-diagonal conflict
  PhiY = toeplitz (Y(1:end-1, :), [Y(1, :); zeros(na-1, 1)]);
  PhiU = toeplitz (U(1:end-1, :), [U(1, :); zeros(nb-1, 1)]);
  Phi = [-PhiY, PhiU];
  
  Theta = Phi \ Y(2:end, :);
  
  A = [1; Theta(1:na)];     # a0 = 1, a1 = Theta(1), an = Theta(n)
  B = Theta(na+1:end);      # b0 = 0 (leading zeros are removed by tf, no need to add one)
  
  sys = tf ({B, 1}, {A, A}, Ts);

endfunction