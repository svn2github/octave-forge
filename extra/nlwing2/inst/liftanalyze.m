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

function [a0, amax, clmax] = liftanalyze (al, cl)
  if (cl(1) > 0)
    warning ("liftanalyze: polar starts at positive lift");
  endif
  [clmin, imin] = min (cl);
  [clmax, imax] = max (cl);
  if (any (cl(imin+1:imax) < cl(imin:imax-1)))
    warning ("liftanalyze: multimodal lift curve");
  endif
  a0 = interp1 (cl(imin:imax), al(imin:imax), 0, "extrap");
  amax = al(imax);
endfunction
