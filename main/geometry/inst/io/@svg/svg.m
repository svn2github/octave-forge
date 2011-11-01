## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{obj} =} svg ()
## @deftypefnx {Function File} {@var{obj} =} svg (@var{str})
## Create object @var{obj} of the svn class.
##
## If no input argument is provided the object is empty. @var{str} can be a filename
## or a string defining an inline SVG.
##
## @seealso{@svn/parsePaths}
## @end deftypefn

function svg = svg(name='')

  svg = struct;

  ## SVG data. All the attributes of the <svg> node.
  ## The field unparsed contains all the attributes that are not being parsed.
  svg.Data = struct('height',[],'width',[],'id','null','unparsed',' ');
  
  ## SVG metadata. All the attributes of the <metadata> node. 
  ## The field unparsed contains all the attributes that are not being parsed.
  svg.Metadata = struct('unparsed',' ');

  ## SVG paths. It is a vector of path structs. Maybe path can be a object too?
  ## Order of Path.Data is important so we store in a cell (could be a matrix padded with zeros). 
  ## All the paths stored in polyval compatible format. Straigth segments are also stored as a polynomial.
  svg.Path = struct();
  
  ## SVG paths. All the paths of the svg
  svg = class (svg, 'svg');

  if !isempty (name)
    paths = loadpaths(svg, name);
    svg.Path = paths;
  elseif !ischar(name)
    print_usage ;
  endif


endfunction

%!test
%!  dc = svg('../drawing5.svg');
%!  dc.getpath()
%!  dc.pathid
%!  dc.getpath('path3756')
%!   
%!  dc = svg('../drawing.svg');
%!  ids = dc.pathid;
%!  dc.getpath({ids{[1 3]}})
