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

function doubles = __ga_concatenated_bitstring2doubles__ (concatenated_bitstring)

	%costanti
	N_BIT_DOUBLE = 64;

	%una variabile d'appoggio
	nvars = length (concatenated_bitstring) / N_BIT_DOUBLE;

	%ottengo il figlio dalla sua stringa di bit
	tmp1 = zeros (1, nvars);
	for i = 1:nvars
		tmp_aux = (i - 1) * N_BIT_DOUBLE;
		tmp1(i) = __bin2num__ (concatenated_bitstring((tmp_aux + 1):(tmp_aux + N_BIT_DOUBLE)));
	endfor

	doubles = tmp1;
endfunction