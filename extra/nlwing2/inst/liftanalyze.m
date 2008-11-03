% Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
% 
% Author: Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of NLWing2.
% 
% NLWing2 is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 

% -*- texinfo -*-
% @deftypefn{Function File} {[a0, amax, clmax] =} liftanalyze (al, cl)
% analyzes a lift curve. Searches for a zero-lift and max-lift
% angle.
% @end deftypefn

function [a0, amax, clmax] = liftanalyze (al, cl, pn = '')
  if (pn)
    wpref = strcat ("liftanalyze (", pn, "): ");
  else
    wpref = "liftanalyze: ";
  endif
  if (cl(1) > 0)
    warning ([wpref, "polar starts at positive lift"]);
    warned = true;
  endif
  [clmin, imin] = min (cl);
  [clmax, imax] = max (cl);
  if (any (cl(imin+1:imax) < cl(imin:imax-1)))
    warning ([wpref, "multimodal lift curve"]);
    warned = true;
  endif
  if (imax == length (cl))
    warning ([wpref, "maximum lift at end of lift curve"]);
    warned = true;
  endif
  a0 = interp1 (cl(imin:imax), al(imin:imax), 0, "extrap");
  amax = al(imax);
endfunction
