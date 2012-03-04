## Copyright (C) 2012   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{dat} =} cat (@var{dim}, @var{dat1}, @var{dat2}, @dots{})
## Concatenation of iddata objects along dimension @var{dim}.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: March 2012
## Version: 0.1

function dat = cat (dim, varargin)

  switch (dim)
    case 1      # add samples; p, m, e identical
      %[~, p, m, e]
      %nvec = cellfun (@size
      [~, p, m, e] = cellfun (@size, varargin, "uniformoutput", false)
      
      %y = cellfun (@(dat) vertcat (dat.y) 
      %dat = cellfun (@iddata, varargin)
      #y = cellfun (@vertcat
      
      ycell = cellfun (@(dat) dat.y, varargin, "uniformoutput", false)



      %varargin{:}.y
      %varargin(:).y
    case 2      # horzcat, same outputs; 
    
    case 3      # vertcat, same inputs
    
    case 4      # add experiments
      tmp = cellfun (@iddata, varargin);
      
      y = vertcat (tmp.y);
      u = vertcat (tmp.u);
      
      dat = iddata (y, u);
      
  
  endswitch

endfunction