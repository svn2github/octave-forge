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
      subroutine corgau(t,f,d)
c the gaussian correlation exp(-x^2)
      double precision t,f,d
      f = exp(-t)
      d = -f
      end subroutine

      subroutine corexp(t,f,d)
c the exponential correlation exp(-x)
      double precision t,f,d
      f = exp(-sqrt(t))
      d = -f / (2*sqrt(t))
      end subroutine

c inverse multiquadric
      subroutine corimq(t,f,d)
      double precision t,f,d
      f = 1 / sqrt(1+t**2)
      d = -2*t / f**3
      end subroutine





