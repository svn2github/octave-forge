## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{Q} =} Quaternion ()
## @deftypefnx {Function File} {@var{Q} =} Quaternion (@var{q1})
## @deftypefnx {Function File} {@var{Q} =} Quaternion ([@var{s} @var{x} @var{y} @var{z}])
## @deftypefnx {Function File} {@var{Q} =} Quaternion (@var{s})
## @deftypefnx {Function File} {@var{Q} =} Quaternion (@var{v})
## @deftypefnx {Function File} {@var{Q} =} Quaternion (@var{th},@var{v})
## @deftypefnx {Function File} {@var{Q} =} Quaternion (@var{r})
## @deftypefnx {Function File} {@var{Q} =} Quaternion (@var{t})
## Create an object of the Quaternion class.
##
## This is a wrapper class of the quaterion class of the quaternions_oo package.
##
## Quaternion() is the identitity quaternion 1<0,0,0> representing a null
## rotation.
##
## Quaternion (@var{q1}) is a copy of the quaternion Q1
##
## Quaternion ([@var{s} @var{x} @var{y} @var{z}]) is a quaternion formed by
## specifying directly its 4 elements
##
## Quaternion (@var{s}) is a quaternion formed from the scalar S and zero vector
## part: S<0,0,0>
##
## Quaternion (@var{v}) is a pure quaternion with the specified vector part: 0<V>
##
## Quaternion (@var{th},@var{v}) is a unit quaternion corresponding to rotation
## of TH about the vector V.
##
## Quaternion (@var{r}) is a unit quaternion corresponding to the orthonormal
## rotation matrix R.
##
## Quaternion (@var{t}) is a unit quaternion equivalent to the rotational part
## of the homogeneous transform T.
##
## @seealso{quaternion}
## @end deftypefn

function Q = Quaternion(varargin)

  switch nargin
    case 0
      Q = struct ("q_wrap",quaternion (1,0,0,0));
    case 1
      a = varargin{1};

      if strcmp(class(a), "Quaternion")        # Quaternion(Quaternion)

        Q = a;

      elseif strcmp(class(a), "quaternion")        # Quaternion(quaternion)

        Q.q_wrap = a;

      elseif !isnumeric (a)
        error("Quaternion:InvalidArgument","No constructor for argument of class %s",class(a));
      end

      if isreal (a) && size(a,2) == 1       # Quaternion (scalar part)

         q = quaternion (a);
         Q = struct ("q_wrap",q);

      elseif isreal (a) && all (size (a) == [1 3]) # Quaternion (vector part)

         q = quaternion (a(1,1), a(1,2), a(1,3));
         Q = struct ("q_wrap",q);

      elseif isreal (a) && all (size (a) == [1 4]) # Quaternion (scalar & vector part)

         q = quaternion (a(1,1), a(1,2), a(1,3),a(1,4));
         Q = struct ("q_wrap",q);

      elseif all(size(a) == [3 3]) || all(size(a) == [4 4]) #   Q = Quaternion(R) or Q = Quaternion(T)

          q = Quaternion( tr2q(a(1:3,1:3)) );

      else
        print_usage ();
      endif

    case 2 # Quaternion (angle, vector)

       vv = varargin{2};
       th = varargin{1};

       if !isnumeric (vv) || !isnumeric (th)
         error("Quaternion:InvalidArgument","No constructor for arguments of class %s,%s",class(vv),class(th));
       end

       if isscalar(vv) && isvector(th)
         Q = struct ("q_wrap",rot2q(vv,th));
       else
         print_usage ();
       end

    otherwise
      error("Quaternion:InvalidArgument","No constructor with more than 2 arguments");
  end

  Q = class (Q, 'Quaternion');

endfunction

%!test
%!  Q = Quaternion();
%!  Q = Quaternion(Q);
%!  Q = Quaternion(1);
%!  Q = Quaternion((1:5)');
%!  Q = Quaternion(eye(3));
%!  Q = Quaternion(eye(4));
%!  Q = Quaternion(rotv([0 0 1], pi/2))
%!  Q = Quaternion(pi/2, [0 0 1])

%!test
%!  q = quaternion(2,1,3,4);
%!  Q = Quaternion(q);
%!  assert(Q.q == q);

%!error <No constructor> Quaternion('hola');

%!shared Q
%! Q = Quaternion([1,0,0,1]);

%!test %% Methods
%! Q.norm();
%! Q.^5;
%! Q^5;

%!assert(Quaternion([-0.5,0,0,0.5]) == Q.dot([0 0 1]))
%!assert(Quaternion([-0.5,0.5,0.5,0.5]) == Q.dot([0 1 1]))

%!assert( Q.inv() == Quaternion([1,0,0,-1]) )

%!test
%! q = Q.unit() - Quaternion([sqrt(0.5),0,0,sqrt(0.5)]);
%! assert( q.norm() < sqrt(eps))

%!error(Q.plot());
%!error(Q.interp());
%!error(Q.scale());

%!test %% Properties
%! Q.s;
%! Q.v;
%! Q.unit().R;
%! Q.unit().T;

%!assert(Q.q == quaternion(1,0,0,1));
%!assert(Q.double, [1,0,0,1]);
