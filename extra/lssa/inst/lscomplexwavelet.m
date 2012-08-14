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

## -*- texinfo -*-
##
## @deftypefn {Function File} {@var{t} =} lscomplexwavelet (@var{time},
##@var{mag}, @var{maxfreq}, @var{numcoeff}, @var{numoctave}, 

function transform = lscomplexwavelet( T, X, omegamax, ncoeff, noctave, tmin, tmax, tstep, sigma = 0.05)

  ## This is a transform based entirely on the simplified complex-valued transform
  ## in the Mathias paper, page 10. My problem with the code as it stands is, it
  ## doesn't have a good way of determining the window size. Sigma is currently up
  ## to the user, and sigma determines the window width (but that might be best.)
  ##
  ## Currently the code does not apply a time-shift, which needs to be fixed so
  ## that it will work correctly over given frequencies.
	 
  transform = cell(noctave*ncoeff,1);
  
  for octave_iter = 1:noctave
    ## In fastnu.c, winrad is set as π/(sigma*omegaoct); I suppose this is
    ## ... feasible, although it will need to be noted that if sigma is set too
    ## large, the windows will exclude data. I can work with that.
    ##
    ## An additional consideration is that 
    
    for coeff_iter = 1:ncoeff
	
      ## in this, win_t is the centre of the window in question
      ## Although that will vary depending on the window. This is just an
      ## implementation for the first window.
	
      current_iteration = (octave_iter-1)*ncoeff+coeff_iter;
      window_radius = pi / ( sigma * omegamax * ( 2 ^ ( current_iteration - 1 ) ) );
      window_count = 2 * ceil ( ( tmax - tmin ) / window_radius ) - 1;
      omega = current_frequency = omegamax * 2 ^ ( - octave_iter*coeff_iter / ncoeff );
      
      
      
      transform{current_iteration}=zeros(1,window_count);

      ## win_t is the centre of the current window.
      win_t = tmin + window_radius;
      for iter_window = 1:window_count
	## Computes the transform as stated in the paper for each given frequency.
	zeta = sum ( cubicwgt ( sigma .* omega .* ( T - win_t ) ) .* exp ( -i .* omega .* ( T - win_t ) ) .* X ) / sum ( cubicwgt ( sigma .* omega .* ( T - win_t ) ) .* exp ( -i .* omega .* ( T - win_t ) ) );
	transform{current_iteration}(iter_window) = zeta;
	window_min += window_radius ;
    endfor
  endfor
  
endfor

endfunction

