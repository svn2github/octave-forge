## s = vrml_Box (sz) - Box { ... } node
##
## If sz is not given, returns Box { }
## If sz has size 1, returns   Box { <sz> <sz> <sz> }
## If sz has size 3, returns   Box { <sz(1)> <sz(2)> <sz(3)> }
function s = vrml_Box (sz)

if nargin < 1,       sz = []; end
if length (sz) == 1, sz = sz * [1 1 1]; end
if !isempty (sz)
  assert (numel (sz) == 3);
  ssz = sprintf ("\n  size %f %f %f\n",sz);
else
  ssz = "";
end

s = ["Box {",ssz,"}\n"];

