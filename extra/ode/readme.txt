This is the readme.txt file for Octave m-file ordinary differential
equation (ODE) solvers, version 1.07.  They also work in Matlab.

This directory contains 8 files that provide an Octave user with
several options for numerically integrating ode.
There are 3 fixed-step Runge-Kutta algorithms and
3 variable step Runge-Kutta-Fehlberg algorithms.
All are explicit RK formulas that work well with nonstiff problems.

----------------------------------------------------------------------
The archive octave_ode_solvers_v1.07.tar.gz contains 6 single-step
Runge-Kutta ODE solvers along with 2 files demonstrating example
uses of each solver:

   - ode23.m    : variable step, 2nd-3rd order
   - ode45.m    : variable step, 4th-5th order
   - ode78.m    : variable step, 7th-8th order

   - rk2fixed.m : fixed step, 2nd order
   - rk4fixed.m : fixed step, 4th order
   - rk8fixed.m : fixed step, 8th order

   - pendulum.m : a sample m-file script that runs all solvers
   - penddot.m  : derivative function file, returning dy/dt for a simple pendulum
   - readme.txt : this file

----------------------------------------------------------------------
Steps for testing these ode solvers in Octave (version 2.0.14 or better),
from a unix shell:

(1) unzip and untar the archive:
	gunzip ode_v1.07.tar.gz
	tar xvf ode_v1.07.tar
(2) change directories into the newly created directory and execute Octave:
	cd ode_v1.07
	octave
(3) run the sample pemdulum script from within Octave.  This will sequentially
    execute all 6 m-file integrators:
	pendulum

----------------------------------------------------------------------
I've made an effort to make these portable to most Octave installations
as well as for use in most Matlab versions.  These work with no modification
in Matlab v5.2 & v5.3.  If you want to use these in Matlab, however,
you'll do yourself a favor by renaming ode45.m and ode23.m to something else,
like ode45_octave.m and ode23_octave.m.  This is because Matlab already has
two integrators named ode45 and ode23.
Don't forget to change the function names at the top of ode45_octave.m and
ode23_octave.m as well.

Some effort has been made to create ode45 and ode23 with similar
argument structures to their Matlab counterparts.  Only the most basic function
calls to ode45 and ode23 match up in both Matlab's integrators and these.
Feel free to change them as you see fit.  You are welcome to mail me for useful
change suggestions.

----------------------------------------------------------------------
Basic differences between the integrators:

In general, the higher the integration order, the smaller the local truncation
error is at each time step.  Small local truncation errors result in larger
integration steps.  This is demonstrated by ode78 generating far fewer
steps than ode23 for solving the same problem over the same time interval with
the same error criterion.
The cost of the higher order integrators is the number of function evaluations
required at each step.  This results in longer execution times for each integration
step.
The tradeoff between solving a problem with an integrator that takes fewer steps
versus using one that takes more time for each step will vary with each problem.
Factors such as the degree of numerical stiffness or the number of discontinuities
will somteimes cause ode23 to be more effective than ode78, & vice-versa.

Integrator costs in right-hand-side (RHS) evaluations:
   - ode23.m    : requires 3 RHS function evaluations per step
   - ode45.m    : requires 6 RHS function evaluations per step
   - ode78.m    : requires 13 RHS function evaluations per step

   - rk2fixed.m : requires 2 RHS function evaluations per step
   - rk4fixed.m : requires 4 RHS function evaluations per step
   - rk8fixed.m : requires 13 RHS function evaluations per step

If you are interested in experimenting with pendulum.m, try turning on
the 'trace' variable for screen output.  This increases execution speed
but provides a way to monitor the problem during the integration.

----------------------------------------------------------------------
Two of the original files rk4fixed.m and ode78.m came from other
people.

rk4fixed.m was written by:
     Dr. Raul Longoria, Dept. of Mechanical Engineering,
     The Univ. of Texas at Austin and

ode78.m was originally written by:
     Dr. Howard Wilson & 
     Daljeet Singh, Dept. Of Electrical Engineering,
     The University of Alabama

The other files were created from the structure of these 
along with coefficients from standard numerical methods books.
Dr. Longoria has given permission to redistribute rk4fixed.m.

ode78.m was origianlly found at:
ftp://ftp.mathworks.com/pub/contrib/v4/diffeq/ode78.m.
& I am redistributing a modified version with Dr. Wilson's
permission.  

Numerous applications in ordinary and partial differential equations
can be found in Dr. Wilson's text:

     Howard Wilson and Louis Turcotte, 'Advanced Mathematics and 
     Mechanics Applications Using MATLAB', 2nd Ed, CRC Press, 1997

----------------------------------------------------------------------

Bugs or changes or comments should be directed to the email address
below.  The latest and greatest versions will generally _NOT_ be found
on the octave-source list, but rather will be maintained  at:
	http://marc.me.utexas.edu/tmp/octave_ode_solvers/

Marc Compere
compere@mail.utexas.edu
created : 06 October 1999
modified: 15 May 2000
