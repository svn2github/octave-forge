## n = vrml_newname (root)      - A name for a vrml node, starting by root
## 
## vrml_newname ("-clear")
function n = vrml_newname (root)

static vrml_namespace = struct();

if nargin < 1, root = ""; end

if strcmp (root, "-clear"),
  vrml_namespace = struct ();
  return
end
if isempty (root), root = "N"; end

n = sprintf ([root,"%0d"],100000*rand());
while struct_contains (vrml_namespace, n)
  n = sprintf ([root,"%0d"],100000*rand());
end
endfunction

