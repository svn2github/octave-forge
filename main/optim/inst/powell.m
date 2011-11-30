## Copyright (C) 2011  Nir Krakauer
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{p}, @var{obj_value}, @var{convergence}, @var{iters}, @var{nevs}] = powell (@var{f}, @var{p0}, @var{control})
##powell: implements a direction-set (Powell's) method for multidimensional minimization of a function without calculation of the gradient [1, 2]
##
## @subheading Arguments
##
## @itemize @bullet
## @item
## @var{f}: name of function to minimize (string or handle), which should accept one input variable (see example for how to pass on additional input arguments)
##
## @item
## @var{p0}: An initial value of the function argument to minimize
##
## @item
## @var{options}: an optional structure, which can be generated by optimset, with some or all of the following fields:
## @itemize @minus
## @item
##	MaxIter: maximum iterations  (positive integer, or -1 or Inf for unlimited (default))
## @item
##	TolFun: minimum amount by which function value must decrease in each iteration to continue (default is 1E-8)
## @item
##	MaxFunEvals: maximum function evaluations  (positive integer, or -1 or Inf for unlimited (default))
## @item
##	SearchDirections: an n*n matrix whose columns contain the initial set of (presumably orthogonal) directions to minimize along, where n is the number of elements in the argument to be minimized for; or an n*1 vector of magnitudes for the initial directions (defaults to the set of unit direction vectors)
## @end itemize
## @end itemize
##
## @subheading Examples
##
## @example
## @group
## y = @@(x, s) x(1) ^ 2 + x(2) ^ 2 + s;
## o = optimset('MaxIter', 100, 'TolFun', 1E-10);
## s = 1;
## [x_optim, y_min, conv, iters, nevs] = powell(@@(x) y(x, s), [1 0.5], o); %pass y wrapped in an anonymous function so that all other arguments to y, which are held constant, are set
## %should return something like x_optim = [4E-14 3E-14], y_min = 1, conv = 1, iters = 2, nevs = 24
## @end group
##
## @end example
##
## @subheading Returns:
##
## @itemize @bullet
## @item
## @var{p}: the minimizing value of the function argument
## @item
## @var{obj_value}: the value of @var{f}() at @var{p}
## @item
## @var{convergence}: 1 if normal convergence, 0 if not
## @item
## @var{iters}: number of iterations performed
## @item
## @var{nevs}: number of function evaluations
## @end itemize
##
## @subheading References
##
## @enumerate
## @item
## Powell MJD (1964), An efficient method for finding the minimum of a function of several variables without calculating derivatives, @cite{Computer Journal}, 7 :155-162
##
## @item
## Press, WH; Teukolsky, SA; Vetterling, WT; Flannery, BP (1992). @cite{Numerical Recipes in Fortran: The Art of Scientific Computing} (2nd Ed.). New York: Cambridge University Press (Section 10.5)
## @end enumerate
## @end deftypefn

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>
## Description: Multidimensional minimization (direction-set method)

## PKG_ADD: __all_opts__ ("powell");

function [p, obj_value, convergence, iters, nevs] = powell (f, p0, options);

  if (nargin == 1 && ischar (f) && strcmp (f, "defaults"))
    p = optimset ("MaxIter", Inf, \
		  "TolFun", 1e-8, \
		  "MaxFunEvals", Inf, \
		  "SearchDirections", []);
    return;
  endif

  ## check number of arguments
  if ((nargin < 2) || (nargin > 3))
    usage('powell: you must supply 2 or 3 arguments');
  endif

	
  ## default or input values
	
  if (nargin < 3)
    options = struct ();
  endif
	
  xi_set = 0;
  xi = optimget (options, 'SearchDirections');
  if (! isempty (xi))
    if (isvector (xi)) # assume that xi is is n*1 or 1*n
      xi = diag (x);
    endif
    xi_set = 1;
  endif
	

  MaxIter = optimget (options, 'MaxIter', Inf);
  if (MaxIter < 0) MaxIter = Inf; endif
  MaxFunEvals = optimget (options, 'MaxFunEvals', Inf);
  TolFun = optimget (options, 'TolFun', 1E-8);		
				
  nevs = 0;
  iters = 0;
  convergence = 0;

  p = p0; # initial value of the argument being minimized
	
  try
    obj_value = f(p);
  catch
    error ("function does not exist or cannot be evaluated");
  end_try_catch
	
  nevs++;
	
  n = numel (p); # number of dimensions to minimize over
	
  xit = zeros (n, 1);
  if (! xi_set)
    xi = eye(n);
  endif
	

	
  ## do an iteration
  while (iters <= MaxIter && nevs <= MaxFunEvals && ! convergence)
    iters++;
    pt = p; # best point as iteration begins
    fp = obj_value; # value of the objective function as iteration begins
    ibig = 0; # will hold direction along which the objective function decreased the most in this iteration
    dlt = 0; # will hold decrease in objective function value in this iteration
    for i = 1:n
      xit = reshape (xi(:, i), size(p));
      fptt = obj_value;
      [a, obj_value, nev] = line_min (f, xit, {p});
      nevs = nevs + nev;
      p = p + a*xit;
      change = fptt - obj_value;
      if (change > dlt)
	dlt = change;
	ibig = i;
      endif
    endfor
		
    if ( 2*abs(fp-obj_value) <= TolFun*(abs(fp) + abs(obj_value)) )
      convergence = 1;
      return
    endif
		
    if (iters == MaxIter)
      disp ("iteration maximum exceeded");
      return
    endif
		
    ## attempt parabolic extrapolation
    ptt = 2*p - pt;
    xit = p - pt;
    fptt = f(ptt);
    nevs++;
    if (fptt < fp) # check whether the extrapolation actually makes the objective function smaller
      t = 2 * (fp - 2*obj_value + fptt) * (fp-obj_value-dlt)^2 - dlt * (fp-fptt)^2;
      if (t < 0)
	p = ptt;
	[a, obj_value, nev] = line_min (f, xit, {p});
	nevs = nevs + nev;
	p = p + a*xit;
				
	## add the net direction from this iteration to the direction set
	xi(:, ibig) = xi(:, n);
	xi(:, n) = xit(:);
      endif
    endif
  endwhile
			
