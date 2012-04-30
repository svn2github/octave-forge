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

  PhiY = toeplitz (Y(1:end-1, :), zeros (1, na));
  PhiU = toeplitz (U(1:end-1, :), zeros (1, nb));
  Phi = [-PhiY, PhiU]
  
  Theta = Phi \ Y(2:end, :);
  
  A = [1; Theta(1:na)];     % ???
  B = Theta(na+1:end);
  
  sys = tf ({B, 1}, {A, A}, Ts);

endfunction