## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: y = rectpuls(t, w)
##
## Generate a rectangular pulse over the interval [-w/2,w/2), sampled at
## times t.  This is useful with the function pulstran for generating a
## series pulses.
##
## Example
##   fs = 11025;  # arbitrary sample rate
##   f0 = 100;    # pulse train sample rate
##   w = 0.3/f0;  # pulse width 3/10th the distance between pulses
##   auplot(pulstran(0:1/fs:4/f0, 0:1/f0:4/f0, 'rectpuls', w), fs);
##
## See also: pulstran
function y = rectpuls(t, w)

  if nargin<1 || nargin>2,
    usage("y = rectpuls(t [, w])");
  endif

  if nargin < 2, w = 1; endif

  y = zeros(size(t));
  idx = find(t>=-w/2 & t < w/2);
  dfi = do_fortran_indexing;
  unwind_protect
    do_fortran_indexing = 1;
    y(idx) = ones(size(idx));
  unwind_protect_cleanup
    do_fortran_indexing = dfi;
  end_unwind_protect
endfunction

%!assert(rectpuls(0:1/100:0.3,.1), rectpuls([0:1/100:0.3]',.1)');
%!assert(isempty(rectpuls([],.1)));
%!demo
%! fs = 11025;  # arbitrary sample rate
%! f0 = 100;    # pulse train sample rate
%! w = 0.3/f0;  # pulse width 1/10th the distance between pulses
%! oneplot(); ylabel("amplitude"); xlabel("time (ms)");
%! title("graph shows 3 ms pulses at 0,10,20,30 and 40 ms");
%! auplot(pulstran(0:1/fs:4/f0, 0:1/f0:4/f0, 'rectpuls', w), fs); 
%! title(""); xlabel(""); ylabel("");
