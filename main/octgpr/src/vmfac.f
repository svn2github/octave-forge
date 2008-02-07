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
      subroutine vmfac(n,B,D,WB,ZB,g,g1,ba,ba1)
c purpose:      store in W and Z the eigendecomposition of
c               B
c arguments:
c n (in)        problem dimension
c B (in)        variable metric matrix in packed storage
c D (in)        diagonal scaling matrix
c WB (out)      variable metric eigenvalues
c ZB (out)      variable metric polar base
c g (in)        the gradient
c g1 (out)      transformed gradient
c ba (in)       the theta-nu part of hessian model
c ba1 (out)     transformed ba
c
      integer n
      double precision B(*),D(n),WB(n),ZB(n,n),g(n),g1(n),ba(n),ba1(n)
      double precision B2(n*(n+1)/2),work(n,3)
      integer info,i,j,k
c form the scaled matrix diag(D)*B*diag(D)
      k = 0
      do j = 1,n
        do i = 1,j
          k = k + 1
          B2(k) = B(k) * D(i)*D(j)
        end do
      end do
c get the polar decomposition
      call dspev('V','U',n,B2,WB,ZB,n,work,info)
c scale vectors      
      do i = 1,n
        work(i,1) = g(i)/D(i)
        work(i,2) = ba(i)/D(i)
      end do
c transform to polar basis
      call dgemv('T',n,n,1.d0,ZB,n,work(1,1),1,0.d0,g1,1)
      call dgemv('T',n,n,1.d0,ZB,n,work(2,1),1,0.d0,ba1,1)
      end subroutine

