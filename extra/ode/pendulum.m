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
% This file is intended for use with Octave.
% --------------------------------------------------------------------

% This integrates a set of ordinary differential equations (ODE) using 6 different
% ODE solvers.  The equations represent the dynamics of a simple pendulum.
%
% The integrators ode78.m, ode45.m, ode23.m, rk8fixed.m, rk4fixed.m, and rk2fixed.m
% all produce column vector output similar to Matlab.
%
% All integrators work in octave 2.1.32 and Matlab 5.3 with no modification.
%
% Marc Compere
% CompereM@asme.org
% created : 06 October 1999
% modified: 23 October 2001

clear

% allow global access to the parameters m, g, l, & b:
global m g l b rhs_counter

m=1;    % (kg)
g=9.81; % (m/s^2)
l=1.;   % (m)
b=0.7;   % ((N-s)/m))

% integrator setup:
trace = 0;   % this is a (1/0) flag that puts output to the screen or not
count = 1;   % this is a (1/0) flag that causes rk4fixed to increment 'rhs_counter' or not
rhs_counter = 0; % 'rhs_counter' is the number of right-hand-side function evaluations, z_dot=f(z)
ode_fcn_format = 0; % 0 chooses Matlab-format right-hand-side function definitions
                    % xdot=f(t,x), or Octave's lsode format, xdot=f(x,t)
t0=0;
tfinal = 5; % (seconds)
tspan = [t0,tfinal];
hmax = 0.1;

% Initial Conditions: theta(t=0)=30(deg) & initially at rest
IC = [ 30*pi/180,0]'; % (rad), (rad/s)
sps = 100;            % sps -> step per second
Nsteps=(tfinal-t0)*sps;    % this creates sps number of integration steps per second
tolerance = 1e-3;

% polite housekeeping
this_user_uses=page_screen_output;
page_screen_output=0;

% for development:
tol=tolerance; pair=0; x0=IC; FUN='penddot';

% Solve the ODE specified in penddot.m using each of the 6 m-file integrators.

t_begin_calcs=cputime;

   disp('Integrating using rk2fixed...')
   [t1,zrk2fixed] = rk2fixed('penddot',tspan,IC,Nsteps,ode_fcn_format,trace,count);     % fixed step integration
   rk2_counter = rhs_counter;
   rhs_counter=0;

t(1)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using rk4fixed...')
   [t2,zrk4fixed] = rk4fixed('penddot',tspan,IC,Nsteps,ode_fcn_format,trace,count);     % fixed step integration
   rk4_counter = rhs_counter;
   rhs_counter=0;

t(2)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using rk8fixed...')
   [t3,zrk8fixed] = rk8fixed('penddot',tspan,IC,Nsteps,ode_fcn_format,trace,count);     % fixed step integration
   rk8_counter = rhs_counter;
   rhs_counter=0;

t(3)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using ode23...')
   [t4,zode23] = ode23('penddot',tspan,IC,ode_fcn_format,tolerance,trace,count,hmax); % rk23 variable step integration
   ode23_counter = rhs_counter;
   rhs_counter=0;

t(4)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using ode45 with the Dormand-Prince 4(5) pair...')
   pair=0;
   [t5,zode45dp,Nsteps_acc_ode45dp,Nsteps_rej_ode45dp] = ode45('penddot',tspan,IC,pair,ode_fcn_format,tolerance,trace,count,hmax); % rk45 variable step integration
   ode45dp_counter = rhs_counter;
   rhs_counter=0;

t(5)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using ode45 with the Fehlberg 4(5) pair...')
   pair=1;
   [t6,zode45rkf,Nsteps_acc_ode45rkf,Nsteps_rej_ode45rkf] = ode45('penddot',tspan,IC,pair,ode_fcn_format,tolerance,trace,count,hmax); % rk45 variable step integration
   ode45rkf_counter = rhs_counter;
   rhs_counter=0;

t(6)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   disp('Integrating using ode78...')
   [t7,zode78] = ode78('penddot',tspan,IC,ode_fcn_format,tolerance,trace,count,hmax); % rk78 variable step integration
   ode78_counter = rhs_counter;
   rhs_counter=0;

t(7)=cputime-t_begin_calcs;
t_begin_calcs=cputime;

   %disp('Integrating using sdirk...')
   % Note: If you want to use sdirk you have to compile sdirk.oct, then change the function definition in
   %       penddot.m to zdot=penddot(z,t) and uncomment the lines below.
   %       Then if you want the other integrators to still work, set ode_fcn_format=1 above.
   %skip_step=10;
   %h_initial = 1e-3;
   %[t8,zsdirk] = sdirk('penddot',IC,tspan,tolerance,0.1*tolerance,h_initial,trace,skip_step); % 4th order stiff integration
   %sdirk_counter = rhs_counter;
   %rhs_counter=0;

t(8)=cputime-t_begin_calcs;

rhs_fcn_evaluation_summary=[
strcat('rk2_counter      = ',num2str(rk2_counter));
strcat('rk4_counter      = ',num2str(rk4_counter));
strcat('rk8_counter      = ',num2str(rk8_counter));
strcat('ode23_counter    = ',num2str(ode23_counter));
strcat('ode45dp_counter  = ',num2str(ode45dp_counter));
strcat('ode45rkf_counter = ',num2str(ode45rkf_counter));
strcat('ode78_counter    = ',num2str(ode78_counter)) ]
%strcat('sdirk_counter    = ',num2str(sdirk_counter)) ]


disp('Elapsed times for each solver to integrate the state equations for a simple pendulum:')
t


% notes: The Dormand-Prince pair in ode45 produces a time output vector
%        of 18x1.  (size(t5)=18x1)
%        The number of function evaluations is 103 which you can compute
%        from (18-1)*6+1=103.  (18-1) because there were really only 17 new
%        steps computed.  The first step is just the initial conditions.
%        Multiply (18-1) by 6 because each step during the normal main loop
%        requires 6 function evaluations to compute.  Add 1 because the very
%        first step requires 1 function evaluation to start the main loop.


% plot those puppies
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
plot(t5,zode45dp)
plot(t6,zode45rkf)
plot(t7,zode78)
%plot(t8,zsdirk)
if ishold==1, hold, end


% These plots show the angular position and velocity
% trajectories created by each different integrator.
% Position is the trace that reaches steady state at -pi/2.
% Velocity reaches a steady state of zero.


% Return setting(s) to what they were before
page_screen_output=this_user_uses;

