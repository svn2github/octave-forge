## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2012
## Version: 0.1

function sys = arx (dat, na, nb)

  if (nargin != 3)
    print_usage ();
  endif
  
  if (! isa (dat, "iddata"))
    error ("arx: first argument must be an iddata dataset");
  endif

  ## p: outputs,  m: inputs,  ex: experiments
  [~, p, m, ex] = size (dat);

  ## extract data  
  Y = dat.y;
  U = dat.u;
  tsam = dat.tsam;

  ## multi-experiment data requires equal sampling times  
  if (ex > 1 && ! isequal (tsam{:}))
    error ("arx: require equally sampled experiments");
  else
    tsam = tsam{1};
  endif

  
  if (is_real_scalar (na, nb))
    na = repmat (na, p, 1);     # na(p-by-1)
    nb = repmat (nb, p, m);     # nb(p-by-m)
  elseif (! (is_real_vector (na) && is_real_matrix (nb) \
          && rows (na) == p && rows (nb) == p && columns (nb) == m))
    error ("arx: require na(%dx1) instead of (%dx%d) and nb(%dx%d) instead of (%dx%d)", \
            p, rows (na), columns (na), p, m, rows (nb), columns (nb));
  endif

  max_nb = max (nb, [], 2);     # one maximum for each row/output, max_nb(p-by-1)
  n = max (na, max_nb);         # n(p-by-1)


  num = cell (p, m+1);
  den = cell (p, m+1);
  
  for i = 1 : p     # for every output
    Phi = cell (1, ex);
    for e = 1 : ex      # for every experiment  
      ## avoid warning: toeplitz: column wins anti-diagonal conflict
      ## therefore set first row element equal to y(1)
      PhiY = toeplitz (Y{e}(1:end-1, i), [Y{e}(1, i); zeros(na(i)-1, 1)]);
      ## create MISO Phi for every experiment
      PhiU = arrayfun (@(x) toeplitz (U{e}(1:end-1, x), [U{e}(1, x); zeros(nb(i,x)-1, 1)]), 1:m, "uniformoutput", false);
      Phi{e} = (horzcat (-PhiY, PhiU{:}))(n(i):end, :);
    endfor
  
    Theta = __theta__ (Phi, Y, i, n);
      
    A = [1; Theta(1:na(i))];                     # a0 = 1, a1 = Theta(1), an = Theta(n)
    ThetaB = Theta(na(i)+1:end);                 # b0 = 0 (leading zero required by filt)
    B = mat2cell (ThetaB, nb(i,:));
    B = reshape (B, 1, []);
    B = cellfun (@(x) [0; x], B, "uniformoutput", false);

    num(i, :) = [B, {1}];
    den(i, :) = repmat ({A}, 1, m+1);
  endfor

  sys = filt (num, den, tsam);

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

    [U, S, V] = svd (phi{1}, 0);                    # 0 for "economy size" decomposition
    S = diag (S);                                   # extract main diagonal
    r = sum (S > eps*S(1));
    V = V(:, 1:r);
    S = S(1:r);
    U = U(:, 1:r);
    theta = V * (S .\ (U' * y{1}(n(i)+1:end, i)));     # U' is the conjugate transpose
  else
    ## multi-experiment dataset
    ## TODO: find more sophisticated formula than
    ## Theta = (Phi1' Phi + Phi2' Phi2 + ...) \ (Phi1' Y1 + Phi2' Y2 + ...)
    
    ## covariance matrix C = (Phi1' Phi + Phi2' Phi2 + ...)
    tmp = cellfun (@(Phi) Phi.' * Phi, phi, "uniformoutput", false);
    C = plus (tmp{:});
    
    ## PhiTY = (Phi1' Y1 + Phi2' Y2 + ...)
    tmp = cellfun (@(Phi, Y) Phi.' * Y(n(i)+1:end, i), phi, y, "uniformoutput", false);
    PhiTY = plus (tmp{:});
    
    ## pseudoinverse  Theta = C \ Phi'Y
    theta = C \ PhiTY;
  endif
  
endfunction