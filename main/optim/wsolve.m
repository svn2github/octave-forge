## [x,dx] = wsolve(A,y,dy)
##
## Solve a potentially over-determined system with uncertainty in
## the values. Uses QR decomposition for increased accuracy.
## Estimates the uncertainty for the solution given the weighting,
## or if no weighting is given, weighting by an estimate of chisq.
##
## Example 1: weighted system
##    A=[1,2,3;2,1,3;1,1,1]; xin=[1;2;3]; 
##    dy=[0.2;0.01;0.1]; y=A*xin+randn(size(dy)).*dy;
##    [x,dx] = wsolve(A,y,dy);
##    res = [xin, x, dx]
##
##    % Compare the results with a monte carlo simulation
##    n=1000; W = zeros(columns(A),n);
##    for i=1:n, W(:,i) = A\(y+dy.*randn(size(dy))); end
##    sim = [xin, mean(W')', x, std(W')', dx]
##
## Example 2: weighted overdetermined system  y = x1 + 2*x2 + 3*x3 + e
##    A = fullfact([3,3,3]); xin=[1;2;3];
##    y = A*xin; dy = rand(size(y))/50; y+=dy.*randn(size(y));
##    [x,dx] = wsolve(A,y,dy);
##    res = [xin, x, dx]
##
##    % Compare the results with a monte carlo simulation
##    n=1000; W = zeros(columns(A),n);
##    for i=1:n, W(:,i) = A\(y+dy.*randn(size(dy))); end
##    sim = [xin, mean(W')', x, std(W')', dx]

function [x_out,dx_out]=wsolve(A,y,dy)
  if nargin < 2, usage("[x dx] = wsolve(A,y[,dy])"); end
  if nargin < 3, dy = []; end

  [nr,nc] = size(A);
  if nc > nr, error("underdetermined system"); end

  ## apply weighting term, if it was given
  if prod(size(dy))==1
    A = A ./ dy;
    y = y ./ dy;
  elseif ~isempty(dy)
    A = A ./ (dy * ones (1, columns(A)));
    y = y ./ dy;
  endif

  ## system solution: A x = y => x = inv(A) y
  ## QR decomposition has good numerical properties:
  ##   AP = QR, with P'P = Q'Q = I, and R upper triangular
  ## so
  ##   inv(A) y = P inv(R) inv(Q) y = P inv(R) Q' y = P (R \ (Q' y))
  ## Note that b is usually a vector and Q is matrix, so it will
  ## be faster to compute (y' Q)' than (Q' y).
  [Q,R,P] = qr(A,0);
  x = R\(y'*Q)'; 
  x(P) = x;

  ## Get uncertainty from the covariance matrix: dp = sqrt(diag(inv(A'A))).
  ##
  ## Rather than calculate this directly, we are going to use the QR
  ## decomposition we have already computed:
  ##
  ##    AP = QR, with P'P = Q'Q = I, and R upper triangular
  ##
  ## so 
  ##
  ##    A'A = PR'Q'QRP' = PR'RP'
  ##
  ## and
  ##
  ##    inv(A'A) = inv(PR'RP') = inv(P')inv(R'R)inv(P) = P inv(R'R) P'
  ##
  ## For a permutation matrix P,
  ##
  ##    diag(PXP') = P diag(X)
  ##
  ## so
  ##    diag(inv(A'A)) = diag(P inv(R'R) P') = P diag(inv(R'R))
  ##
  ## For R upper triangular, inv(R') = inv(R)' so inv(R'R) = inv(R)inv(R)'.
  ## Conveniently, for X upper triangular, diag(XX') = sumsq(X')', so
  ##
  ##    diag(inv(A'A)) = P sumsq(inv(R)')'
  ## 
  ## This is both faster and more accurate than computing inv(A'A)
  ## directly.
  ##
  ## One small problem:  if R is not square then inv(R) does not exist.
  ## This happens when the system is underdetermined, but in that case
  ## you shouldn't be using wsolve.
  if nargout > 1 || nargout == 0
    dx = sqrt(sumsq(inv(R),2));
    dx(P) = dx;
    if isempty(dy) && length(y) > columns(A)
      ## If we don't have an uncertainty estimate coming in, estimate it
      ## from the chisq of the fit.
      chisq = sumsq(y - A*x)/(length(y)-length(x));
      dx *= sqrt(chisq);
    endif
  endif

  if nargout == 0,
    printf("%15g +/- %-15g\n",[x,dx]');
  elseif nargout == 1,
    x_out = x;
  else
    x_out = x;
    dx_out = dx;
  endif
