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
      subroutine infgpr(ndim,nx,X,theta,nu,var,nlin,mu,RP,corr,
     +x0,y0,sig0,nder,yd0,work)
c purpose:      compute the prediction value, spatial derivatives 
c               and prediction variance of the GPR regressor in
c               a single spatial point. Should be used after
c               nllgpr, but *NOT* after nldgpr (on the same data).
c               note: to facilitate better precision, the vector
c               R \ y~ is not fully formed for value prediction; 
c               L \ y~ and L \ r are used instead. We use it for
c               derivatives, however, as the precision is less 
c               important there (and the converse implies multiple
c               traversals through the matrix R and thus a speed
c               tradeoff).
c arguments:
c ndim (in)     number of dimensions of input space
c nx (in)       number of training points
c X (in)        array of training input vectors
c theta (in)    length scales
c nu (in)       relative white noise. nu = sqrt(var_white/var)
c var (in)      MLE estimated global variance from nllgpr
c nlin (in)     number of linear trend variables
c mu (in)       at least nlin+1. Linear trend from nllgpr
c RP (in)       size at least nx+nx*(nx+1)/2. Contains the factorization 
c               details as computed by nllgpr, after packing the
c               triangular matrix L.
c corr          subroutine to calculate correlation value and its
c               derivative. Must be declared as follows:
c               subroutine corr(t,f,d)
c               double precision t,f,d
c               f = correlation
c               d = derivative
c               end subroutine
c               The correlation should satisfy f(0) = 1 and f(+inf) = 0.
c               t >= 0 is the scaled squared norm of input vectors
c               difference, i.e. sum(theta*(X(:,i)-X(:,j))**2)
c x0 (in)       the spatial point to predict in
c y0 (out)      the prediction values.
c sig0 (out)    the prediction sigmas (noise *not* included).
c nder(in)      number of derivatives requested. 0 to omit derivatives.
c yd0 (out)     the prediction derivatives. if nder <= 0, yd0 is not
c               referenced.
c work (out)    workspace; size at least nx*(1+min(nder,1))
c
      integer ndim,nx,nlin,nder
      real*8 X(ndim,nx),theta(ndim),nu,var,x0(ndim)
      real*8 mu(0:nlin),RP(*),y0,sig0,yd0(*),work(nx,*)
      external corr
      external dwdis2,dsdacc,dtpsv,dcopy,xerbla
      real*8 tmp,dwdis2
      integer i,j,k,info
c argument checks
      info = 0
      if (ndim < 0) then
        info = 1
      else if (nx < 1) then
        info = 2
      else if (nlin < 0 .or. nlin > ndim .or. nlin >= nx) then
        info = 7
      end if
      if (info /= 0) then
        call xerbla('infgpr',info)
        return
      end if
c calculate correlation vector r
      do i = 1,nx
        call corr(dwdis2(ndim,theta,X(1,i),x0),work(i,1),tmp)
c only use last part of workspace if derivatives requested
        if (nder > 0) work(i,2) = tmp
      end do
c form L \ r
      call dtpsv('L','N','N',nx,RP(nx+1),work(1,1),1)
c accumulate sum((L\r).^2) and (L\y)'*(L\r)
      call dsdacc(nx,work(1,1),RP,sig0,tmp)
c add linear trend
      tmp = tmp + mu(0)
      do k = 1,nlin
        tmp = tmp + x0(k)*mu(k)
      end do
      y0 = tmp
c get deviation
      sig0 = sqrt((1-sig0) * var)
c calc derivatives only if necessary
      if (nder == 0) return
      do k = 1,nder
        yd0(k) = 0
      end do
c get full solution L \ y~
      call dcopy(nx,RP,1,work(1,1),1)    
      call dtpsv('L','T','N',nx,RP(nx+1),work(1,1),1)
      do i = 1,nx
c calculate the primary part
        tmp = work(i,1)*work(i,2)
c apply chain rule
        do k = 1,nder
          yd0(k) = yd0(k) + tmp*(x0(k) - X(k,i))
        end do
      end do
c correction
      do k = 1,nder
        yd0(k) = yd0(k) * (2 * theta(k)**2)
        if (k <= nlin) yd0(k) = yd0(k) + mu(k)
      end do
      end subroutine





      

        



