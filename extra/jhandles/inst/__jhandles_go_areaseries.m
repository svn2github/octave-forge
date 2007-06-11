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

function [ h ] = __jhandles_go_areaseries (ax, X, Y, bv, varargin)

  parent = __get_object__ (ax);
  h = [];

  YY = cumsum (Y, 2);

  for k = 1:size (Y,2)
    a_obj = java_new ("org.octave.graphics.GroupObject", parent);
    hh = a_obj.getHandle ();
    addprop (hh, "XData", "doublearray", X(:,k));
    addprop (hh, "YData", "doublearray", Y(:,k));
    addprop (hh, "CDataMapping", "radio", "scaled|direct", "scaled");
    if (k == 1)
      vv = [X(1,k) bv 0; X(:,k) Y(:,k) zeros(size(Y,1),1); X(end,k) bv 0];
      fv = [1:size(vv,1)];
    else
      vv = [X(end:-1:1,k-1) YY(end:-1:1,k-1) zeros(size(Y,1),1); X(:,k) YY(:,k) zeros(size(Y,1),1)];
      fv = [1:size(vv,1)];
    endif
    fvc = k * ones (size (vv,1), 1);
    hp = patch (hh, "Faces", fv, "Vertices", vv, "FaceVertexCData", fvc, ...
      "FaceColor", "flat", "EdgeColor", "k");
    set (hh, "XLim", get(hp, "XLim"));
    set (hh, "YLim", get(hp, "YLim"));
    set (hh, "CLim", get(hp, "CLim"));
    set (hh, "CLimInclude", true);
    a_obj.validate ();
    h = [h hh];
  endfor

endfunction
