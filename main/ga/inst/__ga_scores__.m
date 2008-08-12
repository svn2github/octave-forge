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

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.2

function Scores = __ga_scores__ (fitnessfcn, Population, InitialScores = [])
  [nrP ncP] = size (Population);
  [nrIS ncIS] = size (InitialScores);
  #assert ((ncIS == 0) || (ncIS == 1)); ## DEBUG
  #assert (nrIS <= nrP); ## DEBUG
  if (nrIS > 0)
    Scores(1:nrIS, 1) = InitialScores(1:nrIS, 1);
  endif
  for index = (nrIS + 1):nrP
    Scores(index, 1) = fitnessfcn (Population(index, 1:ncP));
  endfor
  #assert (size (Scores), [nrP 1]); ## DEBUG
endfunction