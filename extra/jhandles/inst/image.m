## Copyright (C) 2007 Michael Goffioul
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301  USA

function h = image (C, varargin)

  ax_obj = __get_object__ (gca);
  img_obj = java_new ("org.octave.graphics.ImageObject", ax_obj,
    mat2java(double(C(:,:,1))/255), mat2java(double(C(:,:,2))/255), mat2java(double(C(:,:,3))/255));
  img_obj.validate();

  tmp = img_obj.getHandle();
  if (nargout > 0)
    h = tmp;
  endif

endfunction
