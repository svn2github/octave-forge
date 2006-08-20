## Copyright (C) 2000  Kai Habel
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
## @deftypefn {Function File} {} voronoi (@var{X},@var{Y})
## @deftypefnx {Function File} {} voronoi (@var{X},@var{Y},"plotstyle")
## @deftypefnx {Function File} {} voronoi (@var{X},@var{Y},"plotstyle",@var{OPTIONS})
## @deftypefnx {Function File} {[@var{vx}, @var{vy}] =} voronoi (@var{X},@var{Y})
## plots voronoi diagram of points @var{X},@var{Y}.
## The voronoi facets with points at infinity are not drawn.
## [@var{vx}, @var{vy}] = voronoi(...) returns the vertices instead plotting the
## diagram. plot (@var{vx}, @var{vy}) shows the voronoi diagram.
##
## A fourth optional argument, which must be a string, contains extra options
## passed to the underlying qhull command.  See the documentation for the
## Qhull library for details.
##
## @example
##   x = rand(10,1); y = rand(size(x));
##   h = convhull(x,y);
##   [vx,vy] = voronoi(x,y);
##   plot(vx,vy,"-b;;",x,y,"o;points;",x(h),y(h),"-g;hull;")
## @end example
##
## @end deftypefn
## @seealso{voronoin, delaunay, convhull}

## Author: Kai Habel <kai.habel@gmx.de>
## First Release: 20/08/2000

## 2002-01-04 Paul Kienzle <pkienzle@users.sf.net>
## * limit the default graph to the input points rather than the whole diagram
## * provide example
## * use unique(x,"rows") rather than __unique_rows__

## 2003-12-14 Rafael Laboissiere <rafael@laboissiere.net>
## Added optional fourth argument to pass options to the underlying
## qhull command

function [varargout] = voronoi (x, y, plt, opt)

	if (nargin < 2 || nargin > 4)
		usage ("voronoi (x, y[, plt[, opt]])")
	endif

	if (nargin < 3)
		plt = "b;;";
		## if not specified plot blue solid lines
	endif

        if (nargin == 4)
		if (! ischar (opt))
			error ("fourth argument must be a string");
		endif
	else
		opt = "";
	endif

	lx = length (x);
	ly = length (y);

	if (lx != ly)
		error ("voronoi: arguments must be vectors of same length");
	endif

	[p, lst, infi] = __voronoi__ ([x(:),y(:)], opt);

	idx = find (!infi);
	ll = length (idx);
	k = 0;r = 1;

	for i = 1:ll
		k += length (nth (lst, idx(i)));
	endfor

	vx = zeros (2,k);
	vy = zeros (2,k);

	for i=1:ll
		fac = nth (lst, idx(i));
		lf = length(fac);
		fac = [fac, fac(1)];
		fst = fac(1:length(fac)-1);
		sec = fac(2:length(fac));
		vx(:,r:r+lf-1) = [p(fst,1),p(sec,1)]';
		vy(:,r:r+lf-1) = [p(fst,2),p(sec,2)]';
		r += lf;
	endfor

	[vx,idx] = unique(vx,"rows");
	vy = vy(idx,:);

	if (nargout == 0)
		lim = [min(x(:)), max(x(:)), min(y(:)), max(y(:))];
	        axis(lim+0.01*[[-1,1]*(lim(2)-lim(1)),[-1,1]*(lim(4)-lim(3))]);
		plot (vx, vy, plt, x, y, 'o;;');
	elseif (nargout == 2)
		vr_val_cnt = 1; varargout{vr_val_cnt++} = vx;
		varargout{vr_val_cnt++} = vy;
	else
		error ("only two or zero output arguments supported")
	endif

endfunction
