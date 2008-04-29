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
      subroutine nllgpr(ndim,nx,X,y,theta,nu,var,nlin,mu,R,
     +nll,corr,info)
c purpose:      calculate the negative log-likelihood of a GPR process
c               regressor, given a correlation function (along with
c               derivative), length scales and relative white noise
c               alongside estimates the constant or linear mean trend,
c               variance, and leaves data for possible subsequent use
c               of nldgpr to calculate derivatives.
c arguments:
c ndim (in)     number of dimensions of input space
c nx (in)       number of training points
c X (in)        array of training input vectors
c y (in)        array of training input values
c theta (in)    length scales
c nu (in)       relative white noise. nu = sqrt(var_white/var)
c var (out)     MLE estimated global variance
c nlin (in)     number of leading input variables to include in linear
c               mean trend. Set nlin = 0 to use a constant mean.
c mu (out)      at least (nlin+1)*3. The first nlin+1 components
c               contain the components of the linear trend (constant
c               first). 
c R (out)       at least (nx)*(nx+2+nlin). The first nx*(nx+1) components
c               contain useful factorization details and are reused in 
c               nldgpr
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
c               info = 2 singular normal matrix (decrease nlin or
c               increase nx.
      integer ndim,nx,nlin,info
      real*8 X(ndim,nx),y(nx),theta(ndim),nu,var
      real*8 mu(0:nlin,0:2),R(nx,0:nx+1+nlin),nll
      external corr
      external dwdis2,dcopy,daxpy,dscal,dtrsv,dtrsm,xerbla,
     +dpotrf,dtrtrs,dgeqr2,dorm2r
      integer i,j,nl1
      real*8 sums,sum,dwdis2

c argument checks
      info = 0
      if (ndim < 0) then
        info = 1
      else if (nx < 1) then
        info = 2
      else if (nlin < 0 .or. nlin > ndim .or. nlin >= nx) then
        info = 8
      end if
      if (info /= 0) then
        call xerbla('nllgpr',info)
        return
      end if

c corc should store the correlation to R(i,j), and its
c derivative w.r.t. squared distance to R(j,i)

c create the lower half of the symmetric correlation matrix
      do j = 1,nx
        R(j,j) = 1 + nu**2
        do i = j+1,nx
c accumulate theta-weighted distance
          sums = dwdis2(ndim,theta,X(1,i),X(1,j))
c call the supplied subroutine to calculate correlation and its
c derivative. Note that the derivatives are stored.
          call corr(sums,R(i,j),R(j,i))
        end do
      end do

c cholesky factorization of lower R triangle 
      call dpotrf('L',nx,R(1,1),nx,info)
      if (info /= 0) goto 501
      
      call dcopy(nx,y,1,R(1,0),1)
c form M = ones(nx,1)
      do i = 1,nx
        R(i,nx+1) = 1.d0
      end do
      if (nlin > 0) then
c form M = [ones(nx,1) X']
        do j = 1,ndim
          call dcopy(nx,X(j,1),ndim,R(1,nx+1+j),1)
        end do
      end if
c form m = L \ y
      call dtrsv('L','N','N',nx,R(1,1),nx,R(1,0),1)
      
      if (nlin > 0) then
        nl1 = nlin + 1
c fit a linear model using QR decomposition

c form L \ M
        call dtrsm('L','L','N','N',nx,nl1,
     +             1.d0,R(1,1),nx,R(1,nx+1),nx)
c factorize (unblocked code) Q*R = L \ M
        call dgeqr2(nx,nl1,R(1,nx+1),nx,mu(0,1),mu(0,2),info) 
c form yy = Q' * (L \ y)
        call dorm2r('L','T',nx,1,nl1,R(1,nx+1),nx,mu(0,1),
     +              R(1,0),nx,mu(0,2),info)
c copy yy(1:nlin+1)
        call dcopy(nl1,R(1,0),1,mu(0,0),1)
c set to zero to get residual yy(1:nlin+1) = 0 
        call dscal(nl1,0d0,R(1,0),1)
c project to residual space: Q*Q' * yy
        call dorm2r('L','N',nx,1,nl1,R(1,nx+1),nx,mu(0,1),
     +              R(1,0),nx,mu(0,2),info)
c solve R \ yy(1:nlin+1) for linear trend
        call dtrtrs('U','N','N',nl1,1,R(1,nx+1),nx,mu(0,0),
     +              nl1,info)
        if (info /= 0) goto 502
      else
c specialized for constant fitting - for speed (and clarity, as this was
c the initial version
c form L \ m
        call dtrsv('L','N','N',nx,R(1,1),nx,R(1,nx+1),1)
c accumulate (m'*inv(R)*m) and (y'*inv(R)*m)
        call dsdacc(nx,R(1,nx+1),R(1,0),sums,sum)
        if (sums == 0d0) goto 502
c store the mean and matrix (1x1)
        mu(0,1) = sums
        mu(0,0) = sum / sums
c remove the linear trend from L \ y
        call daxpy(nx,-mu(0,0),R(1,nx+1),1,R(1,0),1)
      end if
      
c estimate variance
      sums = 0
      do i = 1,nx
        sums = sums + R(i,0)**2
      end do
      var = sums / nx
c form trace
      sum = 0
      do i = 1,nx
        sum = sum + log(R(i,i))
      end do

c final negative log likelihood
      nll = sum + 0.5d0 * nx*log(var)
c normal return
      info = 0
      return
c error returns
  501 info = 1
      return
  502 info = 2
      return
      end subroutine
