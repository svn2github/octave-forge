## Copyright (C) 2012 Luca Favatella <slackydeb@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Script File} {} demo_ga
## Run a demo of the genetic algorithm package.  The current
## implementation is only a placeholder.
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Created: March 2012
## Version: 0.0.4

demo demo_ga


%!demo
%! % TODO


## This code is a simple example of the usage of ga
                                # TODO: convert to demo
# %!xtest assert (ga (@rastriginsfcn, 2), [0, 0], 1e-3)


## This code shows that ga optimizes also functions whose minimum is not
## in zero
                                # TODO: convert to demo
# %!xtest
# %! min = [-1, 2];
# %! assert (ga (struct ("fitnessfcn", @(x) rastriginsfcn (x - min), "nvars", 2, "options", gaoptimset ("FitnessLimit", 1e-7, "Generations", 1000, "PopInitRange", [-5; 5], "PopulationSize", 200))), min, 1e-5)


## This code shows that the "Vectorize" option usually speeds up execution
                                # TODO: convert to demo
# %!test
# %!
# %! tic ();
# %! ga (struct ("fitnessfcn", @rastriginsfcn, "nvars", 2, "options", gaoptimset ("Generations", 10, "PopulationSize", 200)));
# %! elapsed_time = toc ();
# %!
# %! tic ();
# %! ga (struct ("fitnessfcn", @rastriginsfcn, "nvars", 2, "options", gaoptimset ("Generations", 10, "PopulationSize", 200, "Vectorized", "on")));
# %! elapsed_time_with_vectorized = toc ();
# %!
# %! assert (elapsed_time > elapsed_time_with_vectorized);

## The "UseParallel" option should speed up execution
                                # TODO: write demo (after implementing
                                # UseParallel) - low priority


## This code shows a more complex objective function
                                # TODO: convert to demo
# %!test x = ga (struct ("fitnessfcn", @(x) rastriginsfcn (x(1:2)) + ((x(3) ** 2) - (cos (2 * pi * x(3))) + 1) + (x(4) ** 2), "nvars", 4, "options", gaoptimset ()));


## TODO: these should probably become tests (test, not xtest) using a deterministic sequence of random number 
##
## simple optimization result checks. Failures here could happen because
## of non-determinism in the result but if one of these tests always
## fails for you, plese consider dropping an email to the octave-forge
## mailing list <octave-dev@lists.sourceforge.net>.
# %!function f = ff (min)
# %!  f = @(x) sum ((x(:, 1:(columns (min))) - repmat (min,
# %!                                                   rows (x), 1)) .** 2, 2);
# %!function [C, Ceq] = nonlcon (x)
# %!  C = [];
# %!  Ceq = [];
# %!function r = rand_porcelain (interval_min, interval_max, nvars)
# %!  assert (interval_min < interval_max);
# %!  r = interval_min + ((interval_max - interval_min) * rand (1, nvars));
# %!function t = tol (nvars)
# %!  t = repelems (0.15, [1; nvars]);
# %!xtest
# %! nvars = 1;
# %! minimum = zeros (1, nvars);
# %! assert (ga (ff (minimum), nvars), minimum, tol (nvars));
# %!xtest
# %! nvars = 2;
# %! minimum = zeros (1, nvars);
# %! assert (ga (ff (minimum), nvars), minimum, tol (nvars));
# %!xtest
# %! nvars = 3;
# %! minimum = zeros (1, nvars);
# %! assert (ga (ff (minimum), nvars), minimum, tol (nvars));
# %!xtest
# %! nvars = 1;
# %! minimum = ones (1, nvars);
# %! assert (ga (ff (minimum), nvars), minimum, tol (nvars));
# %!xtest
# %! nvars = 2;
# %! minimum = ones (1, nvars);
# %! assert (ga (ff (minimum), nvars), minimum, tol (nvars));
# %!xtest
# %! nvars = 3;
# %! minimum = ones (1, nvars);
# %! assert (ga (ff (minimum), nvars), minimum, tol (nvars));
# %!xtest
# %! nvars = 1;
# %! interval_min = -10;
# %! interval_max =  10;
# %! minimum = - rand_porcelain (interval_min, interval_max, nvars);
# %! options = gaoptimset ("PopInitRange", 2 .* [interval_min; interval_max],
# %!                       "CrossoverFraction", 0.2);
# %! x = ga (ff (minimum), nvars, [], [], [], [], [], [], @nonlcon, options);
# %! assert (x, minimum, 4 .* tol (nvars));
# %!xtest
# %! nvars = 2;
# %! interval_min = -10;
# %! interval_max =  10;
# %! minimum = - rand_porcelain (interval_min, interval_max, nvars);
# %! options = gaoptimset ("PopInitRange", 2 .* [interval_min; interval_max],
# %!                       "CrossoverFraction", 0.2);
# %! x = ga (ff (minimum), nvars, [], [], [], [], [], [], @nonlcon, options);
# %! assert (x, minimum, 4 .* tol (nvars));
# %!xtest
# %! nvars = 3;
# %! interval_min = -10;
# %! interval_max =  10;
# %! minimum = - rand_porcelain (interval_min, interval_max, nvars);
# %! options = gaoptimset ("PopInitRange", 2 .* [interval_min; interval_max],
# %!                       "CrossoverFraction", 0.2);
# %! x = ga (ff (minimum), nvars, [], [], [], [], [], [], @nonlcon, options);
# %! assert (x, minimum, 4 .* tol (nvars));
