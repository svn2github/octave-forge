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
      subroutine zqrinc(m,n,Q,R,j,x)
c purpose:      updates a QR factorization after inserting a new
c               column.      
c               i.e., given an m-by-m unitary matrix Q, an m-by-n
c               matrix R and index j in the range 1:n such that 
c               R0 = [R(:,1:j-1) R(:,j+1:n)] is upper trapezoidal, 
c               this subroutine computes Q := Q1 and R1 := R
c               such that Q1*R1 = [A(:,1:j-1) x A(j+1:n)], where
c               A = Q*R0.
c               (complex version)
c arguments:
c m (in)        number of columns of the matrix R
c n (in)        number of rows of the matrix R
c Q (io)        the orthogonal m-by-m matrix Q
c R (io)        the upper trapezoidal m-by-n matrix R, with 
c               the j-th column not set. 
c               note that the 1st subdiagonal is also
c               accessed, but set to zero on return.
c               further, the elements R(j+1:m,j) are zeroed.
c j (in)        the position of the new column in R
c x (in)        the column being inserted
c
c NOTE:         uses ZLARTG rather than ZROTG
      integer m,n,j
      double complex Q(m,m),R(m,n),x(m)
      double precision c
      double complex s,w,w1,rr,zdotc
      external zlartg,zrot,zdotc,zgemv
      integer i
      if (m <= 0 .or. n <= 0) return
      if (j < 1 .or. j > n) then
        call xerbla('ZQRINC',5)
      end if
c form each element of w = Q'*x when necessary.
      w = zdotc(m,Q(1,m),1,x,1)
      do i = m-1,j,-1
        w1 = w
        w = zdotc(m,Q(1,i),1,x,1)
        call zlartg(w,w1,c,s,rr)
        w = rr
        R(i+1,j) = 0d0
c apply rotation to rows of R if necessary 
        if (i < n) then
          call zrot(n-i,R(i,i+1),m,R(i+1,i+1),m,c,s)
        end if
c apply rotation to columns of Q
        call zrot(m,Q(1,i),1,Q(1,i+1),1,c,conjg(s))
      end do
c just eliminated to trapezoidal form. Store the diagonal element.
      R(j,j) = w
c compute the rest of the column      
      call zgemv('C',m,j-1,1d0,Q,m,x,1,0d0,R(1,j),1)
      end subroutine
