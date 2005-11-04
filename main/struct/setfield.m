## Copyright (C) 2000  Etienne Grossmann
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Built-in Function} {} [@var{k1},..., @var{v1}] =
## @code{setfield (@var{s}, 'k1',..., 'v1')} sets field members in a structure
##
## @example
## @group
## oo(1,1).f0= 1;
## oo= setfield(oo,@{1,2@},'fd',@{3@},'b', 6);
## oo(1,2).fd(3).b == 6
## @result{} ans = 1
## @end group
## @end example
##
## Note that this function is deprecated in favour of 'dynamic
## fields'. So the previous could be written
##
## @example
##          i1= @{1,2@}; i2= 'fd'; i3= @{3@}; i4= 'b';
##          oo( i1@{:@} ).( i2 )( i3@{:@} ).( i4 ) == 6;
## @end example
## @end deftypefn
## @seealso{getfield,setfields,rmfield,isfield,isstruct,fields,cmpstruct,struct}

## Author:  Etienne Grossmann <etienne@cs.uky.edu>

## $Id$

function obj= setfield( obj, varargin )
   field= field_access( varargin{1:nargin-2} );
   val= varargin{ nargin-1 };
   eval(sprintf("%s=val;",field));

function str= field_access( varargin )
   str= 'obj';
   for i=1:nargin
      v= varargin{i};
      if iscell( v )
          sep= '(';
          for j=1:length(v)
              str= sprintf("%s%s%s", str, sep, num2str(v{j}));
              sep= ',';
          end
          str= sprintf("%s)", str);
      else
	  str= sprintf("%s.%s", str, v);
      end
   end

%!test
%! x.a = "hello";
%! x = setfield(x,"b","world");
%! y = struct('a','hello','b','world');
%! assert(x,y);

