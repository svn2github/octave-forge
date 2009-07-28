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
      subroutine pakpgp(nf,nlin,mu,Q,mup,QP)
c purpose:      packs the necessary data and other factorization details
c               as obtained by nllpgp. Used primarily to reduce stored
c               model size and save invariant computations in infpgp.
c arguments:
c nf (in)       number of inducing vectors
c mu (in)       as returned from nllpgp
c Q (in)        as returned from nllpgp
c mup (out)     the stripped down mu array
c QP (out)      the stripped down Q array
      integer nf,nlin
      real*8 mu(0:nlin,*),Q(nf,*),mup(*),QP(nf,*)
      external dcopy,dtrsv
      integer j

      call dcopy(nlin+1,mu,1,mup,1)
      do j = 1,nf
        call dcopy(nf+1-j,Q(j,j),1,QP(j,j),1)
        call dcopy(nf+1-j,Q(j,j+nf),1,QP(j,j+1),nf)
      end do
      call dcopy(nf,Q(1,2*nf+2),1,QP(1,nf+2),1)
      call dcopy(nf,Q(1,2*nf+2),1,QP(1,nf+3),1)
      call dtrsv('L','T','N',nf,Q(1,nf+1),nf,QP(1,nf+3),1)
      end subroutine
