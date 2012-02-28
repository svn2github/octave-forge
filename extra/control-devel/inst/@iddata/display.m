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
## Display routine for iddata objects.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: February 2012
## Version: 0.1

function display (dat)

  datname = inputname (1);
  [outname, p] = __labels__ (dat.outname, "y");
  [inname, m] = __labels__ (dat.inname, "u");
  [expname, e] = __labels__ (dat.expname, "exp");
  
  [n, p, m, e] = size (dat);
  
  str = ["Time domain dataset '", datname, "' containing ", num2str(e), " experiment"];
  if (e > 1)
    str = [str, "s"];
  endif

  disp ("");
  disp (str);
  disp ("");
  
  disp (horzcat (__col2str__ (expname, "Experiment"), __vec2str__ (n, "Samples"), __vec2str__ (cell2mat (dat.tsam), "Sampling Interval")));
  disp ("");
  disp (horzcat (__col2str__ (outname, "Outputs"), __col2str__ (dat.outunit, "Unit (if specified)")));
  disp ("");
  disp (horzcat (__col2str__ (inname, "Inputs"), __col2str__ (dat.inunit, "Unit (if specified)")));
  disp ("");
  
%{
  str = strjust (strvcat (expname), "left");
  space = (repmat ("  ", e, 1));
  str = [space, str];
%}
endfunction

%{
function str = __

  space = repmat ("    ", len+2, 1);
  str = [space, str];

endfunction
%}

function str = __col2str__ (col, title)

  len = rows (col);
  str = strjust (strvcat (col), "left");
  str = [repmat("   ", len, 1), str];
  str = strvcat (title, str);

endfunction


function str = __vec2str__ (vec, title)

  vec = vec(:);
  tmp = isfinite (vec);
  tmp = abs (vec(tmp & vec != 0));
  if (isempty (tmp) || min (tmp) < 1e-3 || max (tmp) > 1e4)
    str = arrayfun (@(x) sprintf ("   %.3e", x), vec, "uniformoutput", false);
  elseif (all (floor (tmp) == tmp))
    str = arrayfun (@(x) sprintf ("   %d", x), vec, "uniformoutput", false);
  else
    str = arrayfun (@(x) sprintf ("   %.4f", x), vec, "uniformoutput", false);
  endif
  str = strjust (char (str), "right");
  %str = [repmat("   ", len, 1), str];
  str = strvcat (title, str);
  
  %if (nargin > 1)
  %  str = [str, repmat(post, length (vec), 1)];
  %endif

endfunction



