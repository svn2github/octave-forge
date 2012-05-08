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
  
##  if (! is_real_scalar (na, nb))
  if (! is_real_vector (na, nb))
    error ("arx: ");
    ## Test for integers
    ## numel (nb) == size (dat, 3)
  endif

  ## TODO: handle MIMO and multi-experiment data
  [~, p, m, ex] = size (dat);

  Y = dat.y;
  U = dat.u;
  Ts = dat.tsam{1};
  
  max_nb = max (nb);
  n = max (na, max_nb);


  num = cell (p, m+1);
  den = cell (p, m+1);
  
  for i = 1 : p     # for every output
    Phi = cell (1, ex);
    for e = 1 : ex      # for every experiment  
      ## avoid warning: toeplitz: column wins anti-diagonal conflict
      ## therefore set first row element equal to y(1)
      PhiY = toeplitz (Y{e}(1:end-1, i), [Y{e}(1, i); zeros(na-1, 1)]); % TODO: multiple na
      PhiU = arrayfun (@(x) toeplitz (U{e}(1:end-1, x), [U{e}(1, x); zeros(nb(x)-1, 1)]), 1:m, "uniformoutput", false);
      Phi{e} = (horzcat (-PhiY, PhiU{:}))(n:end, :);
    endfor
  
    Theta = __theta__ (Phi, Y, i, n);
      
    A = [1; Theta(1:na)];                     # a0 = 1, a1 = Theta(1), an = Theta(n)
    ThetaB = Theta(na+1:end);                 # b0 = 0 (leading zero required by filt)
    B = mat2cell (ThetaB, nb);
    B = reshape (B, 1, []);
    B = cellfun (@(x) [0; x], B, "uniformoutput", false);

    num(i, :) = [B, {1}];
    den(i, :) = repmat ({A}, 1, m+1);
  endfor

  sys = filt (num, den, Ts);

endfunction


function theta = __theta__ (phi, y, i, n)
                                                
  ## Theta = Phi \ Y(n+1:end, :);                   # naive formula
  
  ex = numel (phi);                                 # number of experiments
  
  if (ex == 1)
    ## single-experiment dataset
    
    ## solve linear least squares problem by pseudoinverse
    ## the pseudoinverse is computed by singular value decomposition
    ## M = U S V*  --->  M+ = V S+ U*
    ## Th = Ph \ Y = Ph+ Y
    ## Th = V S+ U* Y,   S+ = 1 ./ diag (S)

    [U, S, V] = svd (phi{1}, 0);                    # 0 for "economy size" decomposition, U overwrites input U
    S = diag (S);                                   # extract main diagonal
    r = sum (S > eps*S(1));
    V = V(:, 1:r);
    S = S(1:r);
    U = U(:, 1:r);
    theta = V * (S .\ (U' * y{1}(n+1:end, i)));     # U' is the conjugate transpose
  else
    ## multi-experiment dataset
    ## TODO: find more sophisticated formula than
    ## Theta = (Phi1' Phi + Phi2' Phi2 + ...) \ (Phi1' Y1 + Phi2' Y2 + ...)
    
    ## covariance matrix C = (Phi1' Phi + Phi2' Phi2 + ...)
    tmp = cellfun (@(Phi) Phi.' * Phi, phi, "uniformoutput", false);
    C = plus (tmp{:});
    
    ## PhiTY = (Phi1' Y1 + Phi2' Y2 + ...)
    tmp = cellfun (@(Phi, Y) Phi.' * Y(n+1:end, i), phi, y, "uniformoutput", false);
    PhiTY = plus (tmp{:});
    
    ## pseudoinverse  Theta = C \ Phi'Y
    theta = C \ PhiTY;
  endif
  
endfunction

%{
function Phi = __phi__ (dat, na, nb, ex)

  ## avoid warning: toeplitz: column wins anti-diagonal conflict
  ## therefore set first row element equal to y(1)
  PhiY = toeplitz (Y(1:end-1, :), [Y(1, :); zeros(na-1, 1)]);
  
  ## PhiU = toeplitz (U(1:end-1, :), [U(1, :); zeros(nb-1, 1)]);
  PhiU = arrayfun (@(x) toeplitz (U(1:end-1, x), [U(1, x); zeros(nb(x)-1, 1)]), 1:m, "uniformoutput", false);
  Phi = horzcat (-PhiY, PhiU{:});
  Phi = Phi(n:end, :);

endfunction
%}