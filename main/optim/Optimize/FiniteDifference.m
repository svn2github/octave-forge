# Copyright (C) 2003  Michael Creel michael.creel@uab.es
# under the terms of the GNU General Public License.
# The GPL license is in the file COPYING
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
 
#========================= FiniteDifference ==========================
# finite differences for numeric differentiation
# the formulae here are based on those in Ox 3.20 (Doornik)
# which references Rice
function d = FiniteDifference(x, order)
	SQRT_EPS = sqrt(eps); # eps is machine precision
	DIFF_EPS = exp(log(eps)/2);
	DIFF_EPS1 = exp(log(eps)/3);
	DIFF_EPS2 = exp(log(eps)/4);
	if (order == 0)
		diff = DIFF_EPS;
	elseif (order == 1)
		diff = DIFF_EPS1;
	else
		diff = DIFF_EPS2;
	endif
    d = max( (abs(x) + SQRT_EPS) * SQRT_EPS, diff);
endfunction
#========================= END FiniteDifference ==========================
