function [tout, xout] = ode78(F,tspan,x0,ode_fcn_format,tol,trace,count)

% Copyright (C) 2000 Marc Compere
% This file is intended for use with Octave.
% ode78.m is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2, or (at your option)
% any later version.
%
% ode78.m is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details at www.gnu.org/copyleft/gpl.html.
%
% --------------------------------------------------------------------
%
% ode78 (v1.07) Integrates a system of ordinary differential equations using
% 7th order formulas.
% This particular implementation uses the 8th order estimate for xout, which
% is called 'local extrapolation'.  The truncation error, gamma1, is of order(h^8).
% Therefore this method, overall is a 7th-order method.
% This requires 13 function evaluations per integration step.
%
% More may be found in the original author's text containing numerous
% applications on ordinary and partial differential equations using Matlab:
%
%     Howard Wilson and Louis Turcotte, 'Advanced Mathematics and 
%     Mechanics Applications Using MATLAB', 2nd Ed, CRC Press, 1997
%
%
% [tout, xout] = ode78(F, tspan, x0, ode_fcn_format, tol, trace, count)
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
%         simply make 'rhs_counter' global in the file that calls ode78
%
% OUTPUT:
% tout  - Returned integration time points (row-vector).
% xout  - Returned solution, one solution column-vector per tout-value.
%
% The result can be displayed by: plot(tout, xout).

%   Daljeet Singh & Howard Wilson
%   Dept. Of Electrical Engg., The University of Alabama.
%   11-24-1988.
%
% modified by:
% Marc Compere
% compere@mail.utexas.edu
% created : 06 October 1999
% modified: 15 May 2000


% The Fehlberg coefficients:
alpha_ = [ 2./27. 1/9 1/6 5/12 .5 5/6 1/6 2/3 1/3 1 0 1 ]';
beta_ = [ [  2/27  0  0   0   0  0  0  0  0  0  0   0  0  ]
[  1/36 1/12  0  0  0  0  0  0   0  0  0  0  0  ]
[  1/24  0  1/8  0  0  0  0  0  0  0  0  0  0 ]
[  5/12  0  -25/16  25/16  0  0  0  0  0  0   0  0  0  ]
[ .05   0  0  .25  .2  0  0  0  0  0  0  0  0 ]
[ -25/108  0  0  125/108  -65/27  125/54  0  0  0  0  0  0   0  ]
[ 31/300  0  0  0  61/225  -2/9  13/900  0  0  0   0  0  0  ]
[ 2  0  0  -53/6  704/45  -107/9  67/90  3  0  0  0  0  0  ]
[ -91/108  0  0  23/108  -976/135  311/54  -19/60  17/6  -1/12  0  0  0  0 ]
[2383/4100 0 0 -341/164 4496/1025 -301/82 2133/4100 45/82 45/164 18/41 0 0 0]
[ 3/205  0   0  0   0    -6/41  -3/205   -3/41     3/41   6/41   0   0  0 ]
[-1777/4100 0 0 -341/164 4496/1025 -289/82 2193/4100 ...
51/82 33/164 12/41 0 1 0]...
]';
 chi_ = [ 0 0 0 0 0 34/105 9/35 9/35 9/280 9/280 0 41/840 41/840]';
 psi_ = [1  0  0  0  0  0  0  0  0  0  1 -1  -1 ]';
pow = 1/8;

if nargin < 7, count = 0; end
if nargin < 6, trace = 0; end
if nargin < 5, tol = 1.e-6; end
if nargin < 4, ode_fcn_format = 0; end

% Initialization
t0 = tspan(1);
tfinal = tspan(2);
t = t0;
% the following step parameters are used in ODE45
% hmax = (tfinal - t)/5;
% hmin = (tfinal - t)/20000;
% h = (tfinal - t)/100;
% The following parameters were taken because the integrator has
% higher order than ODE45. This choice is somewhat subjective.
hmax = (tfinal - t)/2.5;
%hmin = (tfinal - t)/10000;
hmin = (tfinal - t)/1000000000;
h = (tfinal - t)/50;
x = x0(:);          % the '(:)' ensures x is initialized as a column vector
f = x*zeros(1,13);  % f needs to be an Nx13 matrix where N=number of cols in x
tout = t;
xout = x.';
tau = tol * max(norm(x, 'inf'), 1);

if count==1,
 global rhs_counter
 if ~exist('rhs_counter'),rhs_counter=0;,end
end % if count

if trace
%  clc, t, h, x
   clc, t, x
end
% The main loop
   while (t < tfinal) & (h >= hmin)
      if t + h > tfinal, h = tfinal - t; end

      % Compute the slopes
      if (ode_fcn_format==0),
       f(:,1) = feval(F,t,x);
       for j = 1: 12
          f(:,j+1) = feval(F, t+alpha_(j)*h, x+h*f*beta_(:,j));
       end
      else,
       f(:,1) = feval(F,x,t);
       for j = 1: 12
          f(:,j+1) = feval(F, x+h*f*beta_(:,j), t+alpha_(j)*h);
       end
      end %  if (ode_fcn_format==0)


      % increment rhs_counter
      if count==1,
       rhs_counter = rhs_counter + 13;
      end % if

      % Truncation error term
      gamma1 = h*41/840*f*psi_;

      % Estimate the error and the acceptable error
      delta = norm(gamma1,'inf');
      tau = tol*max(norm(x,'inf'),1.0);

      % Update the solution only if the error is acceptable
      if delta <= tau
         t = t + h;
         x = x + h*f*chi_;  % this integrator uses local extrapolation
         tout = [tout; t];
         xout = [xout; x.'];
      end
      if trace
         home, t, h, x
%        home, t, x
      end

      % Update the step size
      if delta == 0.0
       delta = 1e-16;
      end
      h = min(hmax, 0.8*h*(tau/delta)^pow);

   end;

   if (t < tfinal)
      disp('SINGULARITY LIKELY.')
      t
   end
