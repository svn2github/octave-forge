# Copyright (C) 2003,2004,2005  Michael Creel <michael.creel@uab.es>
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

# usage: [theta, V, obj_value, infocrit] = 
#    mle_results(theta, data, model, modelargs, names, title, unscale, control)
#
# inputs:
# theta: column vector of model parameters
# data: data matrix
# model: name of function that computes log-likelihood
# modelargs: (cell) additional inputs needed by model. May be empty ("")
# names: vector of parameter names, e.g., use names = str2mat("param1", "param2");
# title: string, describes model estimated
# unscale: (optional) cell that holds means and std. dev. of data (see scale_data) 
# control: (optional) BFGS or SA controls (see bfgsmin and samin). May be empty (""). 
# nslaves: (optional) number of slaves if executed in parallel (requires MPITB)
#
# outputs:
# theta: ML estimated value of parameters
# obj_value: the value of the log likelihood function at ML estimate
# conv: return code from bfgsmin (1 means success, see bfgsmin for details)
# iters: number of BFGS iteration used


##
## Please see mle_example for information on how to use this
 
# report results
function [theta, V, obj_value, infocrit] = mle_results(theta, data, model, modelargs, names, title, unscale, control, nslaves)
	if nargin < 9 nslaves = 0; endif # serial by default
	if nargin < 8
		[theta, obj_value, convergence] = mle_estimate(theta, data, model, modelargs, "", nslaves);
	else
		[theta, obj_value, convergence] = mle_estimate(theta, data, model, modelargs, control, nslaves);
	endif
	V = mle_variance(theta, data, model, modelargs);

	# unscale results if argument has been passed
	# this puts coefficients into scale corresponding to the original modelargs
	if (nargin > 5)
    		if iscell(unscale) # don't try it if unscale is simply a placeholder
			[theta, V] = unscale_parameters(theta, V, unscale);
    		endif
	endif

	[theta, V] = delta_method("parameterize", theta, {data, model, modelargs}, V);			

	n = rows(data);
	k = rows(V);
	se = sqrt(diag(V));
	if convergence == 1 convergence="Normal convergence";
  	elseif convergence == 2 convergence="No convergence";
	elseif convergence == -1 convergence = "Max. iters. exceeded";
	endif	
	printf("\n\n******************************************************\n");
	disp(title);
	printf("\nMLE Estimation Results\n");
	printf("BFGS convergence: %s\n\n", convergence);

	printf("Average Log-L: %f\n", obj_value);
	printf("Observations: %d\n", n);	      
	a =[theta, se, theta./se, 2 - 2*normal_cdf(abs(theta ./ se))];

	clabels = str2mat("estimate", "st. err", "t-stat", "p-value");

	printf("\n");
	if names !=0 prettyprint(a, names, clabels);
	else prettyprint_c(a, clabels);
	endif

	printf("\nInformation Criteria \n");
	caic = -2*n*obj_value + rows(theta)*(log(n)+1);
	bic = -2*n*obj_value + rows(theta)*log(n);
	aic = -2*n*obj_value + 2*rows(theta);
	infocrit = [caic, bic, aic];
	printf("CAIC : %8.4f      Avg. CAIC: %8.4f\n", caic, caic/n);
	printf(" BIC : %8.4f       Avg. BIC: %8.4f\n", bic, bic/n);
	printf(" AIC : %8.4f       Avg. AIC: %8.4f\n", aic, aic/n);
	printf("******************************************************\n");
endfunction
