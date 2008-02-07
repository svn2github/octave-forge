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
      subroutine nllbnd(nx,y,nu,nll0,nllinf)
c purpose:      this function evaluates the negative log likelihood
c               of a GPR process regressor at boundaries:
c               nll0 is a common value for theta = 0 and
c               nllinf is a value for theta = infinity.
c nx (in)       number of training points
c y (in)        array of training input values
c nu (in)       relative white noise. nu = sqrt(var_white/var)
c nll0 (out)    the value of nllgpr for theta = 0
c nllinf (out)  the limit of nllgpr at theta -> infinity.
c
      integer nx
      double precision y(nx),nu,nll0,nllinf
      double precision mu,ssq
      integer i
      
      mu = 0
c calculate mean
      do i = 1,nx
        mu = mu + y(i)
      end do
      mu = mu / nx
c calculate sigma estimate
      ssq = 0
      do i = 1,nx
        ssq = ssq + (y(i)-mu)**2
      end do
c set values
      ssq = ssq / nx
      nllinf = 0.5d0 * nx * log(ssq)
      nll0 = nllinf + 0.5d0 * log(1 + nx/nu**2)
      end subroutine





