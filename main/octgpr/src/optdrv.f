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
      subroutine optdrv(ndim,theta,nu,nll,dtheta,dnu,
     +                       theta0,nu0,nll0,dtheta0,dnu0,
     +                  info,scal,l2nu,VM,CP,IC)
c purpose:      the optimization driver for training hyperparameters
c               via mixed-norm trust-region quasi-newton method.     
c arguments:
c ndim (in)     number of spatial dimensions.
c theta (io)    current spatial length scales
c nu (io)       current noise
c nll (in)      evaluated nll at theta
c dtheta (in)   derivatives w.r.t. theta
c dnu (in)      derivative(s) w.r.t. nu. (>=2 if l2nu is .true.)
c theta0        stored best theta
c nu0 (io)      likewise
c nll0 (in)     likewise
c dtheta0 (in)  likewise
c dnu0 (in)     likewise
c info (io):    On input, signalizes:
c                0: initial iterate
c                1: successful step
c                2: unsuccessful step
c l2nu (in):    indicates that exact 2nd derivatives are computed
c               and stored in dnu(2) and dnu0(2).
c
c scal (in)     length scales
c VM (in)       stores the variable metric information. must be sized
c               at least (ndim+1)*(3*ndim+2)/2
c CP (in)       control parameters.
c                CP(1) minimum noise. at least sqrt(1d1*macheps)
c                CP(2) noise scale factor. default 1d-4
c                CP(3) minimum TR radius (step tolerance)
c                CP(4) maximum TR radius (default 5d-1)
c                CP(5) decrease factor (default 0.7d0)
c                CP(6) increase factor (default 1.4d0)
c                CP(7) current TR radius (set on initial entry)
c                CP(8) last spatial step size
c                CP(9) last noise step size
c                CP(10) model-predicted reduction in last step
c                CP(11) the objective upper limit
c                CP(12) the objective reduction tolerance
c                CP(13) last relative reduction of objective
c
c IC (in)       integer counters
c                IC(1) number of evaluations
c                IC(2) number of downhill steps
c                IC(3) last flags from trstp
      integer ndim,info,IC(3)
      double precision scal(ndim),theta(ndim),nu,nll,
     +                 dtheta(ndim),dnu(*),
     +                 theta0(ndim),nu0,nll0,
     +                 dtheta0(ndim),dnu0(*)
      logical l2nu
      double precision VM(*),CP(13)
      double precision stp(ndim+1),grd(ndim+1),Zg(ndim),Zba(ndim),
     +snlo,snup,eps,ss,relr
      double precision dlamch,dnrm2,ddot
      external dlamch,dspmid,trstp,dnrm2,ddot
      integer iB,iba,iW,iZ,i
c setup pointers into VM
      iB = 1     
      iba = iB + ndim*(ndim+1)/2
      iW = iba + ndim+1
      iZ = iW + ndim

      if (info == 1) then
c go directly to downhill if there is no last step
        if (IC(1) == 0) then
c if the first objective is better than the limit value,
c replace the limit value.           
          CP(11) = min(CP(11),nll)
          goto 150
        end if
c compute the reduction success ratio
        CP(10) = (nll - nll0) / CP(10)
        if (CP(10) < 0.1d0) then
          CP(7) = CP(7)*CP(5)
          if (CP(7) < CP(3)) goto 95
        else if (CP(10) > 0.7d0) then
c if the last step was unconstrained, shrink step size
          if (IC(3) == 0) then
            CP(7) = max(CP(8),CP(9))
            if (CP(7) < CP(3)) goto 95
          else
            CP(7) = CP(7)*CP(6)
          end if
        end if
        goto 100
      else if (info == 2) then
        if (IC(1) == 0) then
c initial guess failed. This is really bad.
          info = -1
          return
        end if
        CP(7) = CP(7) * CP(5)**1.5
        goto 200
      else
        goto 90
      end if

   90 continue
c THE INITIAL ITERATION
      IC(1) = 0
      IC(2) = 0
