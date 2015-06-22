%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{CGI} =} cgi ()
%% Creates a CGI object to parse CGI query string from GET or POST requests.
%% Parameter can be return by the functions getfirst and getlist or
%% with the dot-syntax (CGI.form.name).
%%
%% The methods getfirst and getlist behave as the Python CGI functions.
%% 
%% @end deftypefn
%% @seealso{@@cgi/getfirst,@@cgi/getlist}


function retval = cgi()

self.request_method = getenv('REQUEST_METHOD');

self.params = {};
self.vals = {};

if strcmp(self.request_method,'GET') || ...
   strcmp(self.request_method,'HEAD')
  % GET/HEAD request
  self.query_string = getenv('QUERY_STRING');
elseif strcmp(self.request_method,'POST')
  % POST request
  content_type = getenv('CONTENT_TYPE');
  content_length = str2double(getenv('CONTENT_LENGTH'));

  if strcmp(content_type,'application/x-www-form-urlencoded')
    self.query_string = fscanf(stdin,'%c',content_length);

  % elseif strcmp(content_type,'multipart/form-data')
  %   % Content-Type: multipart/form-data; boundary=AaB03x
  %   line = fgetl(stdin)

  %   [header_type,header_value,attrib] = parseline(line);
  %   assert(header_type,'Content-Type');
  %   assert(header_value,'multipart/form-data')

  %   line = fgetl(stdin)
  %   line = fgetl(stdin)
  %   line = fgetl(stdin)
  %   [header_type,header_value,attrib] = parseline(line)
  %   line = fgetl(stdin)
  %   line = fgetl(stdin)
  %   self.params{end+1} = attrib.name;
  %   self.vals{end+1} = line;

  %   self.query_string = '';
    
  else     
    error('unsupported content_type %s',content_type);
  end
  %fprintf(stderr,'query_string "%s" "%s" "%d"',self.query_string,content_type,content_length);
else
  error('unsupported requested method %s',self.request_method);
end


% split at & and ;
p = strsplit(self.query_string,{'&',';'});

for i=1:length(p)
  pp = strsplit(p{i},'=');

  if length(pp) == 2
    self.params{end+1} = unquote(pp{1});
    self.vals{end+1} = unquote(pp{2});
  end
end


retval = class(self,'cgi');

% replace strings like 'abc%20def' to 'abc def'
function uq = unquote(s)

% replace + by space
s = strrep(s,'+',' ');

% decode percent sign + hex value
uq = '';
i = 1;
while i <= length(s)
  if strcmp(s(i),'%')
    uq = [uq char(hex2dec(s(i+1:i+2)))];
    i = i+3;
  else
    uq = [uq s(i)];
    i = i+1;
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
