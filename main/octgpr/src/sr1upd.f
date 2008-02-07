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
      subroutine sr1upd(uplo,n,s,y,B)
c purpose:      update a variable metric matrix (in upper packed 
c               storage) using the Powell's SR1 update.
c
c arguments:
c uplo (in)     whether B is in lower or upper storage
c n (in)        problem dimension
c s (in)        the step just taken
c y (io)        gradient difference 
c               (overwritten by secant residual vector)
c B (io)        symmetric packed matrix
c 
      character uplo
      integer n
      double precision s(n),y(n),B(*)
      external dlamch,ddot,dspmv,dspr
      double precision dlamch,ddot,dnrm2,ry,eps
c create residual vector
      call dspmv(uplo,n,-1d0,B,s,1,1d0,y,1)
c calculate the denominator
      ry = ddot(n,y,1,s,1)
c calculate safeguard 
      eps = sqrt(dlamch('E'))
      eps = eps * dnrm2(n,s,1) * dnrm2(n,y,1)
c update 
      if (abs(ry) > eps) then
        call dspr(uplo,n,1/ry,y,1,B)
      end if
      end subroutine


