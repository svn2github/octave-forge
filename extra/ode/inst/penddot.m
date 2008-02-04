% Copyright (C) 2001, 2000 Marc Compere
%
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details at www.gnu.org/copyleft/gpl.html.
%
% This file is intended for use with this software.
% --------------------------------------------------------------------

% This is an example derivative function file that works
% with Octave or Matlab.
% The equations represent motion of a simple pendulum with damping.
%
% The plots created by pendulum.m show the angular position and velocity
% trajectories created by each different integrator.
% Position is the trace that reaches steady state at 0(rad)
% because of the gravity term, -m*g*l/2*sin(x(1)).
% Velocity reaches a steady state of zero because of the
% damping term, -b*x(2).
%
% Use ode45 to integrate these ODE's
% like this:
%    [t,x] = ode45('penddot',tspan,IC);
%
% x is the state column vector and meant to be used only within this m-file
% This function is meant to return the derivatives of the state variable
% given the state vector and time.
%
% Structure:	xdot = [ x1dot, x2dot, ..., xNdot ]'
%
% eg.  ml^2*thetadd + b*thetad + m*g*l*sin(theta) = 0
%
%	x(1) = theta
%	x(2) = thetad 	( = x(1)dot )
%
% Convention: the lowest order states are first columnwise
%
% Marc Compere
% compere@mail.utexas.edu
% created : 06 October 1999
% modified: 23 October 2001

function xdot=penddot(t,x)

global m g l b counter index

xdot=[ x(2) , 1/(1/3*m*l^2)*(-b*x(2)-m*g*l/2*sin(x(1)))]';

% remember to return a column vector

end
