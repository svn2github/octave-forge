function cvscore = kernel_density_cvscore(bandwidth, data, depvar)
		dens = kernel_density(data, data, exp(bandwidth), true);
		dens = dens + eps; # some kernels can assign zero density
		cvscore = -mean(log(dens));
endfunction

