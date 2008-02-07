c Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
c 
c Author: Jaroslav Hajek <highegg@gmail.com>
c 
c This file is part of OctGPR.
c 
c OctGPR is free software; you can redistribute it and/or modify
c it under the terms of the GNU General Public License as published by
c the Free Software Foundation; either version 2 of the License, or
c (at your option) any later version.
c 
c This program is distributed in the hope that it will be useful,
c but WITHOUT ANY WARRANTY; without even the implied warranty of
c MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
c GNU General Public License for more details.
c 
c You should have received a copy of the GNU General Public License
c along with this software; see the file COPYING.  If not, see
c <http://www.gnu.org/licenses/>.
c 
      double precision function dwdis2(ndim,theta,x1,x2)
c purpose:      assistant function. Calculates the weighted squared
c               distance between spatial points x1 and x2
c arguments:
c ndim (in)     number of dimensions
c theta (in)    weights
c x1,x2 (in)    input spatial points
c return value: weighted distance
c
      integer ndim
      double precision theta(*),x1(*),x2(*)
      integer k
      dwdis2 = 0
      do k = 1,ndim
        dwdis2 = dwdis2 + (theta(k)*(x1(k)-x2(k)))**2
      end do
      end function

