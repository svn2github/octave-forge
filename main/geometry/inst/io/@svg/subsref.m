## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {} function_name ()
## @end deftypefn

function varargout = subsref (obj, idx)

  persistent __method__
  if isempty(__method__)

    __method__ = struct();
    
    __method__.plot = @(o,a) plot (o, a);
    __method__.getpath = @(o,a) getpath (o, a);
    __method__.pathid = @(o,a) fieldnames(o.Path);
    __method__.path2polygon = @(o,a) path2polygon (o, a);
    __method__.normalize = @(o,a) normalize (o, a);
    __method__.height = @(o,a) o.Data.height;
    __method__.width = @(o,a) o.Data.width;
  
    debug="first call"
  end

  if ( !strcmp (class (obj), 'svg') )
    error ("Object must be of the svg class but '%s' was used", class (obj) );
  elseif ( idx(1).type != '.' )
    error ("Invalid index for class %s", class (obj) );
  endif

  # Error strings
  method4field = "Class %s has no field %s. Use %s() for the method.";
  typeNotImplemented = "%s no implemented for class %s.";

  method = idx(1).subs
  debug="Following calls"
  if ~isfield(__method__, method)
    error('Unknown method %s.',method);
  else
    fhandle = __method__.(method);
  end

  if strcmp(method,'normalize')
    warning("svg:Devel","Not returning second output argument of %s use method(obj) API to get it",method);
  end

  if numel (idx) == 1 % can't access properties, only methods

    error (method4field, class (obj), method, method);

  end

  if strcmp (idx(2).type, '()')

    args = idx(2).subs;
    out = fhandle (obj, args{:});

  else

    error (typeNotImplemented,[method idx(2).type], class (obj));

  end

endfunction

%{
06:42:38 PM) jwe: KaKiLa: yes, I looked at it.  I still don't think you should try to fake the obj.method() style, but if you insist, you could probably shorten your code by just using case {'meth1', 'meth2', ...} and then retval = feval (method, args); ...
(06:43:12 PM) jwe: I don't see why you should repeat the same code when the only thing that changes is the method name.
(06:44:35 PM) jwe: Or, I think you could create a persistent structure with all the method names as fields, and each field would hold a function handle for that method.
(06:45:28 PM) jwe: then I think you could write  fhandle = s(method); retval = fhandle (args);
(06:45:38 PM) KaKiLa: jwe: you are right, of course. I was no improving code yet...want to get to minimal functionality...very close now. I will implement one of your suggestions in the next release. Thanks!
(06:45:46 PM) jwe: sorry, fhandle = s.(method);

persistent __method__
if isempty(__method__)

  __method__ = struct();
  
  __method__.plot = @(o,a) plot (o, a);
  __method__.getpath = @(o,a) getpath (o, a);
  __method__.pathid = @(o,a) fieldnames(o.Path);
  __method__.path2polygon = @(o,a) path2polygon (o, a);
  __method__.normalize = @(o,a) normalize (o, a);
  __method__.height = @(o,a) o.Data.height;
  __method__.width = @(o,a) o.Data.width;

end

method = idx(1).subs;
if ~isfield(__method__, method)
  error('Unknown method %s.',method);
else
  fhandle = __method__.(method);
end

if strcmp(method,'normalize')
  warning("svg:Devel","Not returning second output argument of %s use method(obj) API to get it",method);
end

if numel (idx) == 1 % can't access properties, only methods

  error (method4field, class (obj), method, method);

end

if strcmp (idx(2).type, '()')

  args = idx(2).subs;
  out = fhandle (obj, args{:});

else

  error (typeNotImplemented,[method idx(2).type], class (obj));

end

}%
