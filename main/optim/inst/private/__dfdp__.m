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
  n=length(p);      %dimensions
  if (nargin < 6)
    bounds = ones (n, 2);
    bounds(:, 1) = -Inf;
    bounds(:, 2) = Inf;
  end
  prt=zeros(m,n);       % initialise Jacobian to Zero
  del = dp .* p; %cal delx=fract(dp)*param value(p)
  idx = p == 0;
  del(idx) = dp(idx); %if param=0 delx=fraction
  idx = dp > 0;
  del(idx) = abs (del(idx)); % not for one-sided intervals, changed
				% direction of intervals could change
				% behavior of optimization without bounds
  min_del = min (abs (del), bounds(:, 2) - bounds(:, 1));
  for j=1:n
    ps = p;
    if (dp(j)~=0)
      if (dp(j) < 0)
	ps(j) = p(j) + del(j);
	if (ps(j) < bounds(j, 1) || ps(j) > bounds(j, 2))
	  t_del1 = max (bounds(j, 1) - p(j), - abs (del(j))); %
				%non-positive
	  t_del2 = min (bounds(j, 2) - p(j), abs (del(j))); %
				%non-negative
	  if (- t_del1 > t_del2)
	    del(j) = t_del1;
	  else
	    del(j) = t_del2;
	  end
	  ps(j) = p(j) + del(j);
	end
	tpf = func (ps);
	prt(:, j) = (tpf(:) - f) / del(j);
      else
	if (p(j) - del(j) < bounds(j, 1))
	  tp = bounds(j, 1);
	  ps(j) = tp + min_del(j);
	elseif (p(j) + del(j) > bounds(j, 2))
	  ps(j) = bounds(j, 2);
	  tp = ps(j) - min_del(j);
	else
	  ps(j) = p(j) + del(j);
	  tp = p(j) - del(j);
	  min_del(j) = 2 * del(j);
	end
	f1 = func (ps);
	f1 = f1(:);
	ps(j) = tp;
	tpf = func (ps);
        prt(:, j) = (f1 - tpf(:)) / min_del(j);
      end
    end
  end
