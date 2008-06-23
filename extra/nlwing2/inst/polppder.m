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

% @deftypefn{Function File} {ppd =} polppder (pp)
% Differentiates a piecewise polynomial structure.
% @end deftypefn
function ppd = polppder (pp)
  ppd.x = pp.x;
  ppd.n = pp.n;
  ppd.d = pp.d;

  if (pp.k <= 1)
    ppd.k = 1;
    pp.P = zeros (size (pp.P, 1), 1);
  else
    k = ppd.k = pp.k - 1;
    ppd.P = dmult (pp.P(:,1:k), k:-1:1);
  endif
endfunction
