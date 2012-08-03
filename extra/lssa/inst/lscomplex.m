## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {t =} lscomplex ( time, mag, maxfreq, numcoeff, numoctaves)
## 
## Return the complex least-squares transform of the (@var{time},@var{mag})
## series, considering frequencies up to @var{maxfreq}, over @var{numoctaves}
## octaves and @var{numcoeff} coefficients.
##
## @seealso{lsreal}
## @end deftypefn

%!test
%!shared t, x, o, maxfreq
%! maxfreq = 4 / ( 2 * pi );
%! t = [0:0.008:8];
%! x = ( 2.*sin(maxfreq.*t) + 3.*sin((3/4)*maxfreq.*t)- 0.5 .* sin((1/4)*maxfreq.*t) - 0.2 .* cos(maxfreq .* t) + cos((1/4)*maxfreq.*t));
%! o = [ maxfreq , 3 / 4 * maxfreq , 1 / 4 * maxfreq ];
%!assert( lscomplex(t,x,maxfreq,2,2), [-0.400754376933531 - 2.366871097665244i, 1.226663545950135 - 2.243899314661490i, 1.936433327880238 - 1.515538553198501i, 2.125045509991203 - 0.954100898917708i ], 6e-14 );



function transform = lscomplex( t , x , omegamax , ncoeff , noctave )
  n = length(t); ## VECTOR ONLY, and since t and x have the same number of entries, there's no problem.
  transform = zeros(1,ncoeff*noctave);
  o = omegamax;
  omul = 2 ^ ( - 1 / ncoeff );
  for iter = 1:ncoeff*noctave
    ot = o .* t;
    transform(iter) = sum( ( cos(ot) - ( sin(ot) .* i ) ) .* x ) / n; ## See the paper for the expression
    o *= omul; ## To advance the transform to the next coefficient in the octave
  endfor

endfunction 
