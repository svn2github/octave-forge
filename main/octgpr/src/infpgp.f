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
      subroutine infpgp(ndim,nf,F,theta,nu,var,nlin,mu,QP,corr,
     +x0,y0,sig0,nder,yd0,work)
c purpose:      compute the prediction value, spatial derivatives 
c               and prediction variance of the PGP regressor in
c               a single spatial point. Should be used after
c               nllpgp, but *NOT* after nldpgp (on the same data).
c arguments:
c ndim (in)     number of dimensions of input space
c nf (in)       number of inducing vectors
c F (in)        array of inducing input vectors
c theta (in)    length scales
c nu (in)       relative white noise. nu = sqrt(var_white/var)
c var (out)     MLE estimated global variance
c nlin (in)     number of leading input variables to include in linear
c               mean trend. Set nlin = 0 to use a constant mean.
c mu (out)      at least (nlin+1)*(nlin+2). The first nlin+1 components
c               contain the components of the linear trend (constant
c               first). 
c QP (out)      at least nf*(nf+3). The array contains packed factorization 
c               details as returned from pakpgp
c nll (out)     the negative log-likelihood
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
c sig0 (out)    the prediction sigmas (noise included).
c nder(in)      number of derivatives requested. 0 to omit derivatives.
c yd0 (out)     the prediction derivatives. if nder <= 0, yd0 is not
c               referenced.
c work (out)    workspace; size at least nf*(2+min(nder,1))
c
      integer ndim,nf,nlin,info
      real*8 F(ndim,nf),theta(ndim),nu,var,x0(ndim)
      real*8 mu(0:nlin),QP(nf,*),y0,sig0,yd0(*),work(nf,*)
      external corr
      external dtrsv,dgemv,dwdis2,dsumsq,dsdacc
      integer i,j,iz
      real*8 dwdis2,dsumsq,sums,sum,l2pi,eps,tmp

      iz = nf+2
c calculate correlation vector r
      do i = 1,nf
        call corr(dwdis2(ndim,theta,F(1,i),x0),work(i,1),tmp)
        work(i,2) = work(i,1)
c only use last part of workspace if derivatives requested
        if (nder > 0) work(i,3) = tmp
      end do
c form LA \ r
      call dtrsv('U','T','N',nf,QP(1,2),nf,work(1,1),1)
c accumulate sum((L\r).^2) and (L\y)'*(L\r)
      call dsdacc(nf,work(1,1),QP(1,iz),sig0,tmp)
c add linear trend
      tmp = tmp + mu(0)
      do k = 1,nlin
        tmp = tmp + x0(k)*mu(k)
      end do
      y0 = tmp
c form LQ \ r
      call dtrsv('L','N','N',nf,QP(1,1),nf,work(1,2),1)
      sig0 = 1 + nu**2*(1+sig0) - dsumsq(nf,work(1,2),1)
c get deviation
      sig0 = sqrt(sig0 * var)
c calc derivatives only if necessary
      if (nder == 0) return
      do k = 1,nder
        yd0(k) = 0
      end do
      do i = 1,nf
c calculate the primary part
        tmp = QP(i,iz+1)*work(i,3)
c apply chain rule
        do k = 1,nder
          yd0(k) = yd0(k) + tmp*(x0(k) - F(k,i))
        end do
      end do
c correction
      do k = 1,nder
        yd0(k) = yd0(k) * (2 * theta(k)**2)
        if (k <= nlin) yd0(k) = yd0(k) + mu(k)
      end do
      end subroutine
