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

function [theta, V, obj_value] = gmm_results(theta, data, weight, moments, momentargs, names, title, unscale, control)
	
	if nargin < 9
		[theta, obj_value, convergence] = gmm_estimate(theta, data, weight, moments, momentargs);
	else
		[theta, obj_value, convergence] = gmm_estimate(theta, data, weight, moments, momentargs, control);
	endif


	m = feval(moments, theta, data, momentargs); # find out how many obsns. we have
	n = rows(m);

	if convergence == 1
		convergence="Normal convergence";
	else
		convergence="No convergence";
	endif	
	
	V = gmm_variance(theta, data, weight, moments, momentargs);

	# unscale results if argument has been passed
	# this puts coefficients into scale corresponding to the original data
	if nargin > 7 
		if iscell(unscale)
			[theta, V] = unscale_parameters(theta, V, unscale);
		endif
	endif

	[theta, V] = delta_method("Parameterize", theta, {data, moments, momentargs}, V);			

	n = rows(data);
	k = rows(theta);
	se = sqrt(diag(V));
	
	printf("\n\n******************************************************\n");
	disp(title);
	printf("\nGMM Estimation Results\n");
	printf("BFGS convergence: %s\n", convergence);
	printf("\nObjective function value: %f\n", obj_value);
	printf("Observations: %d\n", n);

	junk = "X^2 test";
	df = rows(weight) - rows(theta);
	if df > 0
		clabels = str2mat("Value","df","p-value");
		a = [n*obj_value, df, 1 - chisquare_cdf(n*obj_value, df)];
		printf("\n");
		prettyprint(a, junk, clabels);
	else
		disp("\nExactly identified, no spec. test");
	end;	

	# results for parameters				
	a =[theta, se, theta./se, 2 - 2*normal_cdf(abs(theta ./ se))];
	clabels = str2mat("estimate", "st. err", "t-stat", "p-value");
	printf("\n");
	prettyprint(a, names, clabels);
	
	printf("******************************************************\n");
endfunction
