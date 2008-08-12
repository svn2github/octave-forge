## Copyright (C) 2008 Luca Favatella <slackydeb@gmail.com>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program  is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{parents} =} selectionstochunif (@var{expectation}, @var{nParents}, @var{options})
## Choose parents.
##
## @seealso{ga}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.2

function parents = selectionstochunif (expectation, nParents, options)
  [nr nc] = size (expectation);
  #assert (nr, 1); ## DEBUG
  line(1, 1:nc) = cumsum (expectation(1, 1:nc));
  max_step_size = line(1, nc);
  step_size = max_step_size * rand ();
  steps(1, 1:nParents) = rem (step_size * ones (1, nParents), max_step_size);

  for index_steps = 1:nParents ## fix an entry of the steps (or parents) vector
    #assert (steps(1, index_steps) < max_step_size); ## DEBUG
    index_line = 1;
    while (steps(1, index_steps) >= line(1, index_line))
      #assert ((index_line >= 1) && (index_line < nc)); ## DEBUG
      index_line++;
    endwhile
    parents(1, index_steps) = index_line;
  endfor
  #assert (size (parents), [1 nParents]); ## DEBUG
endfunction