## Copyright (C) 2012 Benjamin Lewis
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
## @deftypefn {Function File} {transform =} nureal ( time, mag, maxfreq, numcoeff, numoctaves)
##
## Return the real least-squares transform of the time series
## defined, based on the maximal frequency @var{maxfreq}, the
## number of coefficients @var{numcoeff}, and the number of 
## octaves @var{numoctaves}. Each complex-valued result is the
## pair (c_o, s_o) defining the coefficients which best fit the
## function y = c_o * cos(ot) + s_o * sin(ot) to the (@var{time}, @var{mag}) data.
##
## @end deftypefn

%!shared t, x, o, maxfreq
%! maxfreq = 4 / ( 2 * pi );
%! t = linspace(0,8);
%! x = ( 2.*sin(maxfreq.*t) + 3.*sin((3/4)*maxfreq.*t) - 0.5 .* sin((1/4)*maxfreq.*t) - 0.2 .* cos(maxfreq .* t) + cos((1/4)*maxfreq.*t));
%! assert(lsreal(t,x,maxfreq,2,2),[-1.68275915310663 + 4.70126183846743i, 1.93821553170889 + 4.95660209883437i, 4.38145452686697 + 2.14403733658600i, 5.27425332281147 - 0.73933440226597i],6e-14)
%! #In the assert here, I've got an error bound large enough to catch individual system errors which would present no real issue.

function transform = lsreal( t, x, omegamax, ncoeff, noctave)
  ## the R function runs the following command:
  ## nureal( double X, double Y, int min(X,Y), int ncoeff, int noctave, double omegamax, complex rp)
  ## this means that in the C, *tptr is X and *xptr is Y. Yes, I know. I think I'll rename them.
  ## n is the min of X and Y ... (as is k) and ncoeff is ... ncoeff, while noctave is noctave and
  ## o is omegamax.
  ## where rp = complex(noctave*ncoeff) so ... I can just store that as noctave*ncoeff and have no
  ## problems, I guess.
  ## Possibly throw an error if ncoeff <= 0.
  k = n = length(t); ## THIS IS VECTOR-ONLY. I'd need to add another bit of code to
  ## make it array-safe, and that's not knowing right now what else will be necessary.
  transform = zeros(1,(noctave * ncoeff)); ## In the C code, this is rendered as a Complex, but Octave doesn't care.
  od = 2 ^ ( - 1 / ncoeff ); ## this will cause a crash if ncoeff=0; prefer error & quit?
  o = omegamax;
  ## ot is just defined as a Real here, I'm leaving it until it needs to be called.
  n1 = 1 / n; ## written n_1 in the C, but I'd prefer to not get into underscores here.
  ## zeta and iota are defined as Complex here, leaving them until they need to be defined.
  ## I'm not convinced I won't want ncoeff again, so ...
  ncoeffp = ncoeff;
  ncoeffp *= noctave;
  for iter = 1:ncoeffp
    ## This method is an application of Eq. 8 on page 6 of the text, as well as Eq. 7
    ot = o .* t;
    zeta = sum( ( cos(ot) .* x ) - ( sin(ot) .* x .* i ) );
    ot = ot .* 2;
    iota = sum( cos(ot) - ( sin(ot) .* i ) );
    zeta = zeta .* n1;
    iota = iota .* n1;
    transform(iter) = 2 / ( 1 - ( real(iota) ^ 2 ) - ( imag(iota) ^ 2 ) ) * ( conj(zeta) - (conj(iota) * zeta ));
    o = o .* od;
  endfor
  
  ##  transform = rp;

endfunction
