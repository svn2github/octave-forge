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
## @deftypefn {Built-in Function} {} [@var{v1},...] =
## getfield (@var{s}, 'k1',...)
## extract fields from a structure
## example: given  ss(1,2).fd(3).b=5;
##          getfield(ss,{1,2},'fd',{3},'b') => 5
##
## Note that this function is deprecated in favour of 'dynamic
## fields'. So the previous could be written
##          i1= {1,2}; i2= 'fd'; i3= {3}; i4= 'b';
##          ss( i1{:} ).( i2 )( i3{:} ).( i4 )
## @end deftypefn
## @seealso{setfield,getfields,rmfield,isfield,isstruct,fields,cmpstruct,struct}

## $Id$

function v= getfield( obj, varargin )
   field= field_access( varargin{1:nargin-1} );
   v= eval(field);

function str= field_access( varargin )
   str= 'obj';
   for i=1:nargin
      v= varargin{i};
      if iscell( v )
          sep= '(';
          for j=1:length(v)
              str= [str, sep, num2str(v{j}) ];
              sep= ',';
          end
          str= [str, ')'];
      else
          str= [str, '.', v];
      end
   end

# if we know if dynamic field names are supported, then
#   function s=mygetfield(s,varargin)
#   for idx= 1:nargin-1
#      i=varargin{idx};
#      if iscell(i)
#         s= s( i{:} );
#      else
#         s= s.( i );
#      end
#   end

