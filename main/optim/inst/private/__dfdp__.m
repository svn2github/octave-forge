%% Copyright (C) 1992-1994 Richard Shrager
%% Copyright (C) 1992-1994 Arthur Jutan
%% Copyright (C) 1992-1994 Ray Muzic
%% Copyright (C) 2010 Olaf Till <olaf.till@uni-jena.de>
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.

function prt = __dfdp__ (f, p, dp, func, bounds)

  %% Meant to be called by interfaces 'dfdp.m' and 'dcdp.m', see there.

  m = length (f);
  n = length (p);
  if (nargin < 5)
    bounds = ones (n, 2);
    bounds(:, 1) = -Inf;
    bounds(:, 2) = Inf;
  end
  prt = zeros (m, n); % initialise Jacobian to Zero
  del = dp .* p;
  absdel = abs (del);
  idxa = p == 0;
  del(idxa) = dp(idxa);
  idxd = dp > 0; % double sided interval
  idxz = dp == 0;
  p1 = zeros (n, 1);
  p2 = p1;
  idxvs = false (n, 1);
  idx1g2w = idxvs;
  idx1le2w = idxvs;

  %% p may be slightly out of bounds due to inaccuracy, or exactly at
  %% the bound -> single sided interval
  idxvl = p <= bounds(:, 1);
  idxvg = p >= bounds(:, 2);
  p1(idxvl) = min (p(idxvl) + absdel(idxvl), bounds(idxvl, 2));
  idxd(idxvl) = false;
  p1(idxvg) = max (p(idxvg) - absdel(idxvg), bounds(idxvg, 1));
  idxd(idxvg) = false;
  idxs = ~(idxz | idxd); % single sided interval

  idxnv = ~(idxvl | idxvg); % current paramters within bounds
  idxnvs = idxs & idxnv; % within bounds, single sided interval
  idxnvd = idxd & idxnv; % within bounds, double sided interval
  %% remaining single sided intervals
  p1(idxnvs) = p(idxnvs) + del(idxnvs); % don't take absdel, this could
				% change course of optimization without
				% bounds with respect to previous
				% versions
  %% remaining single sided intervals, violating a bound -> take largest
  %% possible direction of single sided interval
  idxvs(idxnvs) = p1(idxnvs) < bounds(idxnvs, 1) | ...
      p1(idxnvs) > bounds(idxnvs, 2);
  del1 = p(idxvs) - bounds(idxvs, 1);
  del2 = bounds(idxvs, 2) - p(idxvs);
  idx1g2 = del1 > del2;
  idx1g2w(idxvs) = idx1g2;
  idx1le2w(idxvs) = ~idx1g2;
  p1(idx1g2w) = max (p(idx1g2w) - absdel(idx1g2w), bounds(idx1g2w, 1));
  p1(idx1le2w) = min (p(idx1le2w) + absdel(idx1le2w), ...
		      bounds(idx1le2w, 2));
  %% double sided interval
  p1(idxnvd) = min (p(idxnvd) + absdel(idxnvd), bounds(idxnvd, 2));
  p2(idxnvd) = max (p(idxnvd) - absdel(idxnvd), bounds(idxnvd, 1));

  del(idxs) = p1(idxs) - p(idxs);
  del(idxd) = p1(idxd) - p2(idxd);

  for j = 1:n
    if (~idxz(j))
      ps = p;
      ps(j) = p1(j);
      tp1 = func (ps);
      if (idxs(j))
	prt(:, j) = (tp1(:) - f) / del(j);
      else
	ps(j) = p2(j);
	tp2 = func (ps);
	prt(:, j) = (tp1(:) - tp2(:)) / del(j);
      end
    end
  end
