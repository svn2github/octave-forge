function [tout, xout] = ode45(F,tspan,x0,ode_fcn_format,tol,trace,count)

% Copyright (C) 2000 Marc Compere
% This file is intended for use with Octave.
% ode45.m is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
%
% ode45.m is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details at www.gnu.org/copyleft/gpl.html.
%
% --------------------------------------------------------------------
%
% ode45 (v1.07) integrates a system of ordinary differential equations using
% 4th & 5th order embedded Runge-Kutta-Fehlberg formulas.
% This requires 6 function evaluations per integration step.
% This particular implementation uses the 5th order estimate for xout, although
% the truncation error is of order(h^4), therefore this method, overall is
% a 4th-order method.
%
% The Fehlberg 4(5) coefficients are from a tableu in
% U.M. Ascher, L.R. Petzold, Computer Methods for  Ordinary Differential Equations
% and Differential-Agebraic Equations, Society for Industrial and Applied Mathematics
% (SIAM), Philadelphia, 1998
%
% The error estimate formula and slopes are from
% Numerical Methods for Engineers, 2nd Ed., Chappra & Cannle, McGraw-Hill, 1985
%
% Usage:
%         [tout, xout] = ode45(F, tspan, x0, ode_fcn_format, tol, trace, count)
%
% INPUT:
% F     - String containing name of user-supplied problem description.
%         Call: xprime = fun(t,x) where F = 'fun'.
%         t      - Time (scalar).
%         x      - Solution column-vector.
%         xprime - Returned derivative COLUMN-vector; xprime(i) = dx(i)/dt.
% tspan - [ tstart, tfinal ]
% x0    - Initial value COLUMN-vector.
% ode_fcn_format - this specifies if the user-defined ode function is in
%         the form:     xprime = fun(t,x)   (ode_fcn_format=0, default)
%         or:           xprime = fun(x,t)   (ode_fcn_format=1)
%         Matlab's solvers comply with ode_fcn_format=0 while
%         Octave's lsode() and sdirk4() solvers comply with ode_fcn_format=1.
% tol   - The desired accuracy. (optional, default: tol = 1.e-6).
% trace - If nonzero, each step is printed. (optional, default: trace = 0).
% count - if nonzero, variable 'rhs_counter' is initalized, made global
%         and counts the number of state-dot function evaluations
%         'rhs_counter' is incremented in here, not in the state-dot file
%         simply make 'rhs_counter' global in the file that calls ode45
%
% OUTPUT:
% tout  - Returned integration time points (column-vector).
% xout  - Returned solution, one solution column-vector per tout-value.
%
% The result can be displayed by: plot(tout, xout).
%
% Marc Compere
% compere@mail.utexas.edu
% created : 06 October 1999
% modified: 15 May 2000

if nargin < 7, count = 0; end
if nargin < 6, trace = 0; end
if nargin < 5, tol = 1.e-6; end
if nargin < 4, ode_fcn_format = 0; end

pow = 1/8;

% The Fehlberg 4(5) coefficients:
 a_(1,1)=0;
 a_(2,1)=1/4;
 a_(3,1)=3/32; a_(3,2)=9/32;
 a_(4,1)=1932/2197; a_(4,2)=-7200/2197; a_(4,3)=7296/2197;
 a_(5,1)=439/216; a_(5,2)=-8; a_(5,3)=3680/513; a_(5,4)=-845/4104; 
 a_(6,1)=-8/27; a_(6,2)=2; a_(6,3)=-3544/2565; a_(6,4)=1859/4104; a_(6,5)=-11/40; 
 % 4th order b-coefficients
 b4_(1)=25/216; b4_(2)=0; b4_(3)=1408/2565; b4_(4)=2197/4104; b4_(5)=-1/5;
 % 5th order b-coefficients
 b5_(1)=16/135; b5_(2)=0; b5_(3)=6656/12825; b5_(4)=28561/56430; b5_(5)=-9/50; b5_(6)=2/55;
 for i=1:6
  c_(i)=sum(a_(i,:));
 end

