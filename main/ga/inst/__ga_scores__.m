## Copyright (C) 2008, 2010 Luca Favatella <slackydeb@gmail.com>
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.4

function Scores = __ga_scores__ (fitnessfcn, Population)
  [nrP ncP] = size (Population);
  tmp = zeros (nrP, 1);
  for index = 1:nrP
    tmp(index, 1) = fitnessfcn (Population(index, 1:ncP));
  endfor
  Scores = tmp(1:nrP, 1);
endfunction