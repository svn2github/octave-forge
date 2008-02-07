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
      subroutine trstp(n,w,b,a,g,ga,s,sa,del,sal,sau,info)
c purpose:      solves the semidiagonalized mixed-norm trust region
c               subproblem: 
c               minimize: 1/2*sum(w.*s.^2) + g'*s + 
c               sa*b'*s + 1/2 a*sa^2 + ga*sa
c               subject to: norm(s) <= del, sal <= sa <= sau 
c arguments:
c n (in)        dimension of the problem
c w,b,a (in)   quadratic coefficients
c g,ga (in)     linear coefficients
c s,sa (out)    solution
c del (in)      euclidean-norm constraints
c sal,sau (in)  sa bound constrains. sal <= 0,sau >= 0.
c info (out)    type of solution:
c               info is a two-digit number in the form XY, denoting
c               that the solution is:
c                X = 0: unconstrained in s
c                X = 1: regular lagrange constr. in s
c                X = 2: singular lagrange constr. in s
c                Y = 0: unconstrained in sa
c                Y = 1: lower bound on sa active
c                Y = 2: upper bound on sa active
c
      integer n,info
      double precision w(n),b(n),a,g(n),ga,s(n),sa,del,sal,sau
      double precision delu,dell,eps,dsa,laml,lamu,lam,dlam,ss
      double precision t1,t2,dt1,dt2
      external dgemv,dlamch,dnrm2
      double precision dlamch
      integer i,nit

      dell = del * 0.9d0
      delu = del * 1.1d0
      eps = dlamch('E')
c calculate initial bracketing for lambda
      laml = max(0d0,eps*max(abs(W(1)),abs(W(n))) - W(1))
      ss = 0
      do i = 1,n
        t1 = max(abs(g(i)+sal*b(i)),abs(g(i)+sau*b(i)))
        ss = ss + t1**2
      end do
      lamu = sqrt(ss) / del - W(1)
      lam = laml
      nit = 21
c begin main loop
   10 continue
c check for maximum iterations
      if (nit == 0) then
        info = -1
        return
      end if
      nit = nit - 1
c calculate local sa coefficients
      t1 = 2*ga
      t2 = a
      do i = 1,n
        t1 = t1 - g(i)*b(i)/(w(i)+lam)
        t2 = t2 - b(i)**2  /(w(i)+lam)
      end do
      t1 = .5d0*t1
      t2 = .5d0*t2
      if (t2 <= 0) then
c the concave case. pick from sal,sau
        if (t2*(sal+sau)+t1 > 0) then
          sa = sal
        else
          sa = sau
        end if
      else
c the convex case.        
        sa = min(sau,max(sal,-.5d0*t1/t2))
      end if
c calculate s step size
      ss = 0
      do i = 1,n
        s(i) = -(g(i)+sa*b(i))/(w(i)+lam)
        ss = ss + s(i)**2
      end do
      ss = sqrt(ss)
      if (ss < dell) then
        if (lam == laml) goto 11
        lamu = lam
      else if (ss > delu) then
        laml = lam
      else
c constrained solution
        info = 10
        goto 20
      end if
c use halving interval each third step to protect against slow newton
c progress
      if (mod(nit,3) == 0) goto 12
c newton step.
      if (sa > sal .and. sa < sau) then
c derivative of sa
        dt1 = 0
        dt2 = 0
        do i = 1,n
          dt1 = dt1 + g(i)*b(i) / (w(i)+lam)**2
          dt2 = dt2 + b(i)**2   / (w(i)+lam)**2
        end do
        dt1 = .5d0*dt1
        dt2 = .5d0*dt2
        dsa = .5d0*(dt1/t2 - t1*dt2/t2**2)
      else
        dsa = 0
      end if
c derivative of ss**2      
      dlam = 0
      do i = 1,n
        dlam = dlam - 2*s(i)*(s(i)+b(i)*dsa)/(w(i)+lam)
      end do
c use newton step for 1/del - 1/ss      
      dlam = ss**2*(ss-del) / dlam
      lam = lam + dlam
      if (lam >= laml .and. lam <= lamu) goto 10
c if newton step goes outside range, use interval midpoint
   12 continue
      lam = .5d0 * (laml + lamu)
c cycle main loop
      goto 10
      
   11 continue
      if (lam == 0d0) then
c the unconstrained solution
        info = 0
      else
c the "hard case"
        s(1) = sqrt(del**2 + s(1)**2 - ss**2)
        info = 20
      end if

   20 continue
      if (info < 0) return
      if (sa == sal) info = info + 1
      if (sa == sau) info = info + 2
      return
      end subroutine



