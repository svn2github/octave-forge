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
      subroutine dscsev(n,B,D,W,Z,info)
c purpose:      given a symmetric matrix B in packed storage, form the
c               eigendecomposition of diag(D)*B*diag(D)
c arguments:
c n (in)        dimension of B
c B (in)        matrix in upper BLAS packed storage
c D (in)        scaling diagonal matrix
c W (out)       eigenvalues (as output by DSYEV)
c Z (out)       eigenvectors (as output by DSYEV)
c
      integer n,info
      double precision B(*),D(n),W(n),Z(n,n)
      double precision work(3*n)
      integer i,j,k
c form the scaled matrix diag(D)*B*diag(D)
      k = 0
      do j = 1,n
        do i = 1,j
          k = k + 1
          Z(i,j) = B(k) * D(i)*D(j)
        end do
      end do
c get the polar decomposition (use unblocked code)
      call dsyev('V','U',n,Z,n,W,work,3*n,info)
      end subroutine
