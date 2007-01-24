function cvscore = kernel_regression_cvscore(bandwidth, data, depvar)
	fit = kernel_regression(data, depvar, data, exp(bandwidth), true);
	cvscore = norm(depvar - fit);
endfunction

