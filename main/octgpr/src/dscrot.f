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
      subroutine dscrot(trans,n,D,Z,x)
c purpose:      perform a "rotate and scale" transformation, i.e.
c               given a diagonal matrix D and orthogonal matrix
c               W, this subroutine computes
c               x = W*D*x       if (trans == 'N' or 'n')
c               x = W'*D*x      if (trans == 'T' or 't')
c arguments:
c trans (in)    indicates transposition
c n (in)        dimension
c D (in)        scale matrix
c Z (in)        orthogonal matrix
c x (io)        the vector being transformed
c wrk           workspace >= n
c
      character trans
      integer n
      double precision D(n),Z(n,n),x(n)
      double precision wrk(n)
      integer i
      do i = 1,n
        wrk(i) = x(i)*D(i)
      end do
      call dgemv(trans,n,n,1d0,Z,n,wrk,1,0d0,x,1)
      end subroutine
