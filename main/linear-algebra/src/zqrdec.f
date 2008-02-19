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
      subroutine zqrdec(m,n,Q,R,j)
c purpose:      updates a QR factorization after deleting
c               a column.      
c               i.e., given an m-by-m unitary matrix Q, an m-by-n
c               matrix R and index j in the range 1:n+1 such that 
c               R(:,1:j-1) and R(j+1:m,j:n) are upper trapezoidal,
c               this subroutine computes Q := Q1 and R1 := R
c               such that Q1*R1 = Q*R, with Q1 unitary and R1
c               upper trapezoidal.
c arguments:
c m (in)        number of columns of the matrix R
c n (in)        number of rows of the matrix R
c Q (io)        the orthogonal m-by-m matrix Q
c R (io)        the almost upper trapezoidal m-by-n matrix R.
c               note that the 1st subdiagonal is also
c               accessed, but set to zero on return.
c j (in)        the position of the deleted column in R
c
c NOTE:         uses DLARTG rather than DROTG
c               (complex version)
      integer m,n,j
      double complex Q(m,m),R(m,n),u(m)
      double precision c
      double complex s,rr
      external zlartg,zrot
      integer i
      if (m <= 0 .or. n <= 0) return
      if (j < 1 .or. j > n+1) then
        call xerbla('ZQRDEC',5)
      end if
c go downwards, retriangularize
      do i = j,min(m-1,n)
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
