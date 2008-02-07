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
      subroutine vmcmp(n,B,D,Z,ba,a,g,ga,s,sa,ssiz,redc)
c purpose:      completes the solution of the mixed-norm
c               trust-region subproblem initiated by vmfac and
c               trstp, computes the actual step size and
c               expected reduction according to the model.
c arguments:
c n (in)        problem dimension.
c B (in)        variable metric matrix in packed storage
c D (in)        diagonal scaling matrix
c Z (in)        variable metric polar base
c ba,a (in)     quadratic coefficients
c g,ga (in)     linear coefficients
c s,sa (io)     solution (sa is not modified)
c ssiz (out)    norm(s)
c redc (out)    model reduction
c
      integer n
      double precision B(*),D(n),Z(n,n),ba(n),a,g(n),ga,
     +s(n),sa,ssiz,redc
      double precision tmp(n)
      integer i,j
c transform from polar basis
      call dgemv('N',n,n,1.d0,Z,n,s,1,0.d0,tmp,1)
      do i = 1,n
        s(i) = tmp(i)/D(i)
      end do
c compute the actual step size
      ssiz = dnrm2(n,tmp,1)
c compute the expected reduction
      call dspmv('U',n,1.d0,B,tmp,1,0.d0,s,1)
      redc = 0.5d0*ddot(n,tmp,1,s,1) + sa*ddot(n,ba,1,s,1) + 
     +0.5d0*a*sa**2 + ddot(n,g,1,s,1) + ga*sa
      end subroutine

