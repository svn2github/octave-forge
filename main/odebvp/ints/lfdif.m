## Copyright (C) 2007 Tiago Charters de Azevedo <tca@diale.org>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
## 02110-1301  USA

function sol=lfdif(ai,bi,alpha,beta,n)
#To approximate the solution of the boundary-value problem
#
#  y''=p(x)*y' + q(x)*y + r(x), a<=x<=b, y(a)=alpha, y(b)=beta
#
#by the linear finite-diffence method.
#
#Input: endpoints a, b; boundary conditions alpha, beta; integer n>=2
#Auxiliary functions (separated files user defined): p.m, q.m and r.m
#Output: (x(i),y(i)) for each i=0, 1,..., n+1
#Usage: lfdif(a,b,alpha,beta,n)

  h=(bi-ai)/(n+1);
  x=[ai+h:h:bi-h];
  a=2+h^2*q(x);
  b=-1+(h/2.)*p(x);
  c=-1-(h/2.)*p(x);

  A=spdiag(c(2:n),-1)+spdiag(a)+spdiag(b(1:n-1),1);

  d(1)=-h^2*r(x(1))+(1+(h/2.)*p(x(1)))*alpha;
  d(2:n-1)=-h^2*r(x(2:n-1));
  d(n)=-h^2*r(x(n))+(1-(h/2.)*p(x(n)))*beta;
  
  x=vertcat(ai, x', bi);
  y=vertcat(alpha, A\d', beta);

  sol=horzcat(x,y);
endfunction

