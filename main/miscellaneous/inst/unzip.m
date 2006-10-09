function unzip(zipfile)
	
  if (nargin == 1)


    if (ischar (zipfile))

      cmd = sprintf ("unzip %s ", zipfile);

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
	error ("unzip: unzip exited with status = %d", status);
      endif
    
    else
      error ("unzip: expecting an argument to be character strings");
    endif

  else
		usage(" unzip(zipfiles)");
  endif

endfunction