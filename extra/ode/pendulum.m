% Copyright (C) 2000 Marc Compere
% This file is intended for use with Octave.
% pendulum.m is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
%
% pendulum.m is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details at www.gnu.org/copyleft/gpl.html.
%
% --------------------------------------------------------------------
%
% This integrates a set of ordinary differential equations (ODE) using 6 different
% ODE solvers.  The equations represent the dynamics of a simple pendulum.
%
% The integrators ode78.m, ode45.m, ode23.m, rk8fixed.m, rk4fixed.m, and rk2fixed.m
% all produce column vector output similar to Matlab.
%
% All integrators work in octave 2.1.24 and Matlab 5.3 with no modification.
%
% Marc Compere
% compere@mail.utexas.edu
% created : 06 October 1999
% modified: 15 May 2000

clear

% allow global access to the parameters m, g, l, & b:
global m g l b rhs_counter

m=1;    % (kg)
g=9.81; % (m/s^2)
l=1.;   % (m)
b=2.;   % ((N-s)/m))

% integrator setup:
trace = 0;   % this is a (1/0) flag that puts output to the screen or not
count = 1;   % this is a (1/0) flag that causes rk4fixed to increment 'rhs_counter' or not
rhs_counter = 0; % 'rhs_counter' is the number of right-hand-side function evaluations, z_dot=f(z)
ode_fcn_format = 0; % 0 chooses Matlab-format right-hand-side function definitions
                    % xdot=f(t,x), or Octave's lsode format, xdot=f(x,t)
t0=0;
tfinal = 5; % (seconds)
tspan = [t0,tfinal];
% Initial Conditions: theta(t=0)=30(deg) & initially at rest
IC = [ 30*pi/180 0]'; % (rad), (rad/s)
sps = 100;            % sps -> step per second
Nsteps=(tfinal-t0)*sps;    % this creates sps number of integration steps per second
tolerance = 1e-3;

% Solve the ODE specified in penddot.m using each of the 6 m-file integrators.

t_begin_calcs=cputime;

   disp('Integrating using rk2fixed...')
   [t1,zrk2fixed] = rk2fixed('penddot',tspan,IC,Nsteps,ode_fcn_format,trace,count);     % fixed step integration
   rk2_counter = rhs_counter
   rhs_counter=0;

t(1)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using rk4fixed...')
   [t2,zrk4fixed] = rk4fixed('penddot',tspan,IC,Nsteps,ode_fcn_format,trace,count);     % fixed step integration
   rk4_counter = rhs_counter
   rhs_counter=0;

t(2)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using rk8fixed...')
   [t3,zrk8fixed] = rk8fixed('penddot',tspan,IC,Nsteps,ode_fcn_format,trace,count);     % fixed step integration
   rk8_counter = rhs_counter
   rhs_counter=0;

t(3)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using ode23...')
   [t4,zode23] = ode23('penddot',tspan,IC,ode_fcn_format,tolerance,trace,count); % rk45 variable step integration
   ode23_counter = rhs_counter
   rhs_counter=0;

t(4)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using ode45...')
   [t5,zode45] = ode45('penddot',tspan,IC,ode_fcn_format,tolerance,trace,count); % rk45 variable step integration
   ode45_counter = rhs_counter
   rhs_counter=0;

t(5)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using ode78...')
   [t6,zode78] = ode78('penddot',tspan,IC,ode_fcn_format,tolerance,trace,count); % rk78 variable step integration
   ode78_counter = rhs_counter
   rhs_counter=0;

t(6)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   %disp('Integrating using sdirk4...')
   % Note: If you want to use sdirk4 you have to compile sdirk4.oct, then change the function definition in
   %       penddot.m to zdot=penddot(z,t) 
   %       Then if you want the other integrators to still work, set ode_fcn_format=1 above.
   %skip_step=10;
   %h_initial = 1e-3;
   %[t7,zsdirk4] = sdirk4('penddot',IC,tspan,tolerance,0.1*tolerance,h_initial,trace,skip_step); % 4th order stiff integration
   %sdirk4_counter = rhs_counter
   %rhs_counter=0;

t(7)=cputime-t_begin_calcs;



disp('Elapsed times for each solver to integrate a pendulum:')
t



% plot that baby
figure(1)
clg
if ishold~=1, hold, end
title('Pendulum Position & Velocity')
ylabel('Theta & Theta_dot (rad) & (rad/s)')
xlabel('Time (s)')
plot(t1,zrk2fixed)
plot(t2,zrk4fixed)
plot(t3,zrk8fixed)
plot(t4,zode23)
plot(t5,zode45)
plot(t6,zode78)
%plot(t7,zsdirk4)
if ishold==1, hold, end


% These plots show the angular position and velocity
% trajectories created by each different integrator.
% Position is the trace that reaches steady state at -pi/2.
% Velocity reaches a steady state of zero.

