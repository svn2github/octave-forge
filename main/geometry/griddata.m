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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{ZI} =} griddata (@var{x},@var{y},@var{z},@var{xi},@var{yi},method)
## @deftypefnx {Function File} {[@var{XI},@var{YI},@var{ZI}] =}
## griddata (@var{x},@var{y},@var{z},@var{xi},@var{yi},method)
## 
## 
## If method is omitted it defaults to 'linear'
## @seealso{delaunay}
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>

function [varargout] = griddata (x,y,z,xi,yi)
	
	if nargin==5
		method='linear';
	endif
	if (nargin <5|nargin>7 )
		usage('griddata(x,y,z,xi,yi)');
	endif
	if isstr(method), method=tolower(method); endif
	if !( (size(x)==size(y))&(size(x)==size(z)) )
		error('x,y,z must be vectors of same length');
	endif
	if (size(xi)!=size(yi))
		error('xi and yi must be vectors or matrices of same size');
	endif
	if (is_vector(xi))
		#xi and yi are vectors
		[xi,yi]=meshgrid(xi,yi);
		vr_val_cnt = 1; varargout{vr_val_cnt++} = xi;
		varargout{vr_val_cnt++} = yi;
	endif
	[nr,nc]=size(xi);

	# triangulate data
	tri=delaunay(x,y);

	# 
	xi=reshape(xi,nr*nc,1);
	yi=reshape(yi,nr*nc,1);
	zi=zeros(size(xi));

	if strcmp(method,'cubic')
		error('griddata(...,\'cubic\') cubic interpolation not yet implemented\n')
	elseif strcmp(method,'nearest')
		error('griddata(...,\'nearest\') nearest neighbor interpolation not yet implemented\n')

		#search index of nearest point
		#dsearch not yet implemented
		idx=dsearch(x,y,tri,xi,yi);
		zi=z(idx);
	elseif strcmp(method,'linear')
		#search for every point the enclosing triangle
		tri_list=tsearch(x,y,tri,xi,yi);

		#keep non zero values before overwriting zeros with 1
		t_nzero=tri_list>0;
		tri_list=tri_list+(tri_list==0);
		nr_t=rows(tri_list);

		N=zeros(nr_t,4);
		#assign x,y,z for each point of triangle
		x1=x(tri([tri_list],1));y1=y(tri([tri_list],1));z1=z(tri([tri_list],1));
		x2=x(tri([tri_list],2));y2=y(tri([tri_list],2));z2=z(tri([tri_list],2));
		x3=x(tri([tri_list],3));y3=y(tri([tri_list],3));z3=z(tri([tri_list],3));

		#calculate norm vector
		N(:,1:3)=cross([x2-x1, y2-y1, z2-z1],[x3-x1, y3-y1, z3-z1]);
		N_norm=sqrt(N(:,1).^2+N(:,2).^2+N(:,3).^2);
		N(:,1:3)=N(:,1:3)./kron(N_norm,[1 1 1]);

		#calculate D of plane equation
		#Ax+By+Cz+D=0;
		N(:,4)=-(N(:,1).*x1+N(:,2).*y1+N(:,3).*z1);

		#calculate zi by solving plane equation for xi,yi
		zi=-1./N(:,3).*( N(:,1).*xi+N(:,2).*yi+N(:,4) );
	
		#reset zi values for points not in convex hull		
		zi=t_nzero.*zi;

		# restore original shape
		zi=reshape(zi,nr,nc);
               varargout{vr_val_cnt++} = zi;
	else
		error('unknown interpolation method');
	endif
endfunction
