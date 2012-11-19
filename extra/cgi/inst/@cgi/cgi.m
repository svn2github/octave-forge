% Create a CGI object to parse CGI query string.
% Only GET methods are currently handled.
% 
% CGI = cgi()
% Parameter can be return by:
% getfirst(CGI,name[,default])
% getlist(CGI,name)
% CGI.form.name
%
% The methods getfirst and getlist behave as the Python CGI functions

function retval = cgi()

self.query_string = getenv('QUERY_STRING');

self.params = {};
self.vals = {};

% should also split at ";"
p = strsplit(self.query_string,'&');

for i=1:length(p)
  pp = strsplit(p{i},'=');
  
  self.params{end+1} = unquote(pp{1});
  self.vals{end+1} = unquote(pp{2});
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
