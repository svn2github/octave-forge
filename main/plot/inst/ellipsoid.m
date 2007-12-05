## Copyright (C) 2007   Sylvain Pelissier   <sylvain.pelissier@gmail.com>
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
## @deftypefn {Function File} {[@var{x}, @var{y}, @var{z}] =} ellipsoid (@var{xc},@var{yc},@var{zc},@var{xr},@var{yr},@var{zr},@var{n})
## @deftypefnx {Function File} {} ellipsoid (@var{xc},@var{yc},@var{zc},@var{xr},@var{yr},@var{zr},@var{n})
## Generates three matrices in @code{meshgrid} format, of an ellipsoid.
## Called with no return arguments, @code{ellipsoid} call directly 
## @code{surf (@var{x}, @var{y}, @var{z})}.
## @end deftypefn

function [xx, yy, zz] = ellipsoid(varargin)
  
  if (nargin < 1)
    print_usage ();
  elseif (nargin == 6)
    xc = varargin{1};
	yc = varargin{2};
	zc = varargin{3};
	xr = varargin{4};
	yr = varargin{5};
	zr = varargin{6};
    n = 20;
  elseif(nargin == 7)
	xc = varargin{1};
	yc = varargin{2};
	zc = varargin{3};
	xr = varargin{4};
	yr = varargin{5};
	zr = varargin{6};
	n = varargin{7};
  else
	print_usage ();
  endif

  theta = linspace (0, 2*pi, n+1);
  phi = linspace (-pi/2, pi/2, n+1);
  [theta,phi] = meshgrid (theta, phi);

  x = xr.*cos (phi) .* cos (theta)+xc;
  y = yr.*cos (phi) .* sin (theta)+yc;
  z = zr.*sin (phi)+zc;

  if (nargout > 0)
    xx = x;
    yy = y;
    zz = z;
  else
    surf ( x, y, z);
  endif

endfunction
