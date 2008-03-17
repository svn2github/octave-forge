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
## Version: 3.1

%ritorna true se è stata raggiunta la condizione di stop, false altrimenti
function retval = __ga_stop__ (problem, popolazione, generazione)
	__ga_stop_aux1__ = (generazione >= gaoptimget (problem.options, 'Generations'));

	%in doc matlab e' previsto <= e non <
	__ga_stop_aux2__ = (problem.fitnessfcn ((__ga_sort_ascend_population__ (problem.fitnessfcn, popolazione))(1, :)) <= gaoptimget (problem.options, 'FitnessLimit'));

	retval = (__ga_stop_aux1__ || __ga_stop_aux2__);
endfunction