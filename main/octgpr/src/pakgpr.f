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
      subroutine pakgpr(nx,nlin,mu,R,mup,RP)
c purpose:      packs the necessary data and other factorization details
c               as obtained by nllgpr. Used primarily to reduce stored
c               model size and save invariant computations in infgpr.
c arguments:
c nx (in)       number of training points
c nlin (in)     number of linear trend variables
c mu (in)       as returned from nllgpr
c mup (out)     size at least nlin+1. Contains the mean.
c R (in)        dtto
c RP (in)       size at least 2*nx+nx*(nx+1)/2. Contains the factorization 
c               details as computed by nllgpr, after packing the
c               triangular matrix L.
c
      integer nx,nlin
      real*8 mu(nlin+1,*),R(nx,*),mup(*),RP(*)
      external dcopy,dtrsv,dtr2tp

      call dcopy(nlin+1,mu,1,mup,1)
      call dcopy(nx,R(1,1),1,RP(1),1)
      call dcopy(nx,R(1,1),1,RP(nx+1),1)
      call dtrsv('L','T','N',nx,R(1,2),nx,RP(nx+1),1)
      call dtr2tp('L','N',nx,R(1,2),nx,RP(2*nx+1))

      end subroutine
