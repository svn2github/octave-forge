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

function C=graph2cell(A,type)
  C=cell(size(A));

  x=find(A==0);
  for i=1:numel(x);
      C{x(i)}={''};
  end
  x=find(A~=0 & A~=1);
  for i=1:numel(x);
      C{x(i)}={[' ' num2str(A(x(i))) ' ']};
  end
  x=find(A==1);
  if strcmp(type,'adj')
      for i=1:numel(x);
          C{x(i)}={'u'};
      end
  elseif strcmp(type,'varadj')
      for i=1:numel(x);
          C{x(i)}={[' ' num2str(A(x(i))) ' ']};
      end
  end

endfunction
