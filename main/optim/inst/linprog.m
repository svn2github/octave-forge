## Copyright (C) 2009 Luca Favatella <slackydeb@gmail.com>
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
## @deftypefn{Function File} {@var{x} =} linprog (@var{f}, @var{A}, @var{b})
## @deftypefnx{Function File} {@var{x} =} linprog (@var{f}, @var{A}, @var{b}, @var{Aeq}, @var{beq})
## @deftypefnx{Function File} {@var{x} =} linprog (@var{f}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{LB})
## @deftypefnx{Function File} {@var{x} =} linprog (@var{f}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{LB}, @var{UB})
## @deftypefnx{Function File} {[@var{x}, @var{fval}] =} linprog (@dots{})
## Solve a linear problem. @code{linprog} solves the following LP:
##
## @example
## min f'*x
## @end example
##
## subject to
##
## @example
## @group
## A*x <= b
## Aeq*x = beq
## x >= LB
## x <= UB
## @end group
## @end example
##
## The default @var{Aeq} and @var{beq} are assumed to be empty matrices.
##
## The default lower bound @var{LB} is assumed to be minus infinite; the
## default upper bound @var{UB} is assumed to be infinite.
##
## @seealso{glpk}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 0.3.1

                                # TODO: write a test using not null and
                                # not zero Aeq and beq

function [x fval] = linprog (f, A, b,
                             Aeq = [], beq = [],
                             LB = [], UB = [])

  if ((nargin < 3) || (nargin == 4) || (nargin > 7) ||
      (nargout > 2) ||
      (! isvector (f)))
    print_usage ();
  else

    l_f = length(f);
    nr_A = rows (A);
    nr_Aeq = rows (Aeq);

    if (isempty (Aeq))
      Aeq = zeros (0, l_f);
    endif
    if (isempty (beq))
      beq = zeros (0, 1);
    endif

    if (isempty (LB))
      LB = - inf (1, l_f);
    endif
    if (isempty (UB))
      UB = inf (1, l_f);
    endif

    ctype = [(repmat ("U", nr_A, 1));
             (repmat ("S", nr_Aeq, 1))];
    [x fval] = glpk (f(1:l_f),
                     [A(1:nr_A, 1:l_f); Aeq(1:nr_Aeq, 1:l_f)],
                     [b(1:nr_A, 1); beq(1:nr_Aeq, 1)],
                     LB(1:l_f),
                     UB(1:l_f),
                     ctype);

  endif

endfunction


%!shared f, A, b, LB, expected
%! f = [21 25 31 34  23 19 32  36 27 25 19];
%! A1 = [1 0 0 0  1 0 0  1 0 0 0; 0 1 0 0  0 1 0  0 1 0 0; 0 0 1 0  0 0 0  0 0 1 0; 0 0 0 1  0 0 1  0 0 0 1];
%! A2 = [1 1 1 1  0 0 0  0 0 0 0; 0 0 0 0  1 1 1  0 0 0 0; 0 0 0 0  0 0 0  1 1 1 1];
%! A = [-A1; A2];
%! b1 = [40; 50; 50; 70];
%! b2 = [100; 60; 50];
%! b = [-b1; b2];
%! LB = zeros (1, 11);
%! expected = [40; 0; 50; 10; 0; 50; 10; 0; 0; 0; 50];
%!
%!assert (linprog (f, A, b, [], [], LB), expected);
%!assert (linprog (f, A, b, zeros (1, 11), 0, LB), expected);