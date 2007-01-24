function bandwidth = kernel_optimal_bandwidth(data, depvar)
	# SA controls
	ub = 1;
	lb = -5;
	nt = 1;
	ns = 1;
	rt = 0.05;
	maxevals = 50;
	neps = 5;
	functol = 1e-2;
	paramtol = 1e-3;
	verbosity = 0;
	minarg = 1;
	sa_control = { lb, ub, nt, ns, rt, maxevals, neps, functol, paramtol, verbosity, 1};

	# bfgs controls
	bfgs_control = {100,0,0};

	if (nargin == 1)
		bandwidth = samin("kernel_density_cvscore", {0, data}, sa_control);
		bandwidth = bfgsmin("kernel_density_cvscore", {bandwidth, data}, bfgs_control);
	else
		bandwidth = samin("kernel_regression_cvscore", {0, data, depvar}, sa_control);
		bandwidth = bfgsmin("kernel_regression_cvscore", {bandwidth, data, depvar}, bfgs_control);
	endif
	bandwidth = exp(bandwidth);
endfunction
