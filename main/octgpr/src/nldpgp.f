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
      subroutine nldpgp(ndim,nx,nf,X,F,theta,nu,var,R,Q,
     +dtheta,dnu,info)
c purpose:      calculate the negative log-likelihood of a PGP 
c               regressor, given a correlation function (along with
c               derivative), length scales and relative white noise
c               alongside estimates the constant or linear mean trend,
c               variance, and leaves data for possible subsequent use
c               of nldgpr to calculate derivatives.
c arguments:
c ndim (in)     number of dimensions of input space
c nx (in)       number of training points
c X (in)        array of training input vectors
c F (in)        array of inducing input vectors
c theta (in)    length scales
c nu (in)       relative white noise. nu = sqrt(var_white/var)
c var(out)      MLE estimated global variance, multiplied by nu**2
c R (out)       at least nx*(2*nf+1). The array contains useful factorization 
c               details and is reused in nldpgp.
c Q (out)       at least nf*(2*nf+nlin+2). The array contains useful factorization 
c               details and is reused in nldpgp and infpgp.
c dtheta (out)  derivatives w.r.t. length scales
c dnu (out)     derivative and second derivative w.r.t. relative noise
c info          error code. Possible values are:
c               info = 0 no problem
c               info < 0 illegal parameter value
c               info = 1 singular correlation matrix (increase nu)
c               info = 2 singular normal matrix (decrease nlin or
c               increase nx.
      integer ndim,nx,nf,info
      real*8 X(ndim,nx),F(ndim,nf),theta(ndim),nu,var
      real*8 R(nx,0:2*nf),Q(nf,2*nf+2)
      real*8 dtheta(ndim),dnu
      integer i,j,nl1,iA,iB,iz
      real*8 ddot,nu2,nu2i,elm,fac,dld,dvar
      external ddot,dtrsm,dtrsv,dpotri,dger,dsyr
      parameter (l2pi = 1.83787706640935d0) 

c argument checks
      info = 0
      if (ndim < 0) then
        info = 1
      else if (nx < 1) then
        info = 2
      else if (nf < 1 .or. nf > nx) then
        info = 3
      end if
      if (info /= 0) then
        call xerbla('nldpgp',info)
        return
      end if

      iA = nf + 1
      iz = 2*nf + 2

c form ya = yy - RA * zz
      call dgemv('N',nx,nf,-1d0,R(1,1),nx,Q(1,iz),1,1d0,R(1,0),1)

c update RA = R/A = RA / LA
      call dtrsm('R','L','N','N',nx,nf,1d0,Q(1,nf+1),nf,R(1,1),nx)

c update z = A \ R'*y = LA' \ z
      call dtrsv('L','T','N',nf,Q(1,nf+1),nf,Q(1,iz),1)

c turn LA into inv(A)
      call dpotri('L',nf,Q(1,nf+1),nf,info)
      if (info /= 0) goto 501

c turn LQ into inv(Q)
      call dpotri('L',nf,Q(1,1),nf,info)
      if (info /= 0) goto 502

      nu2 = nu**2
      nu2i = 1/nu2

c theta derivatives
      do k = 1,ndim
        dtheta(k) = 0d0
      end do

      fac = -1d0/var
      call dsyr('L',nf,fac,Q(1,iz),1,Q(1,1),nf)
c compute dld part      
      do j = 1,nf-1
        do i = j+1,nf
          elm = (nu2*Q(i,nf+j) - Q(i,j)) * Q(i-j,nf+1-j)
          do k = 1,ndim
            dtheta(k) = dtheta(k) + elm*(F(k,i)-F(k,j))**2
          end do
        end do
      end do

      fac = -nu2i/var
      call dger(nx,nf,fac,R(1,0),1,Q(1,iz),1,R(1,1),nx)
      do j = 1,nf
        do i = 1,nx
          elm = R(i,j) * R(i,j+nf) 
          do k = 1,ndim
            dtheta(k) = dtheta(k) + elm*(X(k,i)-F(k,j))**2
          end do
        end do
      end do

      do k = 1,ndim
        dtheta(k) = 2*theta(k)*dtheta(k)
      end do

c nu derivative
c compute 1/2*trace(inv(A)*Q)
      dld = 0d0
      do j = 1,nf
        dld = dld + .5d0 * Q(j,nf+j)*Q(1,iz-j)
        if (j < nf) then
          dld = dld + ddot(nf-j,Q(j+1,nf+j),1,Q(2,iz-j),1)
        end if
      end do
c compute dld part
      dld = dld + .5d0 * (nx-nf)*nu**(-2)
c compute 1/2*zz'*Q*zz
      dvar = 0d0
      do j = 1,nf
        dvar = dvar + .5d0 * Q(1,iz-j)*Q(j,iz)**2
        if (j < nf) then
          dvar = dvar + ddot(nf-j,Q(2,iz-j),1,Q(j+1,iz),1)*Q(j,iz)
        end if
      end do
c compute dvar part
      dvar = -nu**(-2) * (.5d0*nx - dvar/var)
c calc dnu 
      dnu = 2*nu * (dld + dvar)

c normal return
      info = 0
      return
c error returns
  501 info = 1
      return
  502 info = 2
      return

      end subroutine
      
