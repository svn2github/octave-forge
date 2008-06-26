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
% @deftypefn{Function File} {wing =} makewing (acs, pols, ref, np, tfunc)
% Creates the wing structure necessary for further computations. 
% @var{acs} is an N-by-5 array specifying the spanwise geometry description.
% each row contains @code{[zac xac yac chord twist]}
% pols is a struct array describing the spanwise wing section data
% distribution. @code{pols(i).z} is the spanwise coordinate, @code{pols(i).cl}
% is the lift coefficient on local angle of attack dependence, etc. 
% @var{ref} contains the reference quantities.
% @var{np} specifies an approximate number of panels.
% @var{tfunc} is a handle to a function mapping 
% @end deftypefn
function wing = makewing (ac, pols, ref, np = 80, zac = [])

  ozac = ac(:,1);

  if (isempty (zac))
    % distribute points
    if (ref.sym)
      zmx = ozac(end);
      fi = linspace (0, pi/2, np+1).';
      zac = zmx * sin (fi);
    else
      error ("panelize: unsymmetric case not implemented")
    endif
  endif

  wing.zac = zac;
  aci = interp1 (ozac, ac(:,2:5), zac, "pchip");
  wing.xac = aci(:,1);
  wing.yac = aci(:,2);

  m2 = @(v) (v(1:end-1)+v(2:end))/2;
  wing.zc = zc = m2 (zac);
  wing.ch = m2 (aci(:,3));
  wing.twc = pi/180 * m2 (aci(:,4));

  zpol = [pols.z];
  if (any (diff (zpol) < 0))
    [zpol,isrt] = sort (zpol);
    pols = pols(isrt);
  endif

  % set jj so that zc(jj(i)-1) <= zpol(i) < zc(jj(i)) 
  % which, in turn, means 
  % zpol(i) < zc(jj(i)) <= zc(jj(i+1)-1) <= zpol(i+1)
  jj = lookup (zc, zpol) + 1;
  % correct boundary values (to include all of zc)
  jj(1) = 1;
  jj(end) = length (zc) + 1;

  wing.pidx = jj;
  wing.pol = pols;
  wing.np = np;

  wing.a0 = interp1 (zpol, [pols.a0], zc, "extrap") - wing.twc;
  wing.amax = interp1 (zpol, [pols.amax], zc, "extrap");
  wing.clmax = interp1 (zpol, [pols.clmax], zc, "extrap");

  wing.cf = zeros (length (jj), 1);

  % TODO: can fully vectorize here?
  for i=1:length (jj)-1
    jl = jj(i); ju = jj(i+1)-1;
    wing.cf (jl:ju) = interp1 (zpol(i:i+1), [0 1], wing.zc (jl:ju), ...
      'linear', 'extrap');
  endfor

  for [val,key] = ref
    wing.(key) = val;
  endfor
  if (! isfield (wing, 'sym'))
    wing.sym = true;
  endif
  if (! isfield (wing, 'area'))
    wing.area = sum (wing.ch .* diff (wing.zac));
    if (wing.sym)
      wing.area *= 2;
    endif
  endif
  if (! isfield (wing, 'span'))
    wing.span = wing.zac(end) - wing.zac(1);
    if (wing.sym)
      wing.span *= 2;
    endif
  endif
endfunction
