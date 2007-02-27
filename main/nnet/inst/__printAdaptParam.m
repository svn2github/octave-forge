## Copyright (C) 2006 Michel D. Schmid
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} printAdaptParam (@var{fid})
## @code{printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: mds
## $Revision$, $Date$

function printAdaptParam(fid,net)

  if isfield(net,"adaptParam")
    if isempty(net.adaptParam)
      fprintf(fid,"          adaptParam:  '%s'\n","not yet used item");
    else
      fprintf(fid,"          adaptParam:  '%s'\n",net.adaptParam);
    endif
  endif

endfunction