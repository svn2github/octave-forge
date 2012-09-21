%% Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    (at your option) any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% Example of a free rigid body (no torques)

%% Inital orientation
% The princicpal axis of the body in the [1 1 1] diagonal. We assume the body
% has the principal axis in the Y-direction
  ang = acos(1/sqrt(3))*[-1 1 0];
  [R M] = EAmatrix(0,[3 1 3],true);
  q0 = mat2quat(R(ang));

%% Inital angular velocities
% Body is rotating around its principal axis
  w0 = [0 4*2*pi 0];

  x0 = [w0 q0];

%% Set the system
% Circular cylinder with revolution axis in Y-direction
  opt.Mass = 1;
  r = 1;
  h = 2;
  opt.CoM = (3/4)*[0 h 0];
  opt.InertiaMoment = opt.Mass*[(3/5)*h^2 + (3/20)*r^2 (3/10)*r^2 (3/5)*h^2 + (3/20)*r^2];
  opt.Gravity = [0 0 -1];
  sys = @(t_,x_)RBequations_rot(t_,x_,opt);

%% Set integration
tspan = [0 6];
odeopt = odeset('RelTol',1e-3,'AbsTol',1e-3,...
             'InitialStep',1e-3,'MaxStep',1/10);

%% Euler equations + Quaternions
tic
[t y] = ode45 (sys, tspan, x0, odeopt);
nT = length(t);
toc

% Vector from vertex to end
r0 = [0 1 0];

%% quaternions
r = quatvrot (repmat(r0,nT,1), y(:,4:7) );

figure(1)
cla
drawAxis3D([0 0 0], eye(3), eye(3));
line([0 r(1,1)],[0 r(1,2)],[0 r(1,3)],'color','k','linewidth',2);
hold on
plot3(r(:,1),r(:,2),r(:,3),'.k');
hold off
axis tight;
axis equal;
axis square;
view(150,30)
