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
## @deftypefn{Function File} {@var{xoverKids} =} crossoverscattered (@var{parents})
## Combine two individuals, or parents, to form a crossover child.
##
## @seealso{ga, gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.1

%signature diversa da matlab per problema handle funzioni (comunque se piu' tempo da riprovare)
function xoverKids = crossoverscattered (parents)
	concatenated_parents = [(__ga_doubles2concatenated_bitstring__ (parents(1, :))); (__ga_doubles2concatenated_bitstring__ (parents(2, :)))];

	%crossover scattered
	tmp = concatenated_parents(1, :);
	for i = 1:length (tmp)
		if (rand () < 0.5)
			tmp(1, i) = concatenated_parents(2, i);
		endif
	endfor
	concatenated_xoverKids = tmp;

	xoverKids = __ga_concatenated_bitstring2doubles__ (concatenated_xoverKids);
endfunction