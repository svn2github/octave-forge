function zip(zipfile, files)
	
  if (nargin == 2)

    if (ischar (files))
      files = cellstr (files);
    endif

    if (ischar (zipfile) && iscellstr (files))

      cmd = sprintf ("zip %s %s", zipfile,
		     sprintf (" %s", files{:}));

      [status, output] = system (cmd);

      if (status == 0)
	if (nargout > 0)
	  if (output(end) == "\n")
	    output(end) = [];
	  endif
          entries = cellstr (split (output, "\n"));
	  entries = entries';
	endif
      else
	error ("zip: zip exited with status = %d", status);
      endif
    
    else
      error ("zip: expecting all arguments to be character strings");
    endif

  else
		usage(" zip(zipfiles,files)");
  endif

endfunction