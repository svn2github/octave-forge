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

% function benchmark_dtmm (m, n, nvec)
% description:
% Dense transposed matrix-matrix and matrix-vector multiplication benchmark.
% This is to test the "compound operators" feature introduced in Octave.
%
% arguments:
% m = row dimension of matrices
% n = col dimension of matrices
% nvec = number of vector op repeats
%
% results:
% time_tmm = Time for A'*B (A,B m-by-n matrices)
% time_smm = Time for A'*A
% time_mtm = Time for A*B' (A,B n-by-m matrices)
% time_msm = Time for A*A'
% time_tmv = Time for A'*v nvec-times (A m-by-n matrix)
% time_mtv = Time for v*A' nvec-times (A m-by-n matrix)
%

function results = benchmark_dtmm (m, n, nvec)

  benchutil_default_arg ('m', 40192);
  benchutil_default_arg ('n', 150);
  benchutil_default_arg ('nvec', 100);

  benchutil_initialize (mfilename)

  A = rand (m, n);
  B = rand (m, n);

  benchutil_tic; C = A'*B; time_tmm = benchutil_toc;
  benchutil_set_result ('time_tmm')

  benchutil_tic; C = A'*A; time_smm = benchutil_toc;
  benchutil_set_result ('time_smm')

  A = A';
  B = B';

  benchutil_tic; C = A*B'; time_mtm = benchutil_toc;
  benchutil_set_result ('time_mtm')

  benchutil_tic; C = A*A'; time_msm = benchutil_toc;
  benchutil_set_result ('time_msm')

  A = A';

  v = rand (m, 1);
  benchutil_tic;
  for i=1:nvec
    c = A'*v;
  end
  time_tmv = benchutil_toc;
  benchutil_set_result ('time_tmv')

  v = rand (1, n);
  benchutil_tic;
  for i=1:nvec
    c = v*A';
  end
  time_mtv = benchutil_toc;
  benchutil_set_result ('time_mtv')

