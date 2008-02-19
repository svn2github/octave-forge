c Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
c 
c Author: Jaroslav Hajek <highegg@gmail.com>
c 
c This source is free software; you can redistribute it and/or modify
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
      subroutine zqr1up(m,n,Q,R,u,v)
c purpose:      updates a QR factorization after rank-1 modification
c               i.e., given a n-by-n unitary Q and m-by-n upper 
c               trapezoidal R, an m-vector u and n-vector v, this 
c               subroutine updates Q := Q1 and R := R1 so that
c               Q1*R1 = Q*R + u*v', and Q1 is again orthonormal
c               and R upper trapezoidal.
c               (complex version)
c arguments:
c m (in)        number of columns of the matrix R
c n (in)        number of rows of the matrix R
c Q (io)        the orthogonal m-by-m matrix Q
c R (io)        the upper trapezoidal m-by-n matrix R.
c               note that the 1st subdiagonal is also
c               accessed, but set to zero on return.
c u (in)        the left m-vector
c v (in)        the right n-vector
c
c NOTE:         uses ZLARTG instead of ZROTG
      integer m,n
      double complex Q(m,m),R(m,n),u(m),v(n)
      double precision c
      double complex s,w,w1,rr,zdotc
      external zlartg,zrot,zdotc
      integer i
      if (m <= 0 .or. n <= 0) return
c form each element of w = Q'*u when necessary.
      w = zdotc(m,Q(1,m),1,u,1)
      do i = m-1,1,-1
        w1 = w
        w = zdotc(m,Q(1,i),1,u,1)
        call zlartg(w,w1,c,s,rr)
        w = rr
c apply rotation to rows of R        
        if (i <= n) then
          call zrot(n+1-i,R(i,i),m,R(i+1,i),m,c,s)
        end if
c apply rotation to columns of Q
        call zrot(m,Q(1,i),1,Q(1,i+1),1,c,conjg(s))
      end do
c w(2:n) is eliminated. Update R(1,:)
      do i = 1,n
        R(1,i) = R(1,i) + w*conjg(v(i))
      end do
c go downwards, retriangularize
      do i = 1,min(m-1,n)
        call zlartg(R(i,i),R(i+1,i),c,s,rr)
        R(i,i) = rr
        R(i+1,i) = 0d0
c apply rotation to rows of R
        if (i < n) then
          call zrot(n-i,R(i,i+1),m,R(i+1,i+1),m,c,s)
        end if
c apply rotation to columns of Q
        call zrot(m,Q(1,i),1,Q(1,i+1),1,c,conjg(s))
      end do
      end subroutine
