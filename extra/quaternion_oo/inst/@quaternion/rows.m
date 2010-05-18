function r = rows (a)

  if (nargin != 1)
    print_usage ();
  endif

  r = rows (a.w);

endfunction