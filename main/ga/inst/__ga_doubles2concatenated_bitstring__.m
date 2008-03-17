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
## Version: 3.2

function concatenated_bitstring = __ga_doubles2concatenated_bitstring__ (doubles)

	%stringhe di bit ottenuta concatenando le stringhe di bit delle singole variabili
	tmp1 = __num2bin__ (doubles(1));
	for i = 2:length(doubles)	%2:1 e' una matrice vuota in octave
		tmp1 = strcat (tmp1, __num2bin__ (doubles(i)));
	endfor

	concatenated_bitstring = tmp1;
endfunction