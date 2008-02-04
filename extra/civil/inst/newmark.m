## Copyright (C) 2000 Matthew W. Roberts.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This software is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{x} =} newmark(@var{m}, @var{c}, @var{k}, @var{f}, @var{dt}, @var{x0} = 0, @var{x'0} = 0, @var{alpha} = 1/2, @var{beta} = 1/4, @var{flags} = "")
## Computes the solution of second-order differential equations of the form
##
## @example
## @var{m}  @var{x}'' + @var{c} @var{x}' + @var{k} @var{x} = @var{f}
## @end example
##
## where @var{x}' denotes the first time derivative of @var{x}.
##
## If the function is called without the assigning a return value
## then @var{x} is plotted versus time.
##
## @strong{Inputs}
##
## @table @var
## @item m
## The mass of the body.
## @item c
## Viscous damping of the system.
## @item k
## Spring stiffness (restoring force coefficient).
## @item f
## The forcing function as a time sampled or impulse vector
## (see @strong{Special Cases}).
## @item dt
## The time step -- assumed to be constant
## @item x0
## Initial displacement, default is zero
## @item x'0
## Initial velocity, default is zero
## @item alpha
## Alpha Coefficient -- Controls "artificial damping" of the system.
## Unless you have a really good reason, this should be 1/2 which is
## the default.
## @item beta
## Beta Coefficient -- This coefficient is used to estimate the form of the
## system acceleration between time steps.  Values between 1/4 and 1/6 are
## common. The default is 1/4 which is unconditionally stable.
## @item flags
## A string value which defines special cases.  The cases are defined by 
## unique characters as explained in @strong{Special Cases} below.
## @end table
##
## @strong{Outputs}
##
## @table @var
## @item  x
## Matrix of size (3, @code{length}(@var{f})) with time series of displacement
## (@var{x}(1,:)), velocity (@var{x}(2,:)), and acceleration (@var{x}(3,:))
## @end table
##
## @strong{Special Cases}
##
## The @var{flags} variable is used to define special cases of analysis as
## follows.
##
## "i"  - Impulse forcing function.  The forcing function, @var{f} is a
##        vector of impulses instead of a sampled time history.
## "n"  - The stiffness is non-linear.  In this case, @var{k} is a string
##        which contains the name of a function defining the non-linear
##        stiffness.
##
## @end deftypefn

## Author:  Matthew W. Roberts
## Created: May, 2000



function  x = newmark( M, C, K, f, dt, u0, v0, alpha, beta, flags)

# Take care of unititalized input variables

if( nargin < 6)
	u0 = 0;
endif
if( nargin < 7)
	v0 = 0;
endif
if( nargin < 8)
	alpha = 0.5;
endif
if( nargin < 9)
	beta = 0.25;
endif
if( nargin < 10)
	flags = "";
endif

if( findstr( flags, "n"))
	x = nlnewmark( M, C, K, f, dt, u0, v0, alpha, beta, flags);
else # {

# check for flags
if( findstr( flags, "i"))
	_local_impulse = 1;  # local variable
else
	_local_impulse = 0;
endif


# xxBEGINxx
# initialize x
x = zeros( 3, length(f));

x(1,1) = u0;
x(2,1) = v0;

# compute the initial acceleration
if( _local_impulse)
	# an initial impulse has the effect of instantaneously changing
	# the initial velocity.
	v0 = v0 + f(1)/M;
	x(2,1) = v0;
	# Now, initial acceleration comes from solving m*a0 + c*v0 + k*u0 = 0
	x(3,1) = ( - C * v0 - K * u0 ) / M;
else
	# Compute a0 from m*a0 + c*v0 + k*u0 = f0
	x(3,1) = ( f(1) - C * v0 - K * u0 ) / M;
endif
A = [ 1, 0, -dt^2*beta;
      0, 1, -dt*alpha;
      K, C, M];

Ainv = inv(A);

# define some constants so that we won't need to recalculate each loop:
c1 = dt^2 * (0.5 - beta);
c2 = dt   * (1 - alpha);

	rhs(3) = 0;  # default value
	for i = 2:length(f)
		% create the rhs
		rhs(1) = x(1, i-1) + dt * x(2, i-1) + c1 * x(3, i-1);
		rhs(2) =                  x(2, i-1) + c2 * x(3, i-1);
		if( ! _local_impulse)
			rhs(3) = f(i);
		endif

		# solve for x
		x(:, i) = Ainv * rhs;

		# add the impulse effect...
		if( _local_impulse)
			x(2,i) = x(2,i) + f(i)/M;
		endif
	
	endfor

endif  # }

if( nargout < 1)
	t = 0:dt:(length(f)-1)*dt;
	length(t);
	plot( t, x(1,:));
	x = [];
endif
endfunction
