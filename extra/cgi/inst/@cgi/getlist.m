% vals = getlist(cgi,name)
% Return all CGI parameters with the given name.

function vals = getlist(cgi,name)

i = find(strcmp(cgi.params,name));
vals = cgi.vals(i);
