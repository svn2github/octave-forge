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
      subroutine dtr2tp(uplo,diag,n,a,lda,ap)
c purpose:      converts a triangular matrix into BLAS packed form
c arguments:
c uplo          'L' or 'U'. lower/upper
c diag          'N' or 'U'. if 'U', the diagonal elements of a are not
c               referenced, but assumed to be unity.
c n             order of matrix a
c a             the triangular matrix
c lda           leading dim of a
c ap            the packed form. Size must be at least n*(n+1)/2. 
c
      character uplo,diag
      integer n,lda
      double precision a(lda,*),ap(*)
      logical nounit,lsame
      external lsame,xerbla
      integer i,j,k,info
      info = 0
      if (.not.lsame(uplo,'u') .and. .not.lsame(uplo,'l')) then
        info = 1
      else if (.not.lsame(diag,'u') .and. .not.lsame(diag,'n')) then
        info = 2
      else if (n < 0) then
        info = 3
      else if (lda < 1) then
        info = 6
      end if
      if (info /= 0) then
        call xerbla('dtr2tp',info)
        return
      end if
      nounit = lsame(diag,'N')
      if (lsame(uplo,'U')) then
c code for upper triangular matrix
        k = 0
        do j = 1,n
          do i = 1,j-1
            k = k + 1
            ap(k) = a(i,j)
          end do
          k = k + 1
          if (nounit) then
            ap(k) = a(j,j)
          else
            ap(k) = 1.d0
          end if
        end do
      else
c code for lower triangular matrix
        k = 0
        do j = 1,n
          k = k + 1
          if (nounit) then
            ap(k) = a(j,j)
          else
            ap(k) = 1.d0
          end if
          do i = j+1,n
            k = k + 1
            ap(k) = a(i,j)
          end do
        end do
      end if
      return
      end subroutine

