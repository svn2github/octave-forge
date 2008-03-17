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
## @deftypefn{Function File} {@var{parents} =} selectionroulette (@var{fitnessfcn}, @var{popolazione})
## Choose parents.
##
## @strong{Outputs}
## @table @var
## @item parents
## A row vector of length 2 containing the indices of the parents that you select.
## @end table
##
## @seealso{ga}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.1

function parents = selectionroulette (fitnessfcn, popolazione)

	%una variabile d'appoggio
	n_individui = rows (popolazione);

	%assegno le "probabilita'" linearmente e decrescenti; ad esempio, se gli individui sono 3 le "probabilita'" saranno, da quello a fitnessfcn minore (cioe' migliore), rispettivamente 3, 2 e 1
	probabilita = zeros (n_individui, 1);
	for i = 1:n_individui;
		probabilita(i) = n_individui + 1 - i;
	endfor

	%maggiore probabilita' per i primi elementi
	probabilita_cumulative = cumsum (probabilita);

	%applico la roulette
	aux_roulette = probabilita_cumulative(n_individui) * rand (1, 2);
	index_individui_scelti = zeros (1, 2);
	for i = 1:n_individui
		if ((aux_roulette(1) <= probabilita_cumulative(i)) && (index_individui_scelti(1) == 0))
			index_individui_scelti(1) = i;
		endif
		if ((aux_roulette(2) <= probabilita_cumulative(i)) && (index_individui_scelti(2) == 0))
			index_individui_scelti(2) = i;
		endif
	endfor

	%le immagini di fitnessfcn sulla popolazione ordinate in ordine crescente
	[trash index_img_fitnessfcn] = sort (__ga_calcola_img_fitnessfcn__ (fitnessfcn, popolazione));

	parents = [index_img_fitnessfcn(index_individui_scelti(1)), index_img_fitnessfcn(index_individui_scelti(2))];
endfunction