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
## Version: 0.0.3

demo ga_demo


%!demo
%! % TODO


## This code is a simple example of the usage of ga
                                # TODO: convert to demo
%!xtest assert (ga (@rastriginsfcn, 2), [0, 0], 1e-3)


## This code shows that ga optimizes also functions whose minimum is not
## in zero
                                # TODO: convert to demo
%!xtest
%! min = [-1, 2];
%! assert (ga (struct ("fitnessfcn", @(x) rastriginsfcn (x - min), "nvars", 2, "options", gaoptimset ("FitnessLimit", 1e-7, "Generations", 1000, "PopInitRange", [-5; 5], "PopulationSize", 200))), min, 1e-5)


## This code shows that the "Vectorize" option usually speeds up execution
                                # TODO: convert to demo
%!test
%!
%! tic ();
%! ga (struct ("fitnessfcn", @rastriginsfcn, "nvars", 2, "options", gaoptimset ("Generations", 10, "PopulationSize", 200)));
%! elapsed_time = toc ();
%!
%! tic ();
%! ga (struct ("fitnessfcn", @rastriginsfcn, "nvars", 2, "options", gaoptimset ("Generations", 10, "PopulationSize", 200, "Vectorized", "on")));
%! elapsed_time_with_vectorized = toc ();
%!
%! assert (elapsed_time > elapsed_time_with_vectorized);

## The "UseParallel" option should speed up execution
                                # TODO: write demo (after implementing
                                # UseParallel) - low priority
