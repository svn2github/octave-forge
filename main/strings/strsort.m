# ... = strsort(...)
# Overloads the sort function to operate on strings.

# PKG_ADD dispatch sort strsort string
function [sorted,idx] = strsort(string,varargin)
  if nargout == 2
     [s,idx] = sort(toascii(string),varargin{:});
  else
    s = sort(toascii(string),varargin{:});
  endif
  sorted = setstr(s);
endfunction
