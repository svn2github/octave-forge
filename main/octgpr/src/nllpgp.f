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
      subroutine nllpgp(ndim,nx,nf,X,F,y,theta,nu,var,nlin,mu,R,Q,
     +nll,corr,info)
c purpose:      calculate the negative log-likelihood of a PGP 
c               regressor, given a correlation function (along with
c               derivative), length scales and relative white noise
c               alongside estimates the constant or linear mean trend,
c               variance, and leaves data for possible subsequent use
c               of nldgpr to calculate derivatives.
c arguments:
c ndim (in)     number of dimensions of input space
c nx (in)       number of training vectors
c nf (in)       number of inducing vectors
c X (in)        array of training input vectors
c F (in)        array of inducing input vectors
c y (in)        array of training input values
c theta (in)    length scales
c nu (in)       relative white noise. nu = sqrt(var_white/var)
c var (out)     MLE estimated global variance
c nlin (in)     number of leading input variables to include in linear
c               mean trend. Set nlin = 0 to use a constant mean.
c mu (out)      at least (nlin+1)*(nlin+2). The first nlin+1 components
c               contain the components of the linear trend (constant
c               first). 
c R (out)       at least nx*(2*nf+1). The array contains useful factorization 
c               details and is reused in nldpgp.
c Q (out)       at least nf*(2*nf+nlin+3). The array contains useful factorization 
c               details and is reused in nldpgp and infpgp.
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
c info          error code. Possible values are:
c               info = 0 no problem
c               info < 0 illegal parameter value
c               info = 1 singular correlation matrix (increase nu)
c               info = 2 singular inducing matrix (move away from region)
c               info = 3 singular normal matrix (decrease nlin or
c               increase nx.
      integer ndim,nx,nf,nlin,info
      real*8 X(ndim,nx),F(ndim,nf),y(nx),theta(ndim),nu,var
      real*8 mu(0:nlin,0:nlin+1),R(nx,0:2*nf),Q(nf,2*nf+nlin+3),nll
      external corr
      external dtrsm,dgemm,dgemv,dsyrk,xerbla,dlacpy,dpotrf,
     +dlamch,dposv,dwdis2,dgesum,dsumsq
      integer i,j,nl1,iA,iB,iz
      real*8 dlamch,dwdis2,dsumsq,sums,sum,l2pi,eps
      parameter (l2pi = 1.83787706640935d0) 

c argument checks
      info = 0
      if (ndim < 0) then
        info = 1
      else if (nx < 1) then
        info = 2
      else if (nf < 1 .or. nf > nx) then
        info = 3
      else if (nlin < 0 .or. nlin > ndim .or. nlin >= nx) then
        info = 10
      end if
      if (info /= 0) then
        call xerbla('nllpgp',info)
        return
      end if

      do j = 1,nf
        do i = 1,nx
          sums = dwdis2(ndim,theta,X(1,i),F(1,j))
          call corr(sums,R(i,j),R(i,nf+j))
        end do
      end do

      do j = 1,nf
        Q(j,j) = 1
        do i = j+1,nf
          sums = dwdis2(ndim,theta,F(1,i),F(1,j))
          call corr(sums,Q(i,j),Q(i-j,nf+1-j))
        end do
      end do

      iA = nf + 1
      iz = 2*nf + 2
c save a copy of Q (columns reversed)
      do j = 1,nf
        call dcopy(nf+1-j,Q(j,j),1,Q(1,iz-j),1)
      end do

c form & factorize A = (nu2*Q + R'*R)
      call dlacpy('L',nf,nf,Q(1,1),nf,Q(1,iA),nf)
      call dsyrk('L','T',nf,nx,1d0,R(1,1),nx,nu**2,Q(1,iA),nf)
      
      call dpotrf('L',nf,Q(1,iA),nf,info)
      if (info /= 0) goto 501
      
c factorize Q
      call dpotrf('L',nf,Q(1,1),nf,info)
      if (info /= 0) goto 502
      
      nl1 = nlin + 1
c form RA = R / LA'
      call dtrsm('R','L','T','N',nx,nf,1d0,Q(1,iA),nf,R(1,1),nx)

c form z = LA \ R'*y = RA'*y 
      call dgemv('T',nx,nf,1d0,R(1,1),nx,y,1,0d0,Q(1,iz),1)

c form B = LA \ R'*M = RA'*M
      iB = iz + 1
      call dgesum('N',nx,nf,R(1,1),nx,Q(1,iB),1)
      call dgemm('T','T',nf,nlin,nx,1d0,R(1,1),nx,X,ndim,
     +           0d0,Q(1,iB+1),nf)

c form E = M'*M - B'*B
      mu(0,1) = nx
      call dgesum('T',nlin,nx,X,ndim,mu(1,1),1)
      call dsyrk('L','N',nlin,nx,1d0,X,ndim,0d0,mu(1,2),nl1)
      call dsyrk('L','T',nl1,nf,-1d0,Q(1,iB),nf,1d0,mu(0,1),nl1)

c form w = M'*y - M'*R/A*R'*y = M'*y - B'*z
      call dgesum('N',nx,1,y,nx,mu(0,0),1)
      call dgemv('N',nlin,nx,1d0,X,ndim,y,1,0d0,mu(1,0),1)
      call dgemv('T',nf,nl1,-1d0,Q(1,iB),nf,Q(1,iz),1,1d0,mu(0,0),1)
            
c solve mu = E \ w
      call dposv('L',nl1,1,mu(0,1),nl1,mu(0,0),nl1,info) 
      if (info /= 0) goto 503

c update zz = LA \ R' * (y - M*mu) = z - B*mu
      call dgemv('N',nf,nl1,-1d0,Q(1,iB),nf,mu,1,1d0,Q(1,iz),1)

c form yy = y - M*mu      
      do i = 1,nx
        R(i,0) = y(i) - mu(0,0)
      end do
      call dgemv('T',nlin,nx,-1d0,X,ndim,mu(1,0),1,1d0,R(1,0),1)

      var = dsumsq(nx,R(1,0),1) - dsumsq(nf,Q(1,iz),1)
      var = nu**(-2) * var / nx

      sum = log(nu)*(nx-nf)
      do i = 1,nf
        sum = sum - log(Q(i,i))
      end do
      do i = 1,nf
        sum = sum + log(Q(i,nf+i))
      end do
      
c final negative log likelihood
      nll = sum + 0.5d0 * nx*(log(var) + l2pi)

c normal return
      info = 0
      return
c error returns
  501 info = 1
      return
  502 info = 2
      return
  503 info = 3
      return

      end subroutine
