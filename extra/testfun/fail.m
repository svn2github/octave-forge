## fail (code,pattern)
##    Return true if code fails with an error message matching pattern,
##    otherwise produce an error.  If code runs successfully, the error
##    produced is:
##           expected error but got none  
##    If the code fails with a different error, them message produced is:
##           expected <pattern>
##           but got <text of actual error>
##    The angle brackets are not part of the output.

## This program is public domain
## Author: Paul Kienzle <pkienzle@users.sf.net>

## PKG_ADD mark_as_command fail
function ret=fail(code,pattern)
  if nargin < 1 || nargin > 2
    usage("fail('code' [, 'pattern'])");
  end

  ## allow assert(fail())
  if nargout, ret=1; end  

  ## don't test failure if evalin doesn't exist
  if !exist('evalin'), return; end

  ## perform the test
  try
    evalin("caller",[code,";"]);
    msg = "expected error but got none";
  catch
    err=lasterr;
    ## allow fail('code')
    if nargin<2 || isempty(pattern), return; end
    msg = sprintf("expected message <%s>\nbut got <%s>",pattern,err(1:end-1));
    if !isempty(regexp(pattern,err(1:end-1))), return; end
  end

  ## if we get here, then code didn't fail or error didn't match
  error(msg);
end

%!shared a
%! a = [1,2];
%!test fail ('a*[2,3]','nonconformant')
%!test fail ("fail('a*[2;3]','nonconformant')","expected error but got none")
%!test fail ("fail('a*[2,3]','usage:')","expected .*usage:.*but got.*nonconformant")

## Comment out the following tests if you don't want to see what
## errors look like
% !test fail('a*[2;3]','nonconformant')
% !test fail('a*[2,3]','usage:')
