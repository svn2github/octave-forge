## s = slurp_file (f) - return a whole text file as a string
##
## f : string : filename
## s : string : contents of the file
##
## If f is not an absolute filename, and f is not an immediately accessible
## file, slurp_file () will look for f in LOADPATH.

## Author  : Etienne Grossmann <etienne@isr.ist.utl.pt>
function s = slurp_file (f)

if ! isstr (f),  error ("slurp_file :  f  is not a string"); end
if isempty (f), error ("slurp_file :  f  is empty"); end

s = "";

f0 = f;
[st,err,msg] = stat (f);
if err && f(1) != "/", 
  f = file_in_path (LOADPATH, f);
				# Could not find it anywhere. Open will
				# fail.
  if isempty (f)
    f = f0;
    error ("slurp_file : Can't find '%s' anywhere",f0);
  end
end

## I'll even get decent error messages!
s = system (sprintf ("cat %s",f), 1);
