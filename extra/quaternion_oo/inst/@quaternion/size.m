function s = size (a, b = ":")

  if (nargin > 2)
    print_usage ();
  endif

  s = size (a.w)(b).';

  ## TODO: - catch case nargout == 2
  ##       - return 1 if b > numel (s)

endfunction