c Copyright (C) 2009  VZLU Prague, a.s., Czech Republic
c 
c Author: Jaroslav Hajek <highegg@gmail.com>
c 
c This file is part of NLWing2.
c 
c NLWing2 is free software; you can redistribute it and/or modify
c it under the terms of the GNU General Public License as published by
c the Free Software Foundation; either version 3 of the License, or
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
      subroutine bisavc(m,n,CP,X,vi,w)
c purpose:      calculate induced velocities
c               given by a chain of segments
c arguments:
c m (in)        number of vortices.
c n (in)        number of colloc points
c CP (in)       colloc points (m,3)
c X (in)        nodes (0:n,3)
c vi (out)      induced velocities (m,n,3)
c w (work)      workspace of size 4*m
c
      integer m,n
      double precision CP(m,3),X(0:n,3),vi(m,n,3),w(4,m)
      integer i, j
      double precision dot,XX(3),RX(3),RXn,YY(3),RY(3),RYn,Rf
      parameter(pi4i = -0.0795774715459477d0)
      if (n >= 0) then
        XX = X(0,:)
        do i = 1,m
          RX = XX - CP(i,:)
          RXn = sqrt(sum(RX**2))
          w(1:3,i) = RX
          w(4,i) = RXn
        end do
      end if

      do j = 1,n
        YY = X(j,:)
        do i = 1,m
          RX = w(1:3,i)
          RY = YY - CP(i,:)
          dot = dot_product(RX,RY)
          RXn = w(4,i)
          RYn = sqrt(sum(RY**2))
          Rf = pi4i * (RXn + RYn) / (RXn*RYn*(RXn*RYn + dot))
          vi(i,j,1) = Rf*(RX(2)*RY(3) - RX(3)*RY(2))
          vi(i,j,2) = Rf*(RX(3)*RY(1) - RX(1)*RY(3))
          vi(i,j,3) = Rf*(RX(1)*RY(2) - RX(2)*RY(1))
          w(1:3,i) = RY
          w(4,i) = RYn
        end do
      end do
      end subroutine

