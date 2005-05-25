## Author: Paul Kienzle
## This program is public domain.
function tclsend(name, m)
  if isstr(m)
    send(name,m);
  else
    send(name,sprintf("%.15g ", m));
  endif
endfunction
