## Copyright (C) 2006 Michel D. Schmid <michaelschmid@users.sourceforge.net>
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
## @deftypefn {Function File} {} __printBiases (@var{fid})
## @code{printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: Michel D. Schmid <michaelschmid@users.sourceforge.net>

function __printBiases(fid,net)

  if isfield(net,"biases")
    # check if it's cell array
    if iscell(net.biases)
      [nRows, nColumns] = size(net.biases);
      # insert enough spaces to put ":" to position 20
      # insert 2 spaces for distance between ":" and "%"
      fprintf(fid,"              biases: {%dx%d cell} containing %d biases\n",nRows,nColumns,length(net.biases));
    else
      fprintf(fid,"unsure if this is possible\n");
    endif
  endif

endfunction