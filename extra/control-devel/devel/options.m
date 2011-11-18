function opt = options (varargin)

  key = reshape (varargin(1:2:end-1), [], 1);
  val = reshape (varargin(2:2:end), [], 1);

  opt = cell2struct (val, key, 1)

endfunction