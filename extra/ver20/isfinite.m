function x = isfinite(A)
  if nargin != 1
    usage("x = isfinite(A)");
  endif
  x = !isinf(A);
  