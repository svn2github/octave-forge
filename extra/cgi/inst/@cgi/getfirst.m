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
