## Copyright (C) 2009   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{re}, @var{im}] =} nyquist (@var{sys})
## @deftypefnx {Function File} {[@var{re}, @var{im}] =} nyquist (@var{sys}, @var{w})
## Nyquist diagram of LTI model's frequency response.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.1

function [re_r, im_r] = nyquist (sys, w = [])

  ## check whether arguments are OK
  if (nargin == 0 || nargin > 2)
    print_usage ();
  endif

  if(! isa (sys, "lti"))
    error ("nyquist: first argument sys must be a LTI system");
  endif

  if (! isvector (w) && ! isempty (w))
    error ("nyquist: second argument w must be a vector of frequencies");
  endif

  if (! issiso (sys))
    error ("nyquist: require SISO system");
  endif

  ## find interesting frequency range w if not specified
  if (isempty (w))
    ## begin plot at 10^dec_min, end plot at 10^dec_max [rad/s]
    [dec_min, dec_max] = __freqbounds__ (sys);

    w = logspace (dec_min, dec_max, 500);  # [rad/s]
    w = [0, w];
  endif

  H = __freqresp__ (sys, w);

  H = H(:);
  re = real (H);
  im = imag (H);

  if (! nargout)
    ax_vec = __axis2dlim__ ([[re, im]; [re, -im]]);

    plot (re, im, "b", re, -im, "r")
    axis (ax_vec)
    grid ("on")
    title ("Nyquist Diagram")
    xlabel ("Real Axis")
    ylabel ("Imaginary Axis")
  else
    re_r = re;
    im_r = im;
  endif

endfunction