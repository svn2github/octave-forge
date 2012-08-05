## Copyright (C) 2012 Ben Lewis <benjf5@gmail.com>
##
## This software is free software; you can redistribute it and/or modify it under
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



function transform = lscomplexwavelet( t , x, omegamax, ncoeff, noctave, minimum_window_count, sigma = 0.05)

## This is a transform based entirely on the simplified complex-valued transform
## in the Mathias paper, page 10. My problem with the code as it stands is, it
## doesn't have a good way of determining the window size. Sigma is currently up
## to the user, and sigma determines the window width (but that might be best.)
##
## Currently the code does not apply a time-shift, which needs to be fixed so
## that it will work correctly over given frequencies.
##
## Additionally, each octave up adds one to the number of frequencies.

transform = cell(ncoeff*noctave,1);
for octave_iter = 1:noctave
  current_octave = maxfreq * 2 ^ ( - octave_iter );
  current_window_number = minimum_window_count + noctave - octave_iter;
  window_step = ( tmax - tmin ) / current_window_number;
  for coeff_iter = 1:ncoeff
    ## in this, win_t is the centre of the window in question
    window_min = t_min;
    ## Although that will vary depending on the window. This is just an
    ## implementation for the first window.
    omega = current_frequency = maxfreq * 2 ^ ( - octave_iter*coeff_iter / ncoeff );
    current_radius = 1 / ( current_octave * sigma );
    
    transform{iter} = zeros(1,current_window_number);
    win_t = window_min + ( window_step / 2);
    for iter_window = 1:current_window_number
      ## Computes the transform as stated in the paper for each given frequency.
      zeta = sum ( cubicwgt ( sigma .* omega .* ( T - win_t ) ) .* exp ( -i .* omega .* ( T - win_t ) ) .* X ) / sum ( cubicwgt ( sigma .* omega .* ( T - win_t ) ) .* exp ( -i .* omega .* ( T - win_t ) ) );
      transform{iter}(iter_window) = zeta;
      window_min += window_step ;
    ## I remain hesitant about this value, since it is entirely possible necessary precision will be lost. Should I try to reduce that?
    endfor
  endfor
  
endfor

endfunction

