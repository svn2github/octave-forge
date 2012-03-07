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
      check_experiments (tmp, e);
      check_outputs (tmp, p);
      check_inputs (tmp, m);
    
      y = cellfun (@vertcat, tmp.y, "uniformoutput", false);
      u = cellfun (@vertcat, tmp.u, "uniformoutput", false);
    
    case 2      # horzcat - catenate channels;
      check_experiments (tmp, e);
      check_samples (n);

      y = cellfun (@horzcat, tmp.y, "uniformoutput", false);
      u = cellfun (@horzcat, tmp.u, "uniformoutput", false);
    
    case 3      # merge - catenate experiments
      check_outputs (tmp, p);
      check_inputs (tmp, m);

      y = vertcat (tmp.y);
      u = vertcat (tmp.u);
    
    otherwise
      error ("iddata: cat: '%s' is an invalid dimension", num2str (dim));
  endswitch
  
  dat = iddata (y, u);

endfunction


function check_experiments (tmp, e)

  if (numel (e) > 1 && ! isequal (e{:}))        # isequal doesn't work with less than 2 arguments
    error ("iddata: cat: number of experiments don't match [%s]", \
           num2str (cell2mat (e), "%d "));
  endif
  
  if (! compare_strings (tmp.expname))
    warning ("iddata: cat: experiment names don't match")
  endif

endfunction


function check_outputs (tmp, p)

  if (numel (p) > 1 && ! isequal (p{:}))
    error ("iddata: cat: number of outputs don't match [%s]", \
           num2str (cell2mat (p), "%d "));
  endif
  
  if (! compare_strings (tmp.outname))
    warning ("iddata: cat: output names don't match")
  endif

  if (! compare_strings (tmp.outunit))
    warning ("iddata: cat: output units don't match")
  endif

endfunction


function check_inputs (tmp, m)

  if (numel (m) > 1 && ! isequal (m{:}))
    error ("iddata: cat: number of inputs don't match [%s]", \
           num2str (cell2mat (m), "%d "));
  endif

  if (! compare_strings (tmp.inname))
    warning ("iddata: cat: input names don't match")
  endif

  if (! compare_strings (tmp.inunit))
    warning ("iddata: cat: input units don't match")
  endif

endfunction


function check_samples (n)

  if (numel (n) > 1 && ! isequal (n{:}))
    error ("iddata: cat: number of samples don't match %s", \
           mat2str (vertcat (n{:}), 10));
  endif

endfunction


## kind of strcmp for more than two arguments
## return true if all cells of strings are equal
## and false otherwise
function bool = compare_strings (str, varargin)

  if (nargin > 1)
    tmp = cellfun (@(x) strcmp (str, x), varargin, "uniformoutput", false);
    tmp = cellfun (@all, tmp);
    bool = all (tmp);
  else
    bool = true;
  endif

endfunction


%!error (cat (1, iddata (1, 1), iddata ({2, 3}, {2, 3})));
