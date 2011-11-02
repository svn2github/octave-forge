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

%% -*- texinfo -*-
%% @deftypefn {Function File} @var{SVGn} = normalize (@var{SVG})
%% TODO: normalizes and SVG.
%% @end deftypefn

function SVGn = normalize (obj)

  warning("svg:Devel","This function is under development and is  not working correctly.");
  
  SVGn = obj;
  if ~obj.Data.normalized
    % Translate
    TransV = [0; obj.Data.height/2];
    % Scale
    Dnorm = sqrt (obj.Data.width ^ 2 + obj.Data.height ^ 2);
    S = (1 / Dnorm) * eye (2);

    ids = fieldnames (obj.Path);
    npath = numel(ids);
    for i = 1:npath
        nc = numel (obj.Path.(ids{i}).data);
        
        for j=1:nc
          % Translate to middle
          SVGn.Path.(ids{i}).data{j}(:,end) = ... 
                                      obj.Path.(ids{i}).data{j}(:,end) - TransV;
          
          % Reflect respect to x-axis
          SVGn.Path.(ids{i}).data{j}(2, :) = -SVGn.Path.(ids{i}).data{j}(2, :);
          TransV(2) = -TransV(2);
          
          % Translate to bottom
          SVGn.Path.(ids{i}).data{j}(:,end) = ...
                                      SVGn.Path.(ids{i}).data{j}(:,end) - TransV;
          
          %Scale
          SVGn.Path.(ids{i}).data{j} = S * SVGn.Path.(ids{i}).data{j};
        end
    end
    SVGn.Data.height = SVGn.Data.height / Dnorm;
    SVGn.Data.width = SVGn.Data.width / Dnorm;
    SVGn.Data.normalized = true;
  end

end

