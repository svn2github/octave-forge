%% Copyright (c) 1998, 2000, 2005, 2007 Auburn University.
%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {} dot (q, omega)
%% Derivative of a quaternion.
%%
%% Let Q be a quaternion to transform a vector from a fixed frame to
%% a rotating frame.  If the rotating frame is rotating about the
%% [x, y, z] axes at angular rates [wx, wy, wz], then the derivative
%% of Q is given by
%%
%% @example
%% Q' = dot(Q, omega)
%% @end example
%%
%% If the passive convention is used (rotate the frame, not the vector),
%% then
%%
%% @example
%% Q' = dot(Q,-omega)
%% @end example
%% @end deftypefn

%% Adapted from: qderiv by A. S. Hodel <a.s.hodel@eng.auburn.edu>

function qd = dot (q, Omega)

  if (nargin != 2)
    print_usage ();
  endif

  Omega = vec (Omega);

  if (length (Omega) != 3)
    error ("Quaternion:InvalidArgument: Omega must be a length 3 vector");
  endif

  qd = 0.5 * quaternion(Omega(1),Omega(2),Omega(3)) * q;

endfunction

%!shared q
%! q = quaternion(3,1,0,0);

%!assert(quaternion(0,0,0.5,1.5) == dot(q,[0 0 1]))
%!assert(quaternion(0,0,2,1) == dot(q,[0 1 1]))

