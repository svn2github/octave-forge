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
      subroutine nldgpr(ndim,nx,X,theta,nu,var,R,
     +dtheta,dnu,info)
c purpose:      calculate the negative log-likelihood derivatives
c               w.r.t. length scales and nu. It can be used after
c               nllgpr, to facilitate gradient-based MLE optimization
c               without finite-differencing.
c arguments:
c ndim (in)     number of dimensions of input space
c nx (in)       number of training points
c X (in)        array of training input vectors
c theta (in)    length scales
c nu (in)       relative white noise. nu = sqrt(var_white/var)
c var (in)      MLE estimated global variance from nllgpr
c R (inout)     at least (nx)*(nx+1). The factorization details as
c               computed by nllgpr. R is destroyed.
c dtheta (out)  derivatives w.r.t. length scales
c dnu (out)     derivative and second derivative w.r.t. relative noise
c info          error code. Possible values are:
c               info = 0 no problem
c               info = 1 invalid correlation matrix from nllgpr (dtrtri
c                        failure)
      integer ndim,nx,nlin,info
      real*8 X(ndim,nx),theta(ndim),nu,var
      real*8 R(nx,0:nx),dtheta(ndim),dnu(2)
      external dtrsv,dtrtri,dsyr,xerbla
      integer i,j,k
      real*8 tmp,tmp2,m2

c argument checks
      info = 0
      if (ndim < 0) then
        info = 1
      else if (nx < 1) then
        info = 2
      end if
      if (info /= 0) then
        call xerbla('nldgpr',info)
        return
      end if

c form L' \ m = R \ ones(nx,1)
      call dtrsv('L','T','N',nx,R(1,1),nx,R(1,0),1)

c invert the triangular factor
      call dpotri('L',nx,R(1,1),nx,info)
      if (info /= 0) goto 501

c compute sumsq(m)
      m2 = 0.d0
      do i = 1,nx
        m2 = m2 + R(i,0)**2
      end do      
c accumulate nu derivatives information      
      dnu(1) = 0.d0
      dnu(2) = 0
      do j = 1,nx
        call dsdacc(nx-j,R(j+1,j),R(j+1,0),tmp2,tmp)
        tmp = 2*tmp + R(j,j)*R(j,0)
        tmp2 = tmp2 + 0.5d0*R(j,j)**2
        dnu(1) = dnu(1) + R(j,j)
        dnu(2) = dnu(2) - tmp2 + R(j,0)*tmp/var
      end do
c compute derivative w.r.t. nu**2
c compute second derivative w.r.t. nu**2/2
      dnu(1) = 0.5d0*(dnu(1) - m2/var)
      dnu(2) = dnu(2) - m2**2 / var**2 * 0.5d0/nx
c update to derivatives w.r.t. nu
      dnu(2) = 4*dnu(2)*nu**2 + 2*dnu(1)
      dnu(1) = 2*dnu(1)*nu

c update to get element-wise sensitivities
      call dsyr('L',nx,-1.d0/var,R(1,0),1,R(1,1),nx)

c compute derivatives w.r.t. length scales
      do k = 1,ndim
        dtheta(k) = 0.d0
      end do
      do j=1,nx-1
        do i=j+1,nx
          tmp = R(i,j)*R(j,i)
          do k = 1,ndim
            dtheta(k) = dtheta(k) + tmp*(X(k,i)-X(k,j))**2
          end do
        end do
      end do
      do k = 1,ndim
        dtheta(k) = 2*dtheta(k)*theta(k)
      end do
c normal return
      info = 0
      return
c error returns
  501 info = 1
      return
      end subroutine
