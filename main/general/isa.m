## isa(f,'class')
##   Test if f is a value from a particular class.  Common
##   classes are cell, double, sparse, char and struct.

## Author: Paul Kienzle
## This program is granted to the public domain
function b = isa(f,t)
  b = strcmp(class(f),t);