c supply default values if necessary
      eps = sqrt(dlamch('E'))
      if (CP(1) < eps) CP(1) = eps
      if (CP(2) == 0d0) CP(2) = 1d-4
      if (CP(3) <  0d0) CP(3) = 1d-6
      if (CP(4) == 0d0) CP(4) = 1d+2
      if (CP(5) == 0d0) CP(5) = 0.6d0
      if (CP(6) == 0d0) CP(6) = 1.5d0
      if (CP(7) == 0d0) CP(7) = max(dxnrm2(ndim,scal,theta),nu/CP(2))
      if (CP(12) < 0d0) CP(12) = 1d-6
      CP(13) = CP(12)
c set VM matrix to a multiple of identity
      call dspmid('U',ndim+1,1d-2,VM(iB))
      nll0 = dlamch('O')
      info = 0
      return
c SUCCESSFUL TERMINATION
   95 continue
      info = 1
      return

  100 continue
C UPDATE METRIC
c recover step and compute gradient difference
      do i = 1,ndim
        stp(i) = theta(i)-theta0(i)
        grd(i) = dtheta(i)-dtheta0(i)
      end do
      stp(ndim+1) = nu - nu0
      grd(ndim+1) = dnu(1) - dnu0(1)
c update the VM matrix
c TODO: could the SR1 update be modified to take advantage
c of the known dnu(2)?
      call sr1upd('U',ndim+1,stp,grd,VM)

  150 continue
c HANDLE SUCCESSFUL STEP      
      IC(1) = IC(1) + 1
c check downhill step
      if (nll < nll0) then
c compute the relative progress
        if (nll0 < CP(11)) then
          relr = (nll - nll0) / (nll0 - CP(11))
        else
          relr = 0d0
        end if
c process downhill step        
        IC(2) = IC(2) + 1
        do i = 1,ndim
          theta0(i) = theta(i)
          dtheta0(i) = dtheta(i)
        end do
        nu0 = nu
        dnu0(1) = dnu(1)
        if (l2nu) dnu0(2) = dnu(2)
        nll0 = nll
c check second termination criterion
        if (IC(2) > 1 .and. relr < CP(13) .and. CP(13) < CP(12)) then
c indicate termination          
          info = 2
          return
        end if
        CP(13) = relr
      end if
c overwrite the second derivative with the exact value
      VM(iba+ndim) = dnu0(2)
c scale and factorize the VM matrix
      call dscsev(ndim,VM(iB),scal,VM(iW),VM(iZ),i)
c TODO: what to do if dscsev fails?
      
  200 continue
c GENERATE NEW TRIAL POINT
c unscale and rotate
      call dcopy(ndim,dtheta0,1,Zg,1)
      call dscrot('N',ndim,scal,VM(iZ),Zg)
      call dcopy(ndim,VM(iba),1,Zba,1)
      call dscrot('N',ndim,scal,VM(iZ),Zba)
c compute a trust-region step
      snup = CP(7)*CP(2)
      snlo = max(-snup,CP(1)-nu0)
      call trstp(ndim,VM(iW),Zba,VM(iba+ndim),Zg,dnu0(1),
     +            stp(1),stp(ndim+1),CP(7),snlo,snup,IC(3))
c if nu is constrained from below, but forced by numin, indicate this
c as unconstrained step.
      if (mod(IC(3),10) == 1 .and. -snlo < snup) IC(3) = IC(3)-1
c scale & rotate
      call dscrot('T',ndim,scal,VM(iZ),stp)
c update step sizes
      CP(8) = dxnrm2(ndim,scal,stp)
      CP(9) = abs(stp(ndim+1)/CP(2))
c predict actual reduction
      call dcopy(ndim,dtheta0,1,grd,1)
      grd(ndim+1) = dnu0(1)
      call dspmv('U',ndim+1,.5d0,VM,stp,1,1d0,grd,1)
      CP(10) = ddot(ndim+1,grd,1,stp,1)
c setup new trial point
      do i = 1,ndim
        theta(i) = theta0(i) + stp(i)
      end do
      nu = nu0 + stp(ndim+1)
c normal return - ready for next evaluation
      info = 0
      end subroutine


