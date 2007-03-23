## Copyright (C) 1999,2000  Kai Habel
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{ZI} =} griddata (@var{x},@var{y},@var{z},@var{xi},@var{yi},method)
## @deftypefnx {Function File} {[@var{XI},@var{YI},@var{ZI}] =}
## griddata (@var{x},@var{y},@var{z},@var{xi},@var{yi},method)
## 
## Generate a regular mesh from irregular data using interpolation.
## The function is defined by z=f(x,y).  The interpolation points are
## all (xi,yi).  If xi,yi are vectors then they are made into a 2D mesh.
##
## The interpolation method can be 'nearest', 'cubic' or 'linear'.
## If method is omitted it defaults to 'linear'.
## @seealso{delaunay}
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Adapted-by:  Alexander Barth <barth.alexander@gmail.com>
##              xi and yi are not "meshgridded" if both are vectors 
##              of the same size (for compatibility)

function [rx, ry, rz] = griddata (x,y,z,xi,yi,method)
	
  if nargin==5
    method='linear';
  endif
  if nargin <5 || nargin>7 
    usage('griddata(x,y,z,xi,yi[,method])');
  endif
  if ischar(method), method=tolower(method); endif
  if !all( (size(x)==size(y)) & (size(x)==size(z)) )
    error('x,y,z must be vectors of same length');
  endif
  
  ## meshgrid xi and yi if they are vectors unless they
  ## are vectors of the same length 
  if isvector(xi) && isvector(yi) && numel(xi) ~= numel(yi), 
    [xi,yi]=meshgrid(xi,yi);     
  endif
    
    
  if any(size(xi)!=size(yi))
    error('xi and yi must be vectors or matrices of same size');
  endif
  [nr,nc]=size(xi);
  
  ## triangulate data
  tri=delaunay(x,y);
  zi=zeros(size(xi));
  
  if strcmp(method,'cubic')
    error("griddata(...,'cubic') cubic interpolation not yet implemented\n")

  elseif strcmp(method,'nearest')
    ## search index of nearest point
    idx=dsearch(x,y,tri,xi,yi);
    valid = !isnan(idx);
    zi(valid)=z(idx(valid));

  elseif strcmp(method,'linear')
    ## search for every point the enclosing triangle
    tri_list=tsearch(x,y,tri,xi(:),yi(:));

    ## only keep the points within triangles.
    valid=!isnan(reshape(tri_list,size(xi)));
    tri_list = tri_list(!isnan(tri_list));
    nr_t=rows(tri_list);

    ## assign x,y,z for each point of triangle
    x1=x(tri(tri_list,1));y1=y(tri(tri_list,1));z1=z(tri(tri_list,1));
    x2=x(tri(tri_list,2));y2=y(tri(tri_list,2));z2=z(tri(tri_list,2));
    x3=x(tri(tri_list,3));y3=y(tri(tri_list,3));z3=z(tri(tri_list,3));

    ## calculate norm vector
    N=cross([x2-x1, y2-y1, z2-z1],[x3-x1, y3-y1, z3-z1]);
    N_norm=sqrt(sumsq(N,2));
    N=N./N_norm(:,[1,1,1]);
    
    ## calculate D of plane equation
    ## Ax+By+Cz+D=0;
    D=-(N(:,1).*x1+N(:,2).*y1+N(:,3).*z1);
    
    ## calculate zi by solving plane equation for xi,yi
    zi(valid) = -( N(:,1).*xi(valid) + N(:,2).*yi(valid) + D ) ./ N(:,3);
    
  else
    error('unknown interpolation method');
  endif

  if nargout == 3
    rx = xi;
    ry = yi;
    rz = zi;
  elseif nargout == 1
    rx = zi;
  elseif nargout == 0
    mesh(xi,yi,zi);
%    hold on
%    plot3(x,y,z,'bo'); 
%    hold off
  endif
endfunction

%!demo
%! x=2*rand(100,1)-1;
%! y=2*rand(size(x))-1;
%! z=sin(2*(x.^2+y.^2));
%! [xx,yy]=meshgrid(linspace(-1,1,32));
%! title('nonuniform grid sampled at 100 points');
%! griddata(x,y,z,xx,yy);

%!demo
%! x=2*rand(1000,1)-1;
%! y=2*rand(size(x))-1;
%! z=sin(2*(x.^2+y.^2));
%! [xx,yy]=meshgrid(linspace(-1,1,32));
%! title('nonuniform grid sampled at 1000 points');
%! griddata(x,y,z,xx,yy);
