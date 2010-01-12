% Copyright (C) 2008  Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctaveForge.
% 
% OctaveForge is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
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

% function results = benchutil_average (benchmark, nruns, arg1, arg2, ...)
% Average the benchmark results over a certain number of runs.

function [results, stddevs] = benchutil_average (benchmark, nruns, varargin)
  bfun = str2func (benchmark);
  for i = 1:nruns
    resi(i) = bfun (varargin{:});
  end
  for f = fieldnames (resi).'
    f = f{1};
    results.(f) = mean ([resi.(f)]);
    stddevs.(f) = std ([resi.(f)]);
  end

  if (benchutil_verbose)
    [bdesc, adesc, rdesc] = benchutil_parse_desc ([benchmark, '.m']);
    fprintf ('\n\n');
    for fn = fieldnames (rdesc).'
      fn = fn{1};
      fprintf ('%s (avg. over %d runs): %f +/- %f%%\n', rdesc.(fn), nruns, ...
      results.(fn), 138.59*stddevs.(fn) / results.(fn));
    end
  end

  if (nargout < 1)
    clear results stddevs
  end
  
