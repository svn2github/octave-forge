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

if (exist ("oplot-gl.jar", "file"))
  javaaddpath ("oplot-gl.jar");
else
  javaaddpath (".");
endif
javaaddpath ("jogl.jar");
dispatch ("get", "oplot_get", "any");
dispatch ("set", "oplot_set", "any");
dispatch ("ishandle", "oplot_ishandle", "any");
dispatch ("__go_figure__", "oplot_go_figure", "any");
dispatch ("__go_delete__", "oplot_go_delete", "any");
dispatch ("__go_axes__", "oplot_go_axes", "any");
dispatch ("__go_axes_init__", "oplot_go_axes_init", "any");
dispatch ("__go_text__", "oplot_go_text", "any");
dispatch ("__go_surface__", "oplot_go_surface", "any");
