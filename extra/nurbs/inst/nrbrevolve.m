function surf = nrbrevolve(curve,pnt,vec,theta)

% 
% NRBREVOLVE: Construct a NURBS surface by revolving a NURBS curve.
% 
% Calling Sequence:
% 
%   srf = nrbrevolve(crv,pnt,vec[,ang])
% 
% INPUT:
% 
%   crv		: NURBS curve to revolve, see nrbmak.
% 
%   pnt		: Coordinate of the point used to define the axis
%               of rotation.
% 
%   vec		: Vector defining the direction of the rotation axis.
% 
%   ang		: Angle to revolve the curve, default 2*pi
%
% OUTPUT:
%
%   srf		: constructed surface
% 
% Description:
% 
%   Construct a NURBS surface by revolving the profile NURBS curve around
%   an axis defined by a point and vector.
% 
% Examples:
% 
%   Construct a sphere by rotating a semicircle around a x-axis.
%
%   crv = nrbcirc(1.0,[0 0 0],0,pi);
%   srf = nrbrevolve(crv,[0 0 0],[1 0 0]);
%   nrbplot(srf,[20 20]);
%
% NOTE:
%
%   The algorithm:
%
%     1) vectrans the point to the origin (0,0,0)
%     2) rotate the vector into alignment with the z-axis
%
%     for each control point along the curve
%
%     3) determine the radius and angle of control
%        point to the z-axis
%     4) construct a circular arc in the x-y plane with 
%        this radius and start angle and sweep angle theta 
%     5) combine the arc and profile, coefs and weights.
%  
%     next control point
%
%     6) rotate and vectrans the surface back into position
%        by reversing 1 and 2.
%
%
%    Copyright (C) 2000 Mark Spink
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 2 of the License, or
%    (at your option) any later version.

%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.

if nargin < 3
  error('Not enough arguments to construct revolved surface');
end

if size(curve.knots,2) == 3
   error('The function nrbrevolve is not yet ready for volumes') 
end

if nargin < 4
  theta = 2.0*pi;
end

% Translate curve the center point to the origin
if isempty(pnt)
  pnt = zeros(3,1);
end

if length(pnt) ~= 3
  error('All point and vector coordinates must be 3D');
end

% Translate and rotate the curve into alignment with the z-axis
T  = vectrans(-pnt);
angx = vecangle(vec(1),vec(3));
RY = vecroty(-angx);
vectmp = RY*[vecnorm(vec(:));1.0];
angy = vecangle(vectmp(2),vectmp(3));
RX = vecrotx(angy);
curve = nrbtform(curve,RX*RY*T);

% Construct an arc 
arc = nrbcirc(1.0,[],0.0,theta);

% Construct the surface
coefs = zeros(4,arc.number,curve.number);
angle = vecangle(curve.coefs(2,:),curve.coefs(1,:));
radius = vecmag(curve.coefs(1:2,:));
for i = 1:curve.number  
  coefs(:,:,i) = vecrotz(angle(i))*vectrans([0.0 0.0 curve.coefs(3,i)])*...
          vecscale([radius(i) radius(i)])*arc.coefs;
  coefs(4,:,i) = coefs(4,:,i)*curve.coefs(4,i);
end
surf = nrbmak(coefs,{arc.knots, curve.knots});

% Rotate and vectrans the surface back into position
T = vectrans(pnt);
RX = vecrotx(-angy);
RY = vecroty(angx);
surf = nrbtform(surf,T*RY*RX);  

end

%!demo
%! sphere = nrbrevolve(nrbcirc(1,[],0.0,pi),[0.0 0.0 0.0],[1.0 0.0 0.0]);
%! nrbplot(sphere,[40 40],'light','on');
%! title('Ball and tori - surface construction by revolution');
%! hold on;
%! torus = nrbrevolve(nrbcirc(0.2,[0.9 1.0]),[0.0 0.0 0.0],[1.0 0.0 0.0]);
%! nrbplot(torus,[40 40],'light','on');
%! nrbplot(nrbtform(torus,vectrans([-1.8])),[20 10],'light','on');
%! hold off;

%!demo
%! pnts = [3.0 5.5 5.5 1.5 1.5 4.0 4.5;
%!         0.0 0.0 0.0 0.0 0.0 0.0 0.0;
%!         0.5 1.5 4.5 3.0 7.5 6.0 8.5];
%! crv = nrbmak(pnts,[0 0 0 1/4 1/2 3/4 3/4 1 1 1]);
%! 
%! xx = vecrotz(deg2rad(25))*vecroty(deg2rad(15))*vecrotx(deg2rad(20));
%! nrb = nrbtform(crv,vectrans([5 5])*xx);
%!
%! pnt = [5 5 0]';
%! vec = xx*[0 0 1 1]';
%! srf = nrbrevolve(nrb,pnt,vec(1:3));
%!
%! p = nrbeval(srf,{linspace(0.0,1.0,100) linspace(0.0,1.0,100)});
%! surfl(squeeze(p(1,:,:)),squeeze(p(2,:,:)),squeeze(p(3,:,:)));
%! title('Construct of a 3D surface by revolution of a curve.');
%! shading interp;
%! colormap(copper);
%! axis equal;
%! hold off

