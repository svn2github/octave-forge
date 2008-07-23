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
## @deftypefn{Function File} {@var{mutationChildren} =} mutationsinglepoint (@var{parent})
## Single point mutation.
##
## @seealso{ga, gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.2

function mutationChildren = mutationsinglepoint (parent)

  %% constants
  N_BIT_DOUBLE = 64;

  %% n is the single point of the mutation
  %%
  %% n can go from 1 to (N_BIT_DOUBLE * length (parent))
  n = double (uint64 (1 + (((N_BIT_DOUBLE * length (parent)) - 1) * rand())));

  %% mutation in a single point
  concatenated_mutationChildren = __ga_doubles2concatenated_bitstring__ (parent);
  switch (concatenated_mutationChildren (n))
    case '0'
      concatenated_mutationChildren (n) = '1';
    case '1'
      concatenated_mutationChildren (n) = '0';
    otherwise
      error ("A bitstring must have only characters 0 and 1.");
  endswitch

  mutationChildren = __ga_concatenated_bitstring2doubles__ (concatenated_mutationChildren);
endfunction