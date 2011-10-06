%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%% 
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

function paths = getSVGPaths_py (svg, varargin)

  %% Call python script
  [st str]=system (sprintf ('python parseTest.py %s', svg));

  %% Parse ouput
  strs = strsplit (str(1:end-1), '$', true);

  npaths = numel (strs);
  paths = cell(npaths,1);
  %% Convert path data to polygons
  for ip = 1:npaths

    eval (strs{ip});
    %% FIXME: intialize struct with cell field
    svgpath2.cmd = svgpath(1).cmd;
    svgpath2.data = {svgpath.data};
    
    nD = length(svgpath2.cmd);
    paths{ip} = cell (nD-1,1);
    
    point_end=[];
    if svgpath2.cmd(end) == 'Z'
      paths{ip}(nD-1) = [];
      nD -= 1;
      point_end = svgpath2.data{1};
    end

    %% Initial point
    points(1,:) = svgpath2.data{1};
    
    for jp = 2:nD
      switch svgpath2.cmd(jp)
        case 'L'
          %% Straigth segment to polygon
          points(2,:) = svgpath2.data{jp};
          pp = [(points(2,:)-points(1,:))' points(1,:)'];
          clear points
          points(1,:) = [polyval(pp(1,:),1) polyval(pp(2,:),1)];
          
        case 'C'
          %% Cubic bezier to polygon
          points(2:4,:) = reshape (svgpath2.data{jp}, 2, 3).';
          pp = cbezier2poly (points);
          clear points
          points(1,:) = [polyval(pp(1,:),1) polyval(pp(2,:),1)];
      end
      
      paths{ip}{jp-1} = pp;
    end
    
    if ~isempty(point_end)
      %% Straight segmet to close the path
      points(2,:) = point_end;
      pp = [(points(2,:)-points(1,:))' points(1,:)'];
      
      paths{ip}{end} = pp;
    end
    
  end
  
endfunction

%!test
%! figure(1)
%! hold on
%! paths = getSVGPaths_py ('../drawing.svg');
%! t = linspace (0, 1, 64);
%! for i = 1:numel(paths)
%!    x = []; y = [];
%!    for j = 1:numel(paths{i})
%!     x = cat (2, x, polyval (paths{i}{j}(1,:),t));
%!     y = cat (2, y, polyval (paths{i}{j}(2,:),t));
%!    end
%!    plot(x,y,'-');
%! end
%! axis ij
%! if strcmpi(input('You should see drawing.svg [y/n] ','s'),'n')
%!  error ("didn't get what was expected.");
%! end
%! close 

