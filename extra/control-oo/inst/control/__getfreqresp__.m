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
## Return frequency response H and frequency vector w.
## If w is empty, it will be calculated by __freqbounds__

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.1

function [H, w] = __getfreqresp__ (sys, w = [], mimoflag = 0, resptype = 0)

  ## check arguments
  if(! isa (sys, "lti"))
    error ("getfreqresp: first argument sys must be a LTI system");
  endif

  if (! isvector (w) && ! isempty (w))
    error ("getfreqresp: second argument w must be a vector of frequencies");
  endif

  if (! mimoflag && ! issiso (sys))
    error ("getfreqresp: require SISO system");
  endif

  ## find interesting frequency range w if not specified
  if (isempty (w))
    ## begin plot at 10^dec_min, end plot at 10^dec_max [rad/s]
    [dec_min, dec_max] = __freqbounds__ (sys);

    w = logspace (dec_min, dec_max, 500);  # [rad/s]
  endif

  ## frequency response
  H = __freqresp__ (sys, w, resptype);

endfunction