## Copyright (C) 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {@var{L} =} dtmc_exps (@var{P}, @var{n}, @var{p0})
## @deftypefnx {Function File} {@var{L} =} dtmc_exps (@var{P}, @var{p0})
##
## @cindex Time-alveraged sojourn time
##
## Compute the @emph{time-averaged sojourn time} @code{@var{M}(i)},
## defined as the fraction of time steps @math{@{0, 1, @dots{}, n@}} (or
## until absorption) spent in state @math{i}, assuming that the state
## occupancy probabilities at time 0 are @var{p0}.
##
## @strong{INPUTS}
##
## @table @var
##
## @item Q
## Infinitesimal generator matrix. @code{@var{Q}(i,j)} is the transition
## rate from state @math{i} to state @math{j},
## @math{1 @leq{} i \neq j @leq{} N}. The
## matrix @var{Q} must also satisfy the condition @math{\sum_{j=1}^N Q_{ij} = 0}
##
## @item t
## Time. If omitted, the results are computed until absorption.
##
## @item p
## @code{@var{p}(i)} is the probability that, at time 0, the system was in
## state @math{i}, for all @math{i = 1, @dots{}, N}
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item M
## If this function is called with three arguments, @code{@var{M}(i)}
## is the expected fraction of the interval @math{[0,t]} spent in state
## @math{i} assuming that the state occupancy probability at time zero
## is @var{p}. If this function is called with two arguments,
## @code{@var{M}(i)} is the expected fraction of time until absorption
## spent in state @math{i}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function M = dtmc_taexps( P, varargin )

  persistent epsilon = 10*eps;

  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif

  L = dtmc_exps(P,varargin{:});
  M = L ./ sum(L);
endfunction
%!test
%! P = dtmc_bd([1 1 1 1], [0 0 0 0]);
%! p0 = [1 0 0 0 0];
%! L = dtmc_taexps(P,p0);
%! assert( L, [.25 .25 .25 .25 0], 10*eps );

