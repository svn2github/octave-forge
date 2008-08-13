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
## Version: 1.1.4

function xoverKids = __ga_crossoverfcn__ (parents, options, nvars, FitnessFcn,
                                          unused,
                                          thisPopulation)

  ## preconditions
  [nr_parents nc_parents] = size (parents);
  assert (nr_parents, 1); ## DEBUG
  assert (rem (nc_parents, 2), 0); ## DEBUG
  assert (columns (thisPopulation), nvars); ## DEBUG

  xoverKids = options.CrossoverFcn (parents, options, nvars, FitnessFcn,
                                    unused,
                                    thisPopulation);

  ## postconditions
  assert (size (xoverKids), [(nc_parents / 2) nvars]); ## DEBUG
endfunction