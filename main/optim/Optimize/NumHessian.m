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
 
#============================= NumHessian =============================
# Inspired by Ox 3.20 (Doornik)
function derivative = NumHessian(f, args)

	if !iscell(args) args = {args}; endif
	parameter = args{1};

    k = rows(parameter);
	obj_value = feval(f, args);
	if iscell(obj_value) obj_value = obj_value{1}; endif
    derivative = zeros(k, k);

    for i = 1:k    # approximate 2nd deriv. by central difference 
        pi = parameter(i);
        hi = FiniteDifference(pi, 2);
        for j = 1:(i-1)       # off-diagonal elements 
		    pj = parameter(j);
            hj = FiniteDifference(pj,2);
			
            parameter(i) = di = pi + hi;  parameter(j) = dj = pj + hj; # +1 +1
			hia = di - pi;   hja = dj - pj;
       		args{1} = parameter;
			fpp = feval(f, args);
			if iscell(fpp) fpp = fpp{1}; endif
			parameter(i) = di = pi - hi;  parameter(j) = dj = pj - hj;     # -1 -1 
			hia = hia + pi - di;   hja = hja + pj - dj;
       		args{1} = parameter;
			fmm = feval(f, args);
			if iscell(fmm) fmm = fmm{1}; endif
			
            parameter(i) = pi + hi;  parameter(j) = pj - hj;               # +1 -1
       		args{1} = parameter;
			fpm = feval(f, args);
			if iscell(fpm) fpm = fpm{1}; endif

            parameter(i) = pi - hi;  parameter(j) = pj + hj;               # -1 +1 
       		args{1} = parameter;
			fmp = feval(f, args);
			if iscell(fmp) fmp = fmp{1}; endif
            derivative(j,i) = ((fpp - fpm) + (fmm - fmp)) / (hia * hja);
			derivative(i,j) = derivative(j,i);

            parameter(j) = pj;
		endfor

		# diagonal elements 
        parameter(i) = di = pi + 2 * hi;           	                   # +1 +1 
   		args{1} = parameter;
		fpp = feval(f, args);
		if iscell(fpp) fpp = fpp{1}; endif		

		hia = (di - pi) / 2;

        parameter(i) = di = pi - 2 * hi;           	                   # -1 -1 
   		args{1} = parameter;
		fmm = feval(f, args);
		if iscell(fmm) fmm = fmm{1}; endif
		hia = hia + (pi - di) / 2;

        derivative(i,i) = ((fpp - obj_value) + (fmm - obj_value)) / (hia * hia);

        parameter(i) = pi;
    endfor
endfunction
#============================ END NumHessian ==========================
