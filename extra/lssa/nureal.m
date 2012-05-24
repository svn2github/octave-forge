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
## @deftypefn {Function File} {transform =} nureal ( mag, time, maxfreq, numcoeff, numoctaves)
##
## Return the real least-squares transform of the time series
## defined, based on the maximal frequency @var{maxfreq}, the
## number of coefficients @var{numcoeff}, and the number of 
## octaves @var{numoctaves}. It works only for vectors currently.
##
## @end deftypefn

function transform = nureal( x, t, omegamax, ncoeff, noctave)
  ## the R function runs the following command:
  ## nureal( double X, double Y, int min(X,Y), int ncoeff, int noctave, double omegamax, complex rp)
  ## this means that in the C, *tptr is X and *xptr is Y. Yes, I know. I think I'll rename them.
  ## n is the min of X and Y ... (as is k) and ncoeff is ... ncoeff, while noctave is noctave and
  ## o is omegamax.
  ## where rp = complex(noctave*ncoeff) so ... I can just store that as noctave*ncoeff and have no
  ## problems, I guess.
  ## Possibly throw an error if ncoeff <= 0.
  k = n = min ( min ( x , t ) ); ## THIS IS VECTOR-ONLY. I'd need to add another bit of code to
  ## make it array-safe, and that's not knowing right now what else will be necessary.
  rp = zeros(1,(noctave * ncoeff)); ## In the C code, this is rendered as a Complex, but Octave doesn't care.
  od = 2 ^ ( - 1 / ncoeff ); ## this will cause a crash if ncoeff=0; prefer error & quit?
  o = omegamax;
  ## ot is just defined as a Real here, I'm leaving it until it needs to be called.
  n1 = 1 / n; ## written n_1 in the C, but I'd prefer to not get into underscores here.
  ## zeta and iota are defined as Complex here, leaving them until they need to be defined.
  ## I'm not convinced I won't want ncoeff again, so ...
  ncoeffp = ncoeff;
  for ( ncoeffp *= noctave , iter = 1 ; sign(ncoeffp--) ; o *= od )
    #{
    zeta = iota = 0;
    for ( SRCFIRST ; SRCAVAIL ; SRCNEXT ) ##This is going to be vectorised shortly.
      ## This code can't run yet ... I'm going to work out what SRCFIRST, SRCAVAIL, SRCNEXT are and
      ## replace them with what they should be in this context. I've kept them as reminders.
      ot = o * SRCT; ## Same with SRCT ... I think it means what was originally set as Y. Macros?
      zeta += cos(ot) * SRCX;
      zeta -= sin(ot) * SRCX * i; ## More sure now. I don't think I can vectorise this ... who am I kidding?
      ot *= 2;
      iota += cos(ot);
      iota -= sin(ot) * i;
    endfor
    }#
    ## Commented out the converted-from-C code because it's replaced by the four lines below.
    ## This method is an application of Eq. 8 on page 6 of the text, as well as Eq. 7
    ot = o .* t; 
    zeta = sum( ( cos(ot) .* x ) - ( sin(ot) .* x .* i ) );
    ot = ot .* 2;
    iota = sum( cos(ot) - ( sin(ot) .* i ) );
    zeta *= n1;
    iota *= n1;
    rp(iter++) = 2 / ( 1 - ( real(iota) ^ 2 ) - ( imag(iota) ^ 2 ) ) * ( conj(zeta) - (conj(iota) * zeta ));
  endfor
  
  transform = rp;

endfunction