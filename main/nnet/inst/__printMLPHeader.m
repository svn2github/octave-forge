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
## @deftypefn {Function File} {} __printMLPHeader (@var{fid})
## @code{__printMLPHeader} saves the header of a  neural network structure
## to a *.txt file with identification @code{fid}.
## @end deftypefn

## Author: mds
## $Revision$, $Date$

function __printMLPHeader(fid)

     # one empty row
     fprintf(fid,"\n");
     # write "net="
     fprintf(fid,"net=\n");
     # next empty row
     fprintf(fid,"\n");
     # write "Neural Network object:", insert two spaces..
     fprintf(fid,"  Neural Network object:\n");
     # next empty row
     fprintf(fid,"\n");
     # write "architecture:", insert two spaces..
     fprintf(fid,"  architecture:\n");
     # one more time an empty row
     fprintf(fid,"\n");
     
endfunction