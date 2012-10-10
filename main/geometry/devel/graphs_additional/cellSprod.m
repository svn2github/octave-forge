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

function s=cellSprod(k,s2)
  if ~ischar(k)
      disp('First argument must be a string.')
      s=[];
      return
  end
  if strcmp(k,'')
      s={''};
      return
  end
  if strcmp(k,'u')
      s=s2;
      return;
  end

  n=numel(s2);
  for i=1:n
      if ~strcmp(s2{i},'')
          if strcmp(s2{i},'u')
              s{i}=k;
          else
              s{i}=[k s2{i}];
          end
      else
          s{i}='';
      end
  end

endfunction
