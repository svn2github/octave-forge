## Copyright (C) 2006   Sissou   <sylvain.pelissier@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} zip (@var{zipfile},@var{files})
## Compress the list of files specified in 'files' into the archive 'zipfiles' in the same directory.
## @seealso{unzip,tar}
## @end deftypefn

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