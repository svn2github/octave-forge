## Copyright (C) 1998 Ariel Tankus
## 
## This program is free software.
## This file is part of the Image Processing Toolbox for Octave
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
##

## view    Change the viewing angle for a 3-D plot.
##
##         view(az, el)
##         az - horizontal viewing angle (azimuth) [degrees].
##         el - vertical viewing angle (elevation) [degrees].
##

## Author: Ariel Tankus <arielt@math.tau.ac.il>
## Created: 14.8.98.
## Version: 1.0

function view(az, el)

  ## azimuth is the same as rotation around the z-axis,
  ## so gnuplot's z_axis == az.
  az = rem(az, 360);                  # set az in range: [-360, 360].
  az = az + 360*(az < 0);             # set az in range: [0, 360].

  ## elevation:  0 deg - equator,     90 deg - north pole.
  ## in gnuplot: 0 deg - north pole,  90 deg - equator.
  rot_x = 90 - el;

  ## elevation is in gnuplot coordinates

  rot_x = rem(rot_x, 360);              # set rot_x in range: [-360, 360].
  rot_x = rot_x + 360*(rot_x < 0);      # set rot_x in range: [0, 360].

  if (rot_x > 180)
    ## elevation greater than 180 degs is
    az = rem(az + 180, 360);
    rot_x = 360 - rot_x;
  end

  gset('view', num2str(rot_x), ',', num2str(az));
  replot;

endfunction
