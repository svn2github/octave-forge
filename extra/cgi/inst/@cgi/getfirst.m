% val = getfirst(cgi,name,default)
% Return the first CGI parameter with the given name.
% If the CGI parameter is not found in the query string, then the 
% parameter default is returned if specified or an error is raised.

function val = getfirst(cgi,name,default)

vals = getlist(cgi,name);

if ~isempty(vals)
  val = vals{1};
else
  if nargin == 3
    val = default;
  else
    error('CGI parameter %s was not provided',name);
  end
end


% Copyright (C) 2012 Alexander Barth <barth.alexander@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; If not, see <http://www.gnu.org/licenses/>.