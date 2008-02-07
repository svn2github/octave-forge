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
      subroutine stheta(ndim,nx,X,theta)
c purpose:      guess "typical" length scales for GPR regression
c               optimization purposes. These may either be used as
c               a starting guess, or as scaling factors.
c               this is currently very primitive: the reciprocal
c               of the standard deviation is calculated for each 
c               dimension. May be replaced with something
c     
c arguments:
c ndim (in)     number of dimensions
c nx (in)       number of observations
c X (in)        observations
c theta (out)   length scales
c
      integer ndim,nx
      real*8 X(ndim,nx),theta(ndim)
      real*8 mX(ndim)
      integer i,j,k
      do k = 1,ndim
        mX(k) = 0
      end do
      do i = 1,nx
        do k = 1,ndim
          mX(k) = mX(k) + X(k,i)
        end do
      end do
      do k = 1,ndim
        mX(k) = mX(k) / nx
      end do
      do k = 1,ndim
        theta(k) = 0
      end do
      do i = 1,nx
        do k = 1,ndim
          theta(k) = theta(k) + (X(k,i) - mX(k))**2
        end do
      end do
      do k = 1,ndim
        theta(k) = sqrt(nx / theta(k))
      end do
      end subroutine

