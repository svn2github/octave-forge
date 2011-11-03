function q = q0

  if (nargin != 0)
    print_usage ();
  endif

  q = quaternion (1, 0, 0, 0);

endfunction