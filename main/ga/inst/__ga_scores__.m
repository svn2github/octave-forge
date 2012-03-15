## Copyright (C) 2008, 2010 Luca Favatella <slackydeb@gmail.com>
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

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.5.1

function Scores = __ga_scores__ (problem, Population)
  if (strcmp (problem.options.Vectorized, "on")) ## using vectorized evaluation
    if (strcmp (problem.options.UseParallel, "always"))
      warning ("'Vectorized' option is 'on': ignoring 'UseParallel' \
          option, even if it is 'always'");
    endif
    Scores = problem.fitnessfcn (Population);
  else ## not using vectorized evaluation
    if (! strcmp (problem.options.Vectorized, "off"))
      error ("'Vectorized' option must be 'on' or 'off'");
    endif
    if (strcmp (problem.options.UseParallel, "always")) ## using parallel evaluation
      error ("TODO: implement parallel evaluation of objective function");
    else ## using serial evaluation (i.e. loop)
      if (! strcmp (problem.options.UseParallel, "never"))
        error ("'UseParallel' option must be 'always' or 'never'");
      endif
      [nrP ncP] = size (Population);
      tmp = zeros (nrP, 1);
      for index = 1:nrP
        tmp(index, 1) = problem.fitnessfcn (Population(index, 1:ncP));
      endfor
      Scores = tmp(1:nrP, 1);
    endif
  endif
endfunction