## Copyright (C) 2010 Kurnia Wano, Levente Torok
##.
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##.
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##.
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
##
## -*- texinfo -*-
##
## @deftypefn {Function File} savevtk ( @var{X}, @var{Y}, @var{Z}, @var{filename} )
##  savevtk Save a 3-D scalar array in VTK format.
##  savevtk(array, filename) saves a 3-D array of any size to
##  filename in VTK format.
##.
## -*- texinfo -*-
##
##
## Author: Kurnia Wano, Levente Torok <TorokLev@gmail.com>
## Created: 2010-08-02
## Updates: 2010-11-03
##

function savevtk(array, filename)
    [nx, ny, nz] = size(array);
    fid = fopen(filename, 'wt');
    fprintf(fid, '# vtk DataFile Version 2.0\n');
    fprintf(fid, 'Comment goes here\n');
    fprintf(fid, 'ASCII\n');
    fprintf(fid, '\n');
    fprintf(fid, 'DATASET STRUCTURED_POINTS\n');
    fprintf(fid, 'DIMENSIONS    %d   %d   %d\n', nx, ny, nz);
    fprintf(fid, '\n');
    fprintf(fid, 'ORIGIN    0.000   0.000   0.000\n');
    fprintf(fid, 'SPACING    1.000   1.000   1.000\n');
    fprintf(fid, '\n');
    fprintf(fid, 'POINT_DATA   %d\n', nx*ny*nz);
    fprintf(fid, 'SCALARS scalars double\n');
    fprintf(fid, 'LOOKUP_TABLE default\n');
    fprintf(fid, '\n');
    for a=1:nz
        for b=1:ny
            for c=1:nx
                fprintf(fid, '%d ', array(c,b,a));
            end
            fprintf(fid, '\n');
        end
    end
    fclose(fid);
return
