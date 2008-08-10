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
## @deftypefn{Function File} {@var{x} =} __ga_stop__ (@var{problem}, @var{state})
## Determine whether the genetic algorithm should stop.
##
## @seealso{__ga_problem__}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.0

function retval = __ga_stop__ (problem, state)
  Generations = \
      (state.Generation >= problem.options.Generations);

  TimeLimit = \
      ((time () - state.StartTime) >= problem.options.TimeLimit);

  FitnessLimit = \
      (state.Best(state.Generation + 1, 1) <= problem.options.FitnessLimit);

  retval = (Generations ||
            TimeLimit ||
            FitnessLimit);
endfunction