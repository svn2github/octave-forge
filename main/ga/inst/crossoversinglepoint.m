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
## @deftypefn{Function File} {@var{xoverKids} =} crossoversinglepoint (@var{parents})
## Combine two individuals, or parents, to form a crossover child.
##
## @seealso{ga, gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.2

                                % different signature from MATLAB
                                % because of a problem of function
                                % handle (retry if more spare time)
function xoverKids = crossoversinglepoint (parents)

  %% constants
  N_BIT_DOUBLE = 64;

  %% aux variable
  nvars = columns (parents);

  concatenated_parents = [(__ga_doubles2concatenated_bitstring__ (parents(1, :)));
                          (__ga_doubles2concatenated_bitstring__ (parents(2, :)))];

  %% n is the single point of the crossover
  %%
  %% n can be from 1 to ((N_BIT_DOUBLE * nvars) - 1)
  n = double (uint64 ((((nvars * N_BIT_DOUBLE) - 2) * rand ()) + 1));

  %% single point crossover
  concatenated_xoverKids = strcat (substr (concatenated_parents (1, :),
                                           1, n),
                                   substr (concatenated_parents (2, :),
                                           (n + 1)));

  xoverKids = __ga_concatenated_bitstring2doubles__ (concatenated_xoverKids);
endfunction