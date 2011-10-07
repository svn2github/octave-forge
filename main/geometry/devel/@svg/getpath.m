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
## @deftypefn {Function File} {} function_name ()
## @end deftypefn

function paths = getpath(obj, ids={})

  if !isempty(ids)
  
    if iscell (ids) && iscell(ids{1}) % dealing with ids given as cell
      ids = ids{1};

      if !all ( cellfun (@ischar, ids) )
       print_usage
      end

    elseif !all ( cellfun (@ischar, ids) )
     print_usage
    end
    
  else
    paths = obj.Path;
    return
  end

  tf = ismember (ids, fieldnames (obj.Path));

  cellfun (@(s) printf("'%s' is not a valid path id.\n", s) , {ids{!tf}});

  paths = [];
  if any (tf)
    paths = cellfun(@(s) getfield (obj.Path, s).data, {ids{tf}}, 'UniformOutput', false);
    if numel(paths) == 1
      paths = paths{1};
    end
  end

endfunction

