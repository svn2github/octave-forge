## s = vrml_Sphere (radius) - VRML code for a sphere 
function s = vrml_Sphere (sz)

if nargin < 1,       sz = []; end

if !isempty (sz)
  assert (numel (sz) == 1);
  ssz = sprintf ("\n  radius %f\n",sz);
else
  ssz = "";
end

s = ["Sphere {",ssz,"}\n"];

