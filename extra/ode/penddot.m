function zdot=penddot(t,z)

% Copyright (C) 2000 Marc Compere
% This file is intended for use with Octave.
% penddot.m is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
%
% penddot.m is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details at www.gnu.org/copyleft/gpl.html.
%
% --------------------------------------------------------------------
%
% This is an example derivative function file that works
% with Octave or Matlab.
% The equations represent motion of a simple pendulum with damping.
%
% The plots created by pendulum.m show the angular position and velocity
% trajectories created by each different integrator.
% Position is the trace that reaches steady state at -pi/2
% because of the gravity term, -m*g*l/2*cos(z(1)).
% Velocity reaches a steady state of zero because of the
% damping term, -b*z(2).
%
% Use ode45 to integrate these ODE's
% like this:
%    [t,z] = ode45('penddot',tspan,IC);
%
% z is the state column vector and meant to be used only within this m-file
% This function is meant to return the derivatives of the state variable
% given the state vector and time.
%
% Structure:	zdot = [ z1dot, z2dot, ... zNdot ]'
%
% eg.  ml^2*thetadd + b*thetad + m*g*l*sin(theta) = 0
%
%	z(1) = theta
%	z(2) = thetad 	( = z(1)dot )
%
% Convention: the lowest order states are first columnwise
%
% Marc Compere
% compere@mail.utexas.edu
% created : 06 October 1999
% modified: 15 May 2000

global m g l b counter index

zdot=[ z(2) , 1/(1/3*m*l^2)*(-b*z(2)-m*g*l/2*cos(z(1)))]';

% remember to return a column vector

end
