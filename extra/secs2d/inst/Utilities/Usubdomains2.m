## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## SECS2D is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
##
## AUTHOR: Carlo de Falco <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
##
## @deftypefn {Function File}@
## {@var{e},@var{t}} = Usubdomains2(@var{p},@var{t},@var{rcts},@var{sidelist})
##
## Subdivide domain according to position of elements center of mass 
##
## @end deftypefn

function [e,t] = Usubdomains2(p,t,rcts,sidelist);

  e = [];

  ## Get elements center of mass coordinates
  x  = p(1,:);
  y  = p(2,:);
  mx = sum(x(t(1:3,:)),1)/3;
  my = sum(y(t(1:3,:)),1)/3;

  t(4,:) = 1;

  ## Loop over rectangular regions
  for ii = 1:size(rcts,1)
    
    ## Find elements with center of mass in this rectangle
    trs = find ((mx>rcts(ii,1))&(mx<rcts(ii,2))&(my>rcts(ii,3))&(my<rcts(ii,4)));
    ## Set subdomain number
    t(4,trs) = ii+1;
    
  endfor

  ## Get all element edges
  sides      = [t([1 2 4],:),t([2 3 4],:),t([3 1 4],:)];
  sides(4,:) = 0;
  ns         = size(sides,2);

  ## Build list of edges using conditions on segment vertex coordinates
  x1 = p(1,sides(1,:)) ;
  x2 = p(1,sides(2,:)) ;
  y1 = p(2,sides(1,:)) ;
  y2 = p(2,sides(2,:)) ;

  e  = [];
  for icond = 1:length(sidelist)

    onside  = find( ...
		   (x1<=sidelist(icond,1)) &...
		   (x2<=sidelist(icond,2)) &...
		   (x1>=sidelist(icond,3)) &...
		   (x2>=sidelist(icond,4)) &...
		   (y1<=sidelist(icond,5)) &...
		   (y2<=sidelist(icond,6)) &...
		   (y1>=sidelist(icond,7)) &...
		   (y2>=sidelist(icond,8)) );
    eonside      = unique(sides([1,2],onside)','rows')';
    eonside(5,:) = icond;

    e            = [e,eonside];

  endfor

  ## Set left and right subdomain
  for ie = 1:size(e,2)
    for it = 1:size(t,2)    
      if(((e(1,ie)==t(1,it))&(e(2,ie)==t(2,it)))|...
         ((e(1,ie)==t(2,it))&(e(2,ie)==t(3,it)))|...
         ((e(1,ie)==t(3,it))&(e(2,ie)==t(1,it))))
        e(6,ie)=t(4,it);
      endif
      if(((e(2,ie)==t(1,it))&(e(1,ie)==t(2,it)))|...
         ((e(2,ie)==t(2,it))&(e(1,ie)==t(3,it)))|...
         ((e(2,ie)==t(3,it))&(e(1,ie)==t(1,it))))
        e(7,ie)=t(4,it);
      endif
    endfor
  endfor

endfunction