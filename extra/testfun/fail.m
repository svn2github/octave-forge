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
  try
    evalin("caller",[code,";"]);
    msg = "expected error but got none";
  catch
    msg = sprintf("expected %s\nbut got %s",pattern,lasterr);
    if !isempty(regexp(pattern,lasterr))
      if nargout, ret=1; end  # allow assert(fail())
      return
    end
  end
  error(msg);
end

%!shared a
%! a = [1,2];
%!test fail ('a*[2,3]','nonconformant')
%!test fail ("fail('a*[2;3]','nonconformant')","expected error but got none")
%!test fail ("fail('a*[2,3]','usage:')","expected usage:.*but got.*nonconformant")

## Comment out the following tests if you don't want to see what
## errors look like
% !test fail('a*[2;3]','nonconformant')
% !test fail('a*[2,3]','usage:')
