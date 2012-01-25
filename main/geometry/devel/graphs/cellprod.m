%% Copyright (C) 2012 Juan Pablo Carbajal
%%
%% This program is free software; you can redistribute it and/or modify it under
%% the terms of the GNU General Public License as published by the Free Software
%% Foundation; either version 3 of the License, or (at your option) any later
%% version.
%%
%% This program is distributed in the hope that it will be useful, but WITHOUT
%% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
%% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
%% details.
%%
%% You should have received a copy of the GNU General Public License along with
%% this program; if not, see <http://www.gnu.org/licenses/>.

function s=cellprod(s1,s2)
  % if ~iscellstr(s1) || ~iscellstr(s2)
  %     disp('Error. Arguments must be cell string');
  % end

  n=numel(s1);
  if n==1
      s=cellSprod(s1{1},s2);
  else
      X=cellSprod(s1{1},s2)
      s=cellsum(X,cellprod({s1{2:end}},s2));
  end

endfunction
