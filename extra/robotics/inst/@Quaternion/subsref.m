## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## Improvement based on John W. Eaton's idea.
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
## @deftypefn {Function File} {} subsrefs ()
## @end deftypefn

function varargout = subsref (obj, idx)

  persistent __method__ __properties__ method4field typeNotImplemented
  if isempty(__method__)

    __method__ = struct();

    __method__.inv = @(o,a) q2Q(o, conj(wrapperfield(o)));

    __method__.norm = @(o,a) abs(wrapperfield(o));

    __method__.unit = @(o,a) q2Q(o,wrapperfield(o) / abs(wrapperfield(o)));

    __method__.plot = @(o,a) error(typeNotImplemented,'plot',o);

    __method__.interp = @(o,a) error(typeNotImplemented,'interp',o);

    __method__.scale = @(o,a) error(typeNotImplemented,'scale',o);

    __method__.dot = @(o,a) error(typeNotImplemented,'dot',o);


    __properties__ = struct();

    __properties__.s = @(o) wrapperfield(o).w;

    __properties__.v = @(o) [wrapperfield(o).x wrapperfield(o).y wrapperfield(o).z];

    __properties__.R = @(o) error(typeNotImplemented,'R',o);

    __properties__.T = @(o) error(typeNotImplemented,'T',o);

    # Error strings
    method4field = "Class %s has no field %s. Use %s() for the method.";
    typeNotImplemented = "%s no implemented for class %s.";

  end
  %% Flags
  ismet = false;

  if ( !strcmp (class (obj), 'Quaternion') )
    error ("Object must be of the Quaternion class but '%s' was used", class (obj) );
  elseif ( idx(1).type != '.' )
    error ("Invalid index for class %s", class (obj) );
  endif

  method = idx(1).subs;
  if ~isfield(__method__, method) && ~isfield(__properties__, method)
    error('Unknown method or property %s.',method);
  elseif isfield(__method__, method)
    fhandle = __method__.(method);
    ismet = true;
  elseif isfield(__properties__, method)
    varargout{1} = __properties__.(method)(obj);
    return
  end

  if ismet && numel (idx) == 1 % can't access methods as properties

    error (method4field, class (obj), method, method);

  end

  if strcmp (idx(2).type, '()')

    args = idx(2).subs;
    if isempty(args)
     out = fhandle (obj);
    else
      out = fhandle (obj, args{:});
    end

    varargout{1} = out;

  else

    error (typeNotImplemented,[method idx(2).type], class (obj));

  end

endfunction
