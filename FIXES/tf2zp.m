## Copyright (C) 1999 Paul Kienzle
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

## usage: [z, p, g] = tf2zp(b,a)
##
## Convert transfer function f(x)=sum(b*x^n)/sum(a*x^n) to
## zero-pole-gain form f(x)=g*prod(1-z*x)/prod(1-p*x)

## TODO: See if tf2ss followed by ss2zp gives better results.  These
## TODO: are available from the control system toolbox.  Note that
## TODO: the control systems toolbox doesn't bother, but instead uses
## TODO: roots(b) and roots(a) as we do here (though they are very
## TODO: long-winded about it---must ask why).
function [z, p, g] = tf2zp(b, a)
  if nargin!=2 || nargout!=3,
    usage("[z, p, g] = tf2zp(b, a)");
  endif
  if isempty(b) || isempty(a)
    error("tf2zp b or a is empty. Perhaps already in zero-pole form?");
  endif
  g = b(1)/a(1);
  z = roots(b);
  p = roots(a);
endfunction
