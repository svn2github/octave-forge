function opt = options (varargin)

  if (nargin == 0)
    print_usage ();
  endif

  if (rem (nargin, 2))
    error ("options: properties and values must come in pairs");
  endif

  key = reshape (varargin(1:2:end-1), [], 1);
  val = reshape (varargin(2:2:end), [], 1);

  opt = cell2struct (val, key, 1)

endfunction