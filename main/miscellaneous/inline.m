## [fname,fcode] = inline (str,arg1,...) - Define a function from a string
## [fname,fcode] = inline (str,n)
##
## INPUT : -----------
## str   : string    : String defining the result of the function.
##
## If the second and subsequent arguments are strings, they are the names of
## the arguments of the function.
##
## If the second argument is an integer N, the arguments are supposed to be
## "x","P1", ..., "PN".
##
## If one argument is passed, the function takes single argument called "x".
##
## OUTPUT : ----------
## fname : string    : Name of the new function, which can e.g. be called
##                     from the command line or with feval().
## fcode : string    : The code of the function.
##
## EXAMPLE : ---------
##
## fn = inline ("x.^2 + 1","x");
## feval (fn, 6)        
##   ans = 37
##
function [fname,fcode] = inline (str, n, varargin)

if nargin == 1			#  Single argument called "x"
  argstr = "x";
else				# "x", "P1", ... 
  if isnumeric(n)
    argstr = ["x,",sprintf ("P%i,",1:n)];

  else				# Arguments are given names.

    if ! isstr (n), error ("Expecting second argument to be a string"); end
    i = 3;
    while i <= nargin
      if ! isstr (nth (varargin,i-2)),
	error (sprintf ("Expecting %ith argument to be a string",i));
      end
      i++;
    end
    argstr = sprintf ("%s,",n,all_va_args);
  end
  argstr = argstr(1:length(argstr)-1);
end

## Choose a name (naive way : won't work zillions of times)
while 1
  fname = sprintf ("inline_func_%06i",floor (rand()*1e6));
  if ! exist (fname), break; end
end

fcode = sprintf (["function r = %s (%s)\n",\
		  "  r = ",str,";\n",\
		  "endfunction;"],\
		 fname, argstr);
eval (fcode);
endfunction		  