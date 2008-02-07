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
      program test
      integer n
      parameter(n = 2)
      double precision w(n),ba(n),a,g(n),ga,s(n),sa,del,sal,sau
      integer i,j,info
      open(10,file='testcm.dat')
      read(10,*) i
      if (i /= n) stop 'dim mismatch'
      read(10,*) w
      read(10,*) ba,a
      read(10,*) g,ga
      read(10,*) del,sal,sau
      read(10,*) s,sa
      write(*,*) w
      write(*,*) ba,a
      write(*,*) g,ga
      write(*,*) del,sal,sau
      write(*,*) s,sa
      print *,'mval = ',sum(w*s**2)/2+sum((g+sa*ba)*s)+ga*sa+a*sa**2/2
      close(10)
      call trstp(n,w,ba,a,g,ga,s,sa,del,sal,sau,info)
      print *,'s = ',s,' sa = ',sa,' info = ',info
      print *,'mval = ',sum(w*s**2)/2+sum((g+sa*ba)*s)+ga*sa+a*sa**2/2
      end program
