%% Copyright (C) 2010 Olaf Till
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or (at
%% your option) any later version.
%%
%% This program is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%% General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307USA

function [lb, idx] = cpiv (v, m)

  %% [lb, idx] = cpiv (v, m)
  %%
  %% v: column vector; m: matrix. length (v) must equal rows (m). m must
  %% be positive definit, which is not be explicitely checked. Finds
  %% column vectors w and l with w == v + m * l, w >= 0, l >= 0, l.' * w
  %% == 0. lb: column vector of components of l for which the
  %% corresponding components of w are zero; idx: logical index of these
  %% components in l. This is called solving the 'complementary pivot
  %% problem' (Cottle, R. W. and Dantzig, G. B., 'Complementary pivot
  %% theory of mathematical programming', Linear Algebra and Appl. 1,
  %% 102--125. References for the current algorithm: Bard, Y.: Nonlinear
  %% Parameter Estimation, p. 147--149, Academic Press, New York and
  %% London 1974; Bard, Y., 'An eclectic approach to nonlinear
  %% programming', Proc. ANU Sem. Optimization, Canberra, Austral. Nat.
  %% Univ.).

  n = length (v);
  if (n > size (v, 1))
    error ('first argument is no column vector'); % the most typical mistake
  end
  m = cat (2, m, v);
  id = ones (n, 1);
  nz = -eps; % This is arbitrary; components of w and -l are regarded as
				% non-negative if >= nz.
  nl = 100 * n; % maximum number of loop repeats, after that give up
  ready = false;
  while (~ ready && nl > 0)
    [vm, idm] = min (id .* m(:, end));
    if (vm >= nz)
      ready = true;
    else
      id(idm) = -id(idm);
      m = gjp (m, idm);
      nl = nl - 1;
    end
  end
  if (~ ready)
    error ('not successful');
  end
  idx = id < 0;
  lb = -m(idx, end);
