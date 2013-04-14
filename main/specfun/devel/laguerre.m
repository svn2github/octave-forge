## Copyright (C) 2007 Muthiah Annamalai
## Copyright (C) 2008 Eric Chassande-Mottin
## Copyright (C) 2013 Juan Pablo Carbajal
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## Editor: Juan Pablo Carbajal <ajuanpi+dev@gmail.com>
## Muthiah Annamalai <muthiah.annamalai@uta.edu>

## -*- texinfo -*-
## @deftypefn {Function File} {@var{coefs}=} laguerrepoly (@var{order})
## @deftypefnx {Function File} {[@var{y} @var{coefs}]=} laguerrepoly (@var{order},@var{x})
##
## Compute the coefficients of the Laguerre polynomial, given the
## @var{order}. We calculate the Laguerre polynomial using the recurrence
## relations, Ln+1(x) = inv(n+1)*((2n+1-x)Ln(x) - nLn-1(x)).
##
## If the value @var{x} is specified, the polynomial is also evaluated,
## otherwise just the return the coefficients of the polynomial are returned.
##
## This is NOT the generalized Laguerre polynomial.
##
## @end deftypefn

function varargout = laguerre (order,t)

  if nargin < 1 || nargin > 2
    print_usage
  endif

  if order < 0 || ~isscalar (order)
    error("Octave:invalid-input-arg","Argument 'order' must be a positive integer");
  endif

  h_prev = [0 1];
  h_now  = [-1 1];

  if order == 0
    h = h_prev;
  else
    h = h_now;
  endif

  for ord = 2:order
    x = y = [];

    if length (h_now) < (1+ord)
      x = 0;
    endif

    y  = zeros (1,(1+ord)-length(h_prev));
    p1 = [h_now, x];
    p2 = [x, h_now];
    p3 = [y, h_prev];
    h  = ((2*ord -1).*p2 -p1 -(ord -1).*p3)./(ord);

    h_prev = h_now;
    h_now  = h;
  endfor

  if nargin == 1
    varargout{1} = h;
  elseif nargin == 2
    varargout{1} = polyval (h,t);
    varargout{2} = h;
  endif

endfunction

%!demo
%! x = linspace(0,10,1e3)';
%! order = 0:5;
%! y = cell2mat (arrayfun (@(n)laguerre(n,x),order, "UniformOutput", false));
%!
%! close all
%! h = figure(1);
%! set (h, "Name", "Laguerre polynomials");
%! h = plot(x,y,"-");
%! title ("Laguerre Polynomials")
%! set (h, "LineWidth",2);
%! ltxt = arrayfun (@(x)sprintf("L%d",x), order, "UniformOutput", false);
%! h = legend(ltxt); ...
%! set (h,"Location","northwest", "Box","off");
%! axis ([0 10 -10 20])
%!
%! # -------------------------------------------------
%! # Laguerre polynomials up to order 5 in the [0 10]
%! # interval.

%!test
%! x=rand;
%! y1=laguerre(0,x);
%! p0=[1];
%! y2=polyval(p0,x);
%! assert(y1-y2,0,eps);

%!test
%! x=rand;
%! y1=laguerre(1,x);
%! p1=[-1 1];
%! y2=polyval(p1,x);
%! assert(y1-y2,0,eps);

%!test
%! x=rand;
%! y1=laguerre(2,x);
%! p2=[.5 -2 1];
%! y2=polyval(p2,x);
%! assert(y1-y2,0,eps);

%!test
%! x=rand;
%! y1=laguerre(3,x);
%! p3=[-1/6 9/6 -18/6 1];
%! y2=polyval(p3,x);
%! assert(y1-y2,0,eps);

%!test
%! x=rand;
%! y1=laguerre(4,x);
%! p4=[1/24 -16/24 72/24 -96/24 1];
%! y2=polyval(p4,x);
%! assert(y1-y2,0,eps);
