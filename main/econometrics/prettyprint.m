# Copyright (C) 2003,2004  Michael Creel michael.creel@uab.es
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## this prints matrices with row and column labels
function prettyprint(mat, rlabels, clabels)

	# left pad the column labels 
	a = columns(rlabels);
	for i = 1:a
		printf(" ");
	endfor
	printf("  ");

	# print the column labels
	clabels = ["          ";clabels]; # pad to 8 characters wide
	clabels = strjust(clabels,"right");

	k = columns(mat);
	for i = 1:k
		printf("%s  ",clabels(i+1,:));
	endfor

	# now print the row labels and rows
	printf("\n");
	k = rows(mat);
	for i = 1:k
		if isstr(rlabels(i,:))
			printf(rlabels(i,:));
		else
			printf("%i", rlabels(i,:));
		endif
		printf("  %10.3f", mat(i,:));
		printf("\n");
	endfor
endfunction
