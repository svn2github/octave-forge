function q = qk

  if (nargin != 0)
    print_usage ();
  endif

  q = quaternion (0, 0, 0, 1);

endfunction