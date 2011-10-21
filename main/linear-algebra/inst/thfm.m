## Copyright (C) 2001 Rolf Fabian <fabian@tu-cottbus.de>
## Copyright (C) 2001 Paul Kienzle <pkienzle@users.sf.net>
## Copyright (C) 2011 Philip Nienhuis <pr.nienhuis@hccnet.nl>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{y} =} thfm (@var{x}, @var{mode})
## Trigonometric/hyperbolic functions of square matrix @var{x}.
##
## @var{mode} must be the name of a function. Valid functions are 'sin', 'cos',
## 'tan', 'sec', 'csc', 'cot' and all their inverses and/or hyperbolic variants,
## and 'sqrt', 'log' and 'exp'.
##
## The code @code{thfm( x ,'cos' )} calculates matrix cosinus @emph{even if} input
## matrix @var{x} is @emph{not} diagonalizable.
##
## @heading{Important note}
## This algorithm does @emph{not use} an eigensystem similarity transformation. It
## maps the @var{mode} functions to functions of @code{expm}, @code{logm} and
## @code{sqrtm}, which are known to be robust with respect to non-diagonalizable
## ('defective') @var{x}.
##
## @seealso{funm}
## end deftypefn

function y = thfm (x,M)
  #% minimal arg check only
  if ( nargin ~= 2 || ~ischar (M) || ischar (x) )
    print_usage;
  endif

  ## look for known functions of sqrt, log, exp
  I = eye(size(x));
  match = 1;
  len =  length(M);
  if	len==3
    
    if	M=='cos',
      if (isreal(x))     y = real( expm( i*x ) );
      else               y = ( expm( i*x ) + expm( -i*x ) ) / 2;
      endif
      
    elseif	M=='sin',
      if (isreal(x))     y = imag( expm( i*x ) );
      else               y = ( expm( i*x ) - expm( -i*x ) ) / (2*i);
      endif
      
    elseif	M=='tan',
      if (isreal(x))     t = expm( i*x );    y = imag(t)/real(t);
      else     	         t = expm( -2*i*x ); y = -i*(I-t)/(I+t);
      endif
      
    elseif	M=='cot',		% == cos/sin
      if (isreal(x))     t = expm( i*x );    y = real(t)/imag(t);
      else	         t = expm( -2*i*x ); y = i*(I+t)/(I-t);
      endif
      
    elseif	M=='sec',
      if (isreal(x))     y = inv( real(expm(i*x)) );
      else               y = inv( expm(i*x)+expm(-i*x) )*2 ;
      endif
      
    elseif	M=='csc',
      if (isreal(x))     y = inv( imag(expm(i*x)) );
      else               y = inv( expm(i*x)-expm(-i*x) )*2i;
      endif

    elseif    M=='log',  y = logm(x);
      
    elseif    M=='exp',  y = expm(x);
      
    else match = 0;

    endif
    
  elseif	len==4
    
    if      M=='cosh',   y = ( expm(x)+expm(-x) )/2;
      
    elseif  M=='sinh',   y = ( expm(x)-expm(-x) )/2;
      
    elseif  M=='tanh'    t = expm( -2*x ); y = (I - t)/(I + t);
     
    elseif  M=='coth', 	 t = expm( -2*x ); y = (I + t)/(I - t);
      
    elseif  M=='sech',   y = 2 * inv( expm(x) + expm(-x) );
      
    elseif  M=='csch',   y = 2 * inv( expm(x) - expm(-x) );
      
    elseif  M=='asin',   y = -i * logm( i*x + sqrtm(I - x*x) );
      
    elseif  M=='acos',   y =  i * logm( x - i*sqrtm(I - x*x) );

    elseif  M=='atan',   y = -i/2 * logm( (I + i*x)/(I - i*x) );

    elseif  M=='acot',   y =  i/2 * logm( (I + i*x)/(i*x - I) );

    elseif  M=='asec',   y = i * logm( ( I - sqrtm(I - x*x) ) / x );

    elseif  M=='acsc',   y = -i * logm( i*( I + sqrtm(I - x*x) ) / x );

    elseif  M=='sqrt',   y = sqrtm(x);

    else match = 0;

    end

  elseif   len==5

    if      M=='asinh',  y = logm( x + sqrtm (x*x + I) );
      
    elseif  M=='acosh',  y = logm( x + sqrtm (x*x - I) );
      
    elseif  M=='atanh',  y = logm( (I + x)/(I - x) ) / 2;
      
    elseif  M=='acoth',  y = logm( (I + x)/(x - I) ) / 2;

    elseif  M=='asech',  y = logm( (I + sqrtm (I - x*x)) / x );

    elseif  M=='acsch',  y = logm( (I + sqrtm (I + x*x)) / x );

    else match = 0;

    endif

  else match = 0;

  endif

  ## if no known function found, issue warning
  if (match == 0)
    warning ("thfm doesn't support function M - try to use funm instead");
  endif
endfunction
