function c = opt2cell (opt)

  if (! isstruct (opt))
    error ("opt2cell: argument must be a struct");
  endif

  key = fieldnames (opt);
  val = struct2cell (opt);
  
  c = [key.'; val.'](:);  # reshape to {key1; val1; key2; val2; ...}

endfunction