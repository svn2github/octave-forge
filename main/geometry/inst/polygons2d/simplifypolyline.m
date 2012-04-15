%% Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
%% @deftypefn {Function File} {[@var{pline2} @var{idx}] = } simplifypolyline (@var{pline})
%% @deftypefnx {Function File} {@dots{} = } simplifypolyline (@dots{},@var{property},@var{value},@dots{})
%% Simplify or subsample a polyline using the Ramer-Douglas-Peucker algorithm,
%% a.k.a. the iterative end-point fit algorithm or the split-and-merge algorithm.
%%
%% The @var{pline} as a N-by-2 matrix. Rows correspond to the
%% verices (compatible with @code{polygons2d}). The vector @var{idx} constains
%% the indexes on vetices in @var{pline} that generates @var{pline2}, i.e.
%% @code{pline2 = pline(idx,:)}.
%%
%% @strong{Parameters}
%% @table @samp
%% @item 'Nmax'
%% Maximum number of vertices. Default value @code{100}.
%% @item 'Tol'
%% Tolerance for the error criteria. Default value @code{1e-4}.
%% @item 'MaxIter'
%% Maximum number of iterations. Default value @code{10}.
%% @item 'Method'
%% Not implemented.
%% @end table
%%
%% Run @code{demo simplifypolyline} to see an example.
%%
%% @seealso{curve2polyline, curveval}
%% @end deftypefn

function [pline idx] = simplifypolyline (pline_o, varargin)

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "simplifypolyline";
  parser = addParamValue (parser,'Nmax', 100, @(x)x>0);
  parser = addParamValue (parser,'Tol', 1e-4, @(x)x>0);
  parser = addParamValue (parser,'MaxIter', 100, @(x)x>0);
  parser = parse(parser,varargin{:});

  Nmax      = parser.Results.Nmax;
  tol       = parser.Results.Tol;
  MaxIter   = parser.Results.MaxIter;

  clear parser
  msg = ["Maximum number of points reached with maximal error %g." ...
       " Increase '%s' if the result is not satisfactory."];
  # ------ #

  [N dim] = size(pline_o);
  idx = [1 N];

  for iter = 1:MaxIter
    % Find the point with the maximum distance.
    [dist ii] = maxdistance (pline_o, idx);

    if dist < tol;
      break;
    end

    idx(end+1) = ii;
    idx = sort(idx);

    if length(idx) >= Nmax
      warning('geometry:MayBeWrongOutput', sprintf(msg,dist,'Nmax'));
      break;
    end

  end
  if iter == MaxIter
    warning('geometry:MayBeWrongOutput', sprintf(msg,dist,'MaxIter'));
  end

  pline = pline_o(idx,:);
endfunction

function [dist ii] = maxdistance (p,idx)

  edges = [p(idx(1:end-1),:) p(idx(2:end),:)];
  %% Calculate distance between all points and edges
  %% What is better? this or a only comparing the points that are between the extrema
  %% of each edge.
  [d pos] = distancePointEdge (p, edges);

  %% Filter out all points outside the edges
  tf = pos == 0 | pos == 1;
  d(tf) = -1;

  [dist j] = max(d(:));
  ii = ind2sub (size(d),j);

end

%!demo
%! t     = linspace(0,1,100).';
%! y     = polyval([1 -1.5 0.5 0],t);
%! pline = [t y];
%!
%! figure(1)
%! clf
%! plot (t,y,'-r;Original;','linewidth',2);
%! hold on
%!
%! tol    = [8 2  1 0.5]*1e-2;
%! colors = jet(4);
%!
%! for i=1:4
%!   pline_ = simplifypolyline(pline,'tol',tol(i));
%!   msg = sprintf('-;%g;',tol(i));
%!   h = plot (pline_(:,1),pline_(:,2),msg);
%!   set(h,'color',colors(i,:),'linewidth',2,'markersize',4);
%! end
%! hold off
%!
%! % ---------------------------------------------------------
%! % Four approximations of the initial polyline with decreasing tolerances.
