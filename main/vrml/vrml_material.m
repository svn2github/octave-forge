##  s = vrml_material (dc,ec,tr) - Returns a "material" vrml node
##

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function s = vrml_material (dc, ec, tran)

if nargin < 1, dc = [0.3 0.4 0.9] ; # Default color
elseif prod (size (dc)) != 3,
end

emit = 1;

if nargin < 2, ec = 0; end
if nargin < 3, tran = 0; end

if prod (size (ec)) == 1, emit = ec && !isnan (ec) ; ec = dc ; end


if emit
  se = sprintf ("              emissiveColor %8.3g %8.3g %8.3g\n",ec);
else
  se = "";
end
if tran && ! isnan (tran)
  st = sprintf ("              transparency %8.3g\n",tran);
else
  st = "";
end
  

s = sprintf (["            material Material {\n",\
	      se,st,\
	      "              diffuseColor  %8.3g %8.3g %8.3g \n",\
	      "          }\n"],\
	     dc);
