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
    ## numel (nb) == size (dat, 3)
  endif

  ## TODO: handle MIMO and multi-experiment data
  [~, p, m, ex] = size (dat);

  Y = dat.y{1};
  U = dat.u{1};
  Ts = dat.tsam{1};
  
  max_nb = max (nb);
  n = max (na, max_nb);

  ## avoid warning: toeplitz: column wins anti-diagonal conflict
  PhiY = toeplitz (Y(1:end-1, :), [Y(1, :); zeros(na-1, 1)]);
  ## PhiU = toeplitz (U(1:end-1, :), [U(1, :); zeros(nb-1, 1)]);
  PhiU = arrayfun (@(x) toeplitz (U(1:end-1, x), [U(1, x); zeros(nb(x)-1, 1)]), 1:m, "uniformoutput", false);
  Phi = horzcat (-PhiY, PhiU{:});
  Phi = Phi(n:end, :)
  
  ## Theta = Phi \ Y(n+1:end, :);             # naive formula
  
  ## solve linear least squares problem by pseudoinverse
  ## the pseudoinverse is computed by singular value decomposition
  ## M = U S V*  --->  M+ = V S+ U*
  ## Th = Ph \ Y = Ph+ Y
  ## Th = V S+ U* Y,   S+ = 1 ./ diag (S)
  
  [U, S, V] = svd (Phi, 0);                 # 0 for "economy size" decomposition, U overwrites input U
  S = diag (S);                             # extract main diagonal
  r = sum (S > eps*S(1));
  V = V(:, 1:r);
  S = S(1:r);
  U = U(:, 1:r);
  Theta = V * (S .\ (U' * Y(n+1:end, :)));  # U' is the conjugate transpose
  
  A = [1; Theta(1:na)];                     # a0 = 1, a1 = Theta(1), an = Theta(n)
  ## B = [0; Theta(na+1:end)];                 # b0 = 0 (leading zero required by filt)
  ThetaB = Theta(na+1:end);
  B = mat2cell (ThetaB, nb);
  B = reshape (B, 1, []);
  B = cellfun (@(x) [0; x], B, "uniformoutput", false);
  
  ## sys = filt ({B, 1}, {A, A}, Ts);
  num = [B, {1}];
  den = repmat ({A}, 1, m+1);
  sys = filt (num, den, Ts);

endfunction