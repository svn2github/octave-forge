## Copyright (C) 2001 Paul Kienzle
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

## x = dlmread (filename, sep)
##    Read the matrix x from a file, with columns separated by the
##    character sep (default is ",").  NaN values are written as nan.
##
## WARNING: for compatibility, must treat empty fields as zero, but doesn't.
 
## Author: Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
## 2001-02-16
##    * first revision

function x = dlmread (filename, sep)

  if (nargin < 1 || nargin > 2)
    usage ("x = dlmread (filename, sep)");
  endif
  if nargin < 3, sep = ","; endif
  
  fid = fopen(filename, "r");
  if (fid >= 0)
    in = setstr(fread (fid)');
    fclose (fid);

    ## zap extra spaces
    if (sep != " ")
      idx = find (in == " ");
      if (length (idx) > 0) in(idx) = []; endif
    endif

    ## zap carriage returns
    if (sep != "\r")
      idx = find (in == "\r");
      if (length (idx) > 0) in(idx) = []; endif
    endif

    ## convert new lines to spaces
    idx = find (in == "\n");
    if (length(idx) > 0) in(idx) = " "; endif

    ## number of rows is number of newlines
    nr = length(idx);

    ## convert separators to spaces
    idx = find (in == sep);
    if (length(idx) > 0) in(idx) = " "; endif

    [x, n, err] = sscanf(in, "%g");
    if (!isempty(err))
      error(["dlmread: ", err]);
    elseif (rem(n, nr) != 0)
      error("dlmread: rows are different lengths")
    else
      x = reshape(x, n/nr, nr)';
    endif
  else
    error (["dlmwrite: could not open ", filename]);
  endif

endfunction
