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
## Version: 3.1

%signature diversa da matlab per problema handle funzioni (comunque se piu' tempo da riprovare)
function xoverKids = crossoversinglepoint (parents)

	%costanti
	N_BIT_DOUBLE = 64;

	%una variabile d'appoggio
	nvars = columns (parents);

	concatenated_parents = [(__ga_doubles2concatenated_bitstring__ (parents(1, :))); (__ga_doubles2concatenated_bitstring__ (parents(2, :)))];

	%n e' il singolo punto del crossover
	%n potra' andare da 1 a ((N_BIT_DOUBLE * nvars) - 1)
	n = double (uint64 ((((nvars * N_BIT_DOUBLE) - 2) * rand ()) + 1));

	%crossover a singolo punto
	concatenated_xoverKids = strcat (substr (concatenated_parents (1, :), 1, n), substr (concatenated_parents (2, :), (n + 1)));

	xoverKids = __ga_concatenated_bitstring2doubles__ (concatenated_xoverKids);
endfunction