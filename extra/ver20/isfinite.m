## Returns true if x is finite.
function x = isfinite(A)
  if nargin != 1
    usage("x = isfinite(A)");
  endif
  x = !isinf(A);
  
