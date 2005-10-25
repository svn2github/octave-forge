## fail (code, pattern)
##    Return true if code fails with an error message matching pattern,
##    otherwise produce an error.  If code runs successfully, the error
##    produced is:
##           expected error but got none  
##    If the code fails with a different error, them message produced is:
##           expected <pattern>
##           but got <text of actual error>
##    The angle brackets are not part of the output.
##
## fail (code, 'warning', pattern)
##    Similar to fail(code,pattern), but produces an error if no warning
##    is given during code execution or if the code fails.

## This program is public domain
## Author: Paul Kienzle <pkienzle@users.sf.net>

## PKG_ADD mark_as_command fail
function ret=fail(code,pattern,warning_pattern)
  if nargin < 1 || nargin > 3
    usage("fail(code [, 'warning'] [, pattern])");
  end

  ## sort out arguments
  test_warning =  (nargin > 1 && strcmp(pattern,'warning'));
  if nargin == 3
    pattern = warning_pattern;
  elseif nargin == 1 || (nargin==2 && test_warning)
    pattern = "";
  end
  if isempty(pattern), pattern = "."; end  # match any nonempty message

  ## allow assert(fail())
  if nargout, ret=1; end  

  ## don't test failure if evalin doesn't exist
  if !exist('evalin') || !exist('lastwarn'), return; end

  if test_warning
    ## perform the warning test
    lastwarn("");  # clear old warnings
    state = warning('on'); # make sure warnings are turned on
    try
      ## printf("lastwarn before %s: %s\n",code,lastwarn);
      evalin("caller",[code,";"]);
      ## printf("lastwarn after %s: %s\n",code,lastwarn);
      err = lastwarn;  # retrieve new warnings
      warning(state);
      if isempty(err), 
        msg = sprintf("expected warning <%s> but got none", pattern); 
      else
        err([1:9,end]) = [];  # transform "warning: ...\n" to "..."
        if !isempty(regexp(pattern,err)), return; end
        msg = sprintf("expected warning <%s>\nbut got <%s>", pattern,err);
      end
    catch
      warning(state);
      err = lasterr;
      err([1:7,end]) = [];  # transform "error: ...\n", to "..."
      msg = sprintf("expected warning <%s> but got error <%s>", pattern, err);
    end
      
  else
    ## perform the error test
    try
      evalin("caller",[code,";"]);
      msg = sprintf("expected error <%s> but got none", pattern);
    catch
      err=lasterr;
      err([1:7,end]) = []; # transform "error: ...\n", to "..."
      if !isempty(regexp(pattern,err)), return; end
      msg = sprintf("expected error <%s>\nbut got <%s>",pattern,err);
    end
  end

  ## if we get here, then code didn't fail or error didn't match
  error(msg);
end

%!fail ('[1,2]*[2,3]','nonconformant')
%!fail ("fail('[1,2]*[2;3]','nonconformant')","expected error <nonconformant> but got none")
%!fail ("fail('[1,2]*[2,3]','usage:')","expected error <usage:>\nbut got.*nonconformant")
%!fail ("warning('test warning')",'warning','test warning');

%!# fail ("warning('next test')",'warning','next test');  ## only allowed one warning test?!?

## Comment out the following tests if you don't want to see what
## errors look like
% !fail ('a*[2;3]', 'nonconformant')
% !fail ('a*[2,3]', 'usage:')
% !fail ("warning('warning failure')", 'warning', 'success')
