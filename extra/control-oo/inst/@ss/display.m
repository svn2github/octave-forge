## Copyright (C) 2009   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Display routine for SS objects.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: September 2009
## Version: 0.1

function display (sys)

  tsam = get (sys, "tsam");
  inname = get (sys, "inname");
  outname = get (sys, "outname");
  stname = sys.stname;

  if (isempty (inname) || isequal ("", inname{:}))
    inname = strseq ("u", 1 : length (inname));
  else
    inname = __markemptynames__ (inname);
  endif

  if (isempty (outname) || isequal ("", outname{:}))
    outname = strseq ("y", 1 : length (outname));
  else
    outname = __markemptynames__ (outname);
  endif

  if (isempty (stname) || isequal ("", stname{:}))
    stname = strseq ("x", 1 : length (stname));
  else
    stname = __markemptynames__ (stname);
  endif

  ## fprintf ("SS object %s:\n", inputname(1));
  disp ("");

  if (! isempty (sys.a))
    dispmat (sys.a, "a", stname, stname);
    dispmat (sys.b, "b", stname, inname);
    dispmat (sys.c, "c", outname, stname);
  endif

  dispmat (sys.d, "d", outname, inname);

  display (sys.lti);  # display sampling time

  if (tsam == -1)
    disp ("Static gain.");
  elseif (tsam == 0)
    disp ("Continuous-time model.");
  else
    disp ("Discrete-time model.");
  endif

endfunction


function dispmat (m, mname, rname, cname)

  MAX_LEN = 12;  # max length of row name and column name
  [mrows, mcols] = size (m);

  disp ([mname, " ="]);

  row_name = strjust (strvcat (" ", rname), "left");
  row_name = row_name(:, 1 : min (MAX_LEN, end));
  row_name = horzcat (repmat (" ", mrows+1, 3), row_name);

  mat = cell (1, mcols);
  
  for k = 1 : mcols
    cname{k} = cname{k}(:, 1 : min (MAX_LEN, end));
    acol = vertcat (cname(k), cellstr (deblank (num2str (m(:, k), 4))));
    mat{k} = strjust (strvcat (acol{:}), "right");
  endfor

  lcols = cellfun ("size", mat, 2);
  lcols_max = 2 + max (lcols);

  for k = 1 : mcols
    mat{k} = horzcat (repmat (" ", mrows+1, lcols_max-lcols(k)), mat{k});
  endfor

  mat = horzcat (row_name, mat{:});
  disp (mat);
  disp ("");

endfunction