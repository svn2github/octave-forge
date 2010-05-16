function q = qi

  if (nargin != 0)
    print_usage ();
  endif

  q = quaternion (0, 1, 0, 0);

endfunction