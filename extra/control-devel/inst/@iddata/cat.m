## Copyright (C) 2012   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{dat} =} cat (@var{dim}, @var{dat1}, @var{dat2}, @dots{})
## Concatenation of iddata objects along dimension @var{dim}.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: March 2012
## Version: 0.1

function dat = cat (dim, varargin)

  tmp = cellfun (@iddata, varargin);
  [n, p, m, e] = cellfun (@size, varargin, "uniformoutput", false);

  switch (dim)
    case 1      # vertcat - catenate samples
      if (nargin > 2)       # isequal only works for 2 or more arguments (dim doesn't count)
        if (! isequal (e{:}))
          error ("iddata: cat: number of experiments don't match [%s]", \
                 num2str (cell2mat (e), "%d "));
        endif
        if (! isequal (p{:})
          error ("iddata: cat: number of outputs don't match [%s]", \
                 num2str (cell2mat (p), "%d "));
        endif
        if (! isequal (m{:})
          error ("iddata: cat: number of inputs don't match [%s]", \
                 num2str (cell2mat (m), "%d "));
        endif
      endif
    
      y = cellfun (@vertcat, tmp.y, "uniformoutput", false);
      u = cellfun (@vertcat, tmp.u, "uniformoutput", false);
    
    case 2      # horzcat - catenate channels;
      y = cellfun (@horzcat, tmp.y, "uniformoutput", false);
      u = cellfun (@horzcat, tmp.u, "uniformoutput", false);
    
    case 3      # merge - catenate experiments
      y = vertcat (tmp.y);
      u = vertcat (tmp.u);
    
    otherwise
      error ("iddata: cat: '%s' is an invalid dimension", num2str (dim));
  endswitch
  
  dat = iddata (y, u);

endfunction


%!error (cat (1, iddata (1, 1), iddata ({2, 3}, {2, 3})));