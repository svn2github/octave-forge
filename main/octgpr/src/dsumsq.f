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
      double precision function dsumsq(n,x,incx)
c purpose:      an assistant function. Computes a sum of squares
c               of the components of a vector x. This is separated
c               to allow possibly more precise computation in the
c               future.
c arguments:
c n (in)        length of x
c x (in)        vectors in question
c incx (in)     increment
      integer n,incx
      real*8 x(*)
      integer i
      dsumsq = 0d0
      if (incx == 1) then
        do i = 1,n
          dsumsq = dsumsq + x(i)**2
        end do
      else
        do i = 1,n*incx,incx
          dsumsq = dsumsq + x(i)**2
        end do
      end if
      end function


