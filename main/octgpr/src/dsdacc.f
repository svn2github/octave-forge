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
      subroutine dsdacc(n,x,y,x2,xy)
c purpose:      an assistant subroutine. Accumulates the dot product
c               x'*y as well as sum of squares x'*x in one pass.
c arguments:
c n (in)        length of x,y
c x,y (in)      vectors in question
c x2 (out)      x'*x
c xy (out)      x'*y
c
      integer n
      double precision x(*),y(*),x2,xy
      integer i
      external xerbla
      xy = 0
      x2 = 0
      do i = 1,n
        x2 = x2 + x(i)**2
        xy = xy + x(i)*y(i)
      end do
      end subroutine

