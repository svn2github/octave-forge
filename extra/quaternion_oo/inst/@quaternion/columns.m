function c = columns (a)

  if (nargin != 1)
    print_usage ();
  endif

  c = columns (a.w);

endfunction