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

function Q = Quaternions(varargin)

  switch nargin
    case 0
      Q = struct("q_wrap",quaternion(1,0,0,0), "R",eye(3),"T",[eye(3) zeros(3,1); 0 0 0 1],...
                 "s",1,"v",[0 0 0]);
    otherwise
      error("robotics:Devel","multiple constructors not implemented");
  end

  Q = class (Q, 'Quaternion');
  
endfunction

%!test
%!  Q = Quaternion();

%!error Quaternion([1 0 0 0])
