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
      subroutine dspmid(uplo,n,a,AP)
c purpose:      assistant subroutine. Sets a packed symmetric matrix
c               (upper storage) to a multiple of identity.
c arguments:
c uplo (in)     indicates upper or lower BLAS packed storage
c n (in)        dimension of A
c a (in)        the multiple to set A to
c AP (out)      A in packed storage (upper triangle column after column)
c
      character uplo
      integer n,i,j
      double precision a,AP(*)
      external lsame
      logical lsame
      if (lsame(uplo,'U')) then
        j = 0
        do i = 0,n-1
          do j = j+1,j+i
            AP(j) = 0
          end do
          AP(j) = a
        end do
      else
        j = 1
        do i = 0,n-1
          AP(j) = a
          do j = j+1,j+i
            AP(j) = 0
          end do
        end do
      end if
      end subroutine
