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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Built-in Function} {} [@var{v1},...] =
## getfields (@var{s}, 'k1',...) = [@var{s}.k1,...]
## Return selected values from a struct. Provides some compatibility
## and some flexibility.
## @end deftypefn
## @seealso{setfields,rmfield,isfield,isstruct,fields,cmpstruct,struct}

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: January 2003

function [varargout] = getfields(s,varargin)
    for i=length(varargin):-1:1
	varargout{i} = s.(varargin{i});
    end
end
%!
%!assert(getfields(struct('key','value'),'key'),'value')
%!
