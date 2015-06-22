CGI = cgi(); 
assert(strcmp(getfirst(CGI,'submit-name'),'Larry')); 
disp('All tests passed');