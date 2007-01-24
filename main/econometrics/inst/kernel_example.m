# Copyright (C) 2007 Michael Creel <michael.creel@uab.es>
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

# kernel_example: examples of how to use kernel density and regression functions
#
# usage: kernel_example;

# sample size - should get better fit (on average) as this increases
n = 500;

# set this to greater than 0 to try parallel computations (requires MPITB)
compute_nodes = 0;

nodes = compute_nodes + 1; # count master node

############################################################
# kernel regression example
# uniformly spaced data points on [0,2]
x = 1:n;
x = x';
x = 2*x/n;
# generate dependent variable
trueline =  x + (x.^2)/2 - 3.1*(x.^3)/3 + 1.2*(x.^4)/4;
sig = 0.5;
y = trueline + sig*randn(n,1);
# default bandwidth
bandwidth = 0.45;
# get optimal bandwidth (time consuming, uncomment if you want to try it)
# bandwidth = kernel_optimal_bandwidth(x, y);
# get the fit and do the plot
tic;
fit = kernel_regression(x, y, x, bandwidth, false, compute_nodes);
t1 = toc;
printf("\n");
printf("########################################################################\n");
printf("Kernel regression example\n");
printf("time using %d data points and %d compute nodes: %f\n", n, nodes, t1);
grid("on");
title("Example 1: Kernel regression fit");
plot(x, fit, x, trueline);

############################################################
# kernel density example: univariate - fit to Chi^2(3) data
data = sumsq(randn(n,3),2);
# evaluation point are on a grid for plotting
stepsize = 0.2;
grid_x = (-1:stepsize:11)';
bandwidth = 0.55;
# get optimal bandwidth (time consuming, uncomment if you want to try it)
# bandwidth = kernel_optimal_bandwidth(data);
# get the fitted density and do a plot
tic;
dens = kernel_density(grid_x, data, bandwidth, false, compute_nodes);
t1 = toc;
printf("\n");
printf("########################################################################\n");
printf("Univariate kernel density example\n");
printf("time using %d data points and %d compute nodes: %f\n", n, nodes, t1);
printf("A rough integration under the fitted univariate density is %f\n", sum(dens)*stepsize);
figure();
title("Example 2: Kernel density fit: Univariate Chi^2(3) data");
xlabel("true density is Chi^2(3)");
plot(grid_x, [dens chisquare_pdf(grid_x,3)]);

############################################################
# kernel density example: bivariate
# X ~ N(0,1)
# Y ~ Chi squared(3)
# X, Y are dependent
d = randn(n,3);
data = [d(:,1) sumsq(d,2)];
# evaluation points are on a grid for plotting
stepsize = 0.2;
a = (-5:stepsize:5)'; # for the N(0,1)
b = (-1:stepsize:9)';  # for the Chi squared(3)
gridsize = rows(a);
[grid_x, grid_y] = meshgrid(a, b);
eval_points = [vec(grid_x) vec(grid_y)];
bandwidth = 0.85;
# get optimal bandwidth (time consuming, uncomment if you want to try it)
# bandwidth = kernel_optimal_bandwidth(data);
# get the fitted density and do a plot
tic;
dens = kernel_density(eval_points, data, bandwidth, false, compute_nodes);
t1 = toc;
printf("\n");
printf("########################################################################\n");
printf("Multivatiate kernel density example\n");
printf("time using %d data points and %d compute nodes: %f\n", n, nodes, t1);
dens = reshape(dens, gridsize, gridsize);
printf("A rough integration under the fitted bivariate density is %f\n", sum(sum(dens))*stepsize^2);
figure();
legend("off");
title("Example 3: Kernel density fit: dependent bivatiate data");
xlabel("true marginal density is N(0,1)");
ylabel("true marginal density is Chi^2(3)");
surf(grid_x, grid_y, dens);


# more extensive test of parallel
if compute_nodes > 0 # only try this if parallel is available
	############################################################
	# kernel density example: bivariate
	# X ~ N(0,1)
	# Y ~ Chi squared(3)
	# X, Y are dependent
	# evaluation points are on a grid for plotting
	stepsize = 0.2;
	a = (-5:stepsize:5)'; # for the N(0,1)
	b = (-1:stepsize:9)';  # for the Chi squared(3)
	gridsize = rows(a);
	[grid_x, grid_y] = meshgrid(a, b);
	eval_points = [vec(grid_x) vec(grid_y)];
	bandwidth = 0.85;
	ns = [1000; 2000; 4000; 8000];
	printf("\n");
	printf("########################################################################\n");
	printf("multivariate kernel density example with several sample sizes serial/parallel timings\n");
	for i = 1:rows(ns)
		for compute_nodes = 0:1
			nodes = compute_nodes + 1;
			n = ns(i,:);
			d = randn(n,3);
			data = [d(:,1) sumsq(d,2)];
			tic;
			dens = kernel_density(eval_points, data, bandwidth, false, compute_nodes);
			t1 = toc;
			printf(" %d data points and %d compute nodes: %f\n", n, nodes, t1);
		endfor
	endfor
endif