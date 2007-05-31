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

if (exist ("jhandles.jar", "file"))
  javaaddpath ("jhandles.jar");
else
  javaaddpath (".");
endif
javaaddpath ("jogl.jar");
dispatch ("get", "jhandles_get", "any");
dispatch ("set", "jhandles_set", "any");
dispatch ("ishandle", "jhandles_ishandle", "any");
dispatch ("__go_figure__", "jhandles_go_figure", "any");
dispatch ("__go_delete__", "jhandles_go_delete", "any");
dispatch ("__go_axes__", "jhandles_go_axes", "any");
dispatch ("__go_axes_init__", "jhandles_go_axes_init", "any");
dispatch ("__go_text__", "jhandles_go_text", "any");
dispatch ("__go_surface__", "jhandles_go_surface", "any");
