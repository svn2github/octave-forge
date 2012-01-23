## Copyright (C) 2011 Alexander Klein <alexander.klein@math.uni-giessen.de>
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

## ## -*- texinfo -*-
## @deftypefn {Function File} {[@var{d}, @var{e}] =} big_factorial (@var{n})
## Compute factorials with arbitrarily many digits.
##
## @code{[d,e] = big_factorial (@var{n})} returns the vector of leading
## 10-based digits in @var{d}, and the number of trailing zeroes in
## @var{e}.
##
## @seealso{factorial, lfactorial}
## @end deftypefn

function [d, e] = big_factorial (n)

  if (nargin != 1)
    print_usage ();
  elseif ( n < 0 || fix (n) != n )
    error ("Can compute factorials for positive integers only!");
  end

  d = 1;
  e = 0;

  for k = 1 : n

    ## The leading digits are just the convolution of the 
    ## current digit vector with the digit vector of the
    ## next factor.
    d = normalise_bignum ( conv ( d, normalise_bignum ( k ) ) );

    ## Push trailing zeroes to e.
    if ( !d ( end ) )

      index = find ( d, 1, "last" );

      e += length ( d ) - index;
      d = d ( 1 : index );
    end

  end
end


function n = normalise_bignum ( m )

  n = m;

  ## Make sure there are no digits larger than 9.
  while ( any ( n > 9 ) )

    c = ( [ fix( n / 10 ), 0 ] );
    if ( any ( c ) )

      n = [ 0, rem( n, 10 ) ] + c;

      n = n ( find ( n, 1, "first" ) : end );
    end
  end
end

%!test
%! [d, e] = big_factorial ( 8 );
%! assert ( e, 1)
%! assert ( d, [ 4 0 3 2] )
