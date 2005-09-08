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

## x = dlmread (filename, sep, row)
##    Read the matrix x from a file, with columns separated by the
##    character sep (default is ",").  NaN values are written as nan.
##    The number of rows to skip before reading data is row (default is 0).
##
## WARNING: for compatibility, must treat empty fields as zero, but doesn't.

## Author: Paul Kienzle <pkienzle@users.sf.net>
## 2001-02-16
##    * first revision

function x = dlmread (filename, sep, row)

  if (nargin < 1 || nargin > 3)
    usage ("x = dlmread (filename, sep, row)");
  endif
  if nargin < 2, sep = ","; endif
  if nargin < 3, row = 0; endif

  fid = fopen(filename, "rt");
  if (fid >= 0)
    in = char(fread (fid)');
    fclose (fid);

    ## Count the number of line feeds, or if there are none
    ## the number of carriage returns.  This is the number
    ## of rows.  Note that we have to also check for a missing
    ## line terminator on the last line of the file.
    idx = find (in == "\n");
    nr = length(idx);
    if (nr > 0)
	in(idx) = " ";
	nr += (idx(length(idx)) < length(in));
        idxl = idx;
    endif
    idx = find (in == "\r");
    if (nr == 0)
	nr = length(idx);
	if (nr > 0) nr += (idx(length(idx)) < length(in)); endif
	idxl = idx;
    endif
    if (length (idx) > 0) in(idx) = " "; endif
    nr = nr-row;

    ## find where to start reading data
    if (row > 0)
	istr = idxl(row)+1;
    else
       istr = 1;
    endif
 
    ## convert separators to spaces
    idx = find (in == sep);
    if (length(idx) > 0) in(idx) = " "; endif
    [x, n, err] = sscanf(in(istr:length(in)), "%g");
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