% Initialization
t0 = tspan(1);
tfinal = tspan(2);
t = t0;
hmax = (tfinal - t)/2.5;
hmin = (tfinal - t)/1e9;
h = (tfinal - t)/100; % initial guess at a step size
x = x0(:);            % this always creates a column vector, x
tout = t;             % first output time
xout = x.';           % first output solution

if count==1,
 global rhs_counter
 if ~exist('rhs_counter'),rhs_counter=0; end
end % if count

if trace
 clc, t, h, x
end

% The main loop
   while (t < tfinal) & (h >= hmin)
      if t + h > tfinal, h = tfinal - t; end

      % compute the slopes
      if (ode_fcn_format==0),
       k_(:,1)=feval(F,t,x);
       k_(:,2)=feval(F,t+c_(2)*h,x+h*(a_(2,1)*k_(:,1)));
       k_(:,3)=feval(F,t+c_(3)*h,x+h*(a_(3,1)*k_(:,1)+a_(3,2)*k_(:,2)));
       k_(:,4)=feval(F,t+c_(4)*h,x+h*(a_(4,1)*k_(:,1)+a_(4,2)*k_(:,2)+a_(4,3)*k_(:,3)));
       k_(:,5)=feval(F,t+c_(5)*h,x+h*(a_(5,1)*k_(:,1)+a_(5,2)*k_(:,2)+a_(5,3)*k_(:,3)+a_(5,4)*k_(:,4)));
       k_(:,6)=feval(F,t+c_(6)*h,x+h*(a_(6,1)*k_(:,1)+a_(6,2)*k_(:,2)+a_(6,3)*k_(:,3)+a_(6,4)*k_(:,4)+a_(6,5)*k_(:,5)));
      else,
       k_(:,1)=feval(F,x,t);
       k_(:,2)=feval(F,x+h*(a_(2,1)*k_(:,1)),t+c_(2)*h);
       k_(:,3)=feval(F,x+h*(a_(3,1)*k_(:,1)+a_(3,2)*k_(:,2)),t+c_(3)*h);
       k_(:,4)=feval(F,x+h*(a_(4,1)*k_(:,1)+a_(4,2)*k_(:,2)+a_(4,3)*k_(:,3)),t+c_(4)*h);
       k_(:,5)=feval(F,x+h*(a_(5,1)*k_(:,1)+a_(5,2)*k_(:,2)+a_(5,3)*k_(:,3)+a_(5,4)*k_(:,4)),t+c_(5)*h);
       k_(:,6)=feval(F,x+h*(a_(6,1)*k_(:,1)+a_(6,2)*k_(:,2)+a_(6,3)*k_(:,3)+a_(6,4)*k_(:,4)+a_(6,5)*k_(:,5)),t+c_(6)*h);
      end % if (ode_fcn_format==0)

      % increment rhs_counter
      if count==1,
       rhs_counter = rhs_counter + 6;
      end % if

      % compute the 4th order estimate
      x4=x + h*(b4_(1)*k_(:,1) + b4_(3)*k_(:,3) + b4_(4)*k_(:,4) + b4_(5)*k_(:,5));
      % compute the 5th order estimate
      x5=x + h*(b5_(1)*k_(:,1) + b5_(3)*k_(:,3) + b5_(4)*k_(:,4) + b5_(5)*k_(:,5) + b5_(6)*k_(:,6));

      % estimate the local truncation error
      gamma1 = x5 - x4;

      % Estimate the error and the acceptable error
      delta = norm(gamma1,'inf');       % actual error
      tau = tol*max(norm(x,'inf'),1.0); % allowable error

      % Update the solution only if the error is acceptable
      if delta <= tau
         t = t + h;
         x = x5;    % <-- using the higher order estimate is called 'local extrapolation'
         tout = [tout; t];
         xout = [xout; x.'];
      end
      if trace
         home, t, h, x
      end

      % Update the step size
      if delta == 0.0
       delta = 1e-16;
      end
      h = min(hmax, 0.8*h*(tau/delta)^pow);

   end;

   if (t < tfinal)
      disp('Step size grew too small.')
      t, h, x
   end
