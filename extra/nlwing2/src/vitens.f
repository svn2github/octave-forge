c Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
c 
c Author: Jaroslav Hajek <highegg@gmail.com>
c 
c This file is part of NLWing2.
c 
c NLWing2 is free software; you can redistribute it and/or modify
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
      subroutine vitens(np,alfa,xAC,yAC,zAC,sym,vx0,vxg,vy0,vyg)
c purpose:      builds the induced velocities influence tensor for an
c               array of horseshoe vortices.
c               that is, this subroutine computes the tensors vxg, vyg,
c               vx0, vy0 such that
c               vx(i) = sum(vxg(i,j)*gam(j)) + vx0(i)
c               vy(i) = sum(vyg(i,j)*gam(j)) + vy0(i)
c               where gam(j) is the local circulation.
c
c arguments:
c np (in)       number of panels
c AC (in)       0..np points on curve of aerodynamic centers.
c alfa (in)     the global angle of attack (relative to x axis)
c sym (in)      if true, indicates the symmetric case - each
c               horseshoe vortex is also mirrored by the y=0 plane.
c vx0,vy0 (out) the effective local velocities induced by pure
c               freestream. (np)
c vxg,vyg (out) the influence tensor for effective local 
c               velocities induced by horseshoe vortices. element 
c               (i,j) is the influence of i-th horseshoe vortex at 
c               j-th collocation point. (np,np)
c
      integer np
      real*8 xAC(0:np),yAC(0:np),zAC(0:np),alfa,
     +       vxg(np,np),vx0(np),vyg(np,np),vy0(np)
      logical sym,lsym
      external vindb,vindf
      real*8 calf,salf,CP(3,np),RA(3,np),RAn(np),RB(3),RBn,
     +       vif(3,np),vil(3,np),ACj(3),c2(np),c3(np),cs
      integer i,j,k
      calf = cos(alfa)
      salf = sin(alfa)
c setup collocation points      
      do i = 1,np
        CP(1,i) = 0.5*(xAC(i-1)+xAC(i))
        CP(2,i) = 0.5*(yAC(i-1)+yAC(i))
        CP(3,i) = 0.5*(zAC(i-1)+zAC(i))
c calc the local angle coeffs
        c3(i) = yAC(i) - yAC(i-1)
        c2(i) = zAC(i) - zAC(i-1)
        cs = sqrt(c2(i)**2+c3(i)**2)
        c2(i) = c2(i) / cs
        c3(i) = -c3(i) / cs
        vx0(i) = calf
        vy0(i) = c2(i)*salf
      end do
      lsym = sym
    1 continue
c store radiusvectors to first row, along with their norms
      call reflec(xAC(0),yAC(0),zAC(0),lsym,ACj)
      do i = 1,np
        call radvec(CP(1,i),ACj,RA(1,i),RAn(i))
        call vindf(RA(1,i),RAn(i),calf,salf,vif(1,i))
      end do
c now loop through cuts, inner loop through colloc points      
      do j = 1,np
        call reflec(xAC(j),yAC(j),zAC(j),lsym,ACj)
        do i = 1,np
          call radvec(CP(1,i),ACj,RB,RBn)
c omit bound vortex on singularity 
          if (i /= j .or. lsym) then
            call vindb(RA(1,i),RAn(i),RB,RBn,vil(1,i))
          else
            do k = 1,3
              vil(k,i) = 0d0
            end do
          end if
c subtract free vortex (j-1-th)
          do k = 1,3
            vil(k,i) = vil(k,i) - vif(k,i)
          end do
c calc new free vortex (j-th)
          call vindf(RB,RBn,calf,salf,vif(1,i))
          do k = 1,3
            vil(k,i) = vil(k,i) + vif(k,i)
          end do
c store new radiusvector          
          do k = 1,3
            RA(k,i) = RB(k)
          end do
          RAn(i) = RBn
        end do
c distribute the current column        
c store or add, whatever the case is
        if (sym .eqv. lsym) then
          do i = 1,np
            vxg(i,j) = vil(1,i)
            vyg(i,j) = c2(i)*vil(2,i) + c3(i)*vil(3,i)
          end do
        else
          do i = 1,np
            vxg(i,j) = -vxg(i,j) + vil(1,i)
            vyg(i,j) = -vyg(i,j) + c2(i)*vil(2,i) + c3(i)*vil(3,i)
          end do
        end if
      end do
      lsym = .not. lsym
c go again without reflectors
      if (.not.lsym) goto 1
      end

      subroutine reflec(xACj,yACj,zACj,lsym,ACj)
c purpose:      stores three coordinates to local array, possibly
c               reflecting the trailing one
c xACj (in)     x coord
c yACj (in)     y coord
c zACj (in)     z coord
c lsym (in)     reflection flag
c ACj (out)     reflected point
      real*8 xACj,yACj,zACj,ACj(3)
      logical lsym
      ACj(1) = xACj
      ACj(2) = yACj
      if (lsym) then
        ACj(3) = -zACj
      else
        ACj(3) = zACj
      end if
      end

      subroutine radvec(CP,X,RX,RXn)
c purpose:      calculate a radius vector, along with norm
c arguments:    
c CP (in)       collocation point
c X (in)        origin
c RX (out)      radiusvector
c RXn (out)     its norm      
      real*8 CP(3),X(3),RX(3),RXn
      RX(1) = X(1) - CP(1)
      RX(2) = X(2) - CP(2)
      RX(3) = X(3) - CP(3)
      RXn = sqrt(RX(1)**2+RX(2)**2+RX(3)**2)
      end

      subroutine vindb(RA,RAn,RB,RBn,vi)
c purpose:      calculates induced velocity from a bound vortex
c arguments:
c RA,RB (in)    radiusvectors to bound segment endpoints, i.e.
c               RA = A-CP, RB = B-CP where CP is the collocation
c               point.
c RAn,RBn (in)  computed norms of RA,RB (passed here to gain
c               efficiency in VITENS)
c vi (out)      the induced velocity (by unit circulation)
c
      real*8 RA(3),RAn,RB(3),RBn,vi(3)
      real*8 dot,Rf,pi4i
      parameter(pi4i = -0.0795774715459477d0)
      dot = RA(1)*RB(1) + RA(2)*RB(2) + RA(3)*RB(3)
      Rf = pi4i * (RBn + RAn) / (RAn*RBn*(RAn*RBn + dot))
      vi(1) = Rf*(RA(2)*RB(3) - RA(3)*RB(2))
      vi(2) = Rf*(RA(3)*RB(1) - RA(1)*RB(3))
      vi(3) = Rf*(RA(1)*RB(2) - RA(2)*RB(1))
      end

      subroutine vindf(RA,RAn,ca,sa,vi)
c purpose:      calculates induced velocity from a free vortex
c arguments:
c RA (in)       radiusvector to the starting point, i.e.
c               RA = A-CP, where CP is the collocation point.
c RAn (in)      computed norm of RA (passed here to gain
c               efficiency in VITENS)
c ca,sa (in)    cosine and sine of the global angle of attack
c               (the freestream velociy direction is [ca sa 0])
c vi (out)      the induced velocity (by unit circulation)
c
      real*8 RA(3),RAn,ca,sa,vi(3)
      real*8 dot,Rf,pi4i
      parameter(pi4i = -0.0795774715459477d0)
      dot = RA(1)*ca + RA(2)*sa
      Rf = pi4i / (RAn*(RAn + dot))
      vi(1) = Rf*(         - RA(3)*sa)
      vi(2) = Rf*(RA(3)*ca           )
      vi(3) = Rf*(RA(1)*sa - RA(2)*ca)
      end
      
