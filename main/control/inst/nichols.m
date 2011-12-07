## Copyright (C) 2009, 2010, 2011   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{mag}, @var{pha}, @var{w}] =} nichols (@var{sys})
## @deftypefnx {Function File} {[@var{mag}, @var{pha}, @var{w}] =} nichols (@var{sys}, @var{w})
## Nichols chart of frequency response.  If no output arguments are given,
## the response is printed on the screen.
##
## @strong{Inputs}
## @table @var
## @item sys
## LTI system.  Must be a single-input and single-output (SISO) system.
## @item w
## Optional vector of frequency values.  If @var{w} is not specified,
## it is calculated by the zeros and poles of the system.
## @end table
##
## @strong{Outputs}
## @table @var
## @item mag
## Vector of magnitude.  Has length of frequency vector @var{w}.
## @item pha
## Vector of phase.  Has length of frequency vector @var{w}.
## @item w
## Vector of frequency values used.
## @end table
##
## @seealso{bode, nyquist, sigma}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.3

function [mag_r, pha_r, w_r] = nichols (sys, w = [])

  ## TODO: multiplot feature:   nichols (sys1, "b", sys2, "r", ...)

  if (nargin == 0 || nargin > 2)
    print_usage ();
  endif

  [H, w] = __frequency_response__ (sys, w, false, 0, "ext");

  H = reshape (H, [], 1);
  mag = abs (H);
  pha = unwrap (arg (H)) * 180 / pi;

  if (! nargout)
    mag_db = 20 * log10 (mag);
    ax_vec = __axis_limits__ ([reshape(pha, [], 1), reshape(mag_db, [], 1)]);
    
    plot (pha, mag_db)
    ax = axis;
    if (any (isinf (ax_vec)))  # catch case purely imaginary poles or zeros
      ax_vec(3:4) = ax(3:4);
    endif
    axis (ax_vec)
    grid ("on")
    title (["Nichols Chart of ", inputname(1)])
    xlabel ("Phase [deg]")
    ylabel ("Magnitude [dB]")
  else
    mag_r = mag;
    pha_r = pha;
    w_r = w;
  endif

endfunction