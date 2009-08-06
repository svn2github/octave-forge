c Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
c 
c Author: Jaroslav Hajek <highegg@gmail.com>
c 
c This file is part of OctGPR.
c 
c OctGPR is free software; you can redistribute it and/or modify
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
      subroutine dgesum(trans,m,n,A,lda,x,incx)
c purpose:      Return a column or row sum of an m-by-n matrix A.
c arguments:
c trans (in)    If 'T', return row sum, otherwise if 'N' column sum.
c m (in)        Number of rows of the matrix A
c n (in)        Number of columns of the matrix A
c A (in)        The m-by-n matrix A
c lda (in)      The leading dimension of A.
c x (out)       The output vector. Should be at least 1+(k-1)*incx elements long,
c               where k = m if trans == 'T', else k = n.
c incx (in)     The stride for x (positive).
c
      character*1 trans
      integer m,n,lda,incx
      real*8 A(lda,*),x(*)
      integer i,j,k
      real*8 sum
      logical lsame
      external lsame,xerbla

c error checks
      if (lda <= 1 .or. lda < m) then
        call xerbla('dgesum',5)
      endif

      if (lsame(trans,'N')) then
c code for column-wise summation
        k = 1
        do j = 1,n
          sum = 0d0
          do i = 1,m
            sum = sum + A(i,j)
          end do
          x(k) = sum
          k = k + incx
        end do
      else if (lsame(trans,'T')) then
c code for row-wise summation
        if (incx == 1) then
c specialization for unit stride
          do i = 1,m
            x(i) = 0
          end do
          do j = 1,n
            do i = 1,m
              x(i) = x(i) + A(i,j)
            end do
          end do
        else
c code for non-unit stride
          k = 1
          do i = 1,m
            x(k) = 0
            k = k + incx
          end do
          do j = 1,n
            k = 1
            do i = 1,m
              x(k) = x(k) + A(i,j)
              k = k + incx
            end do
          end do
        end if
      end if
      end subroutine
