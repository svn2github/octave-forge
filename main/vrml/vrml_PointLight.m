##  s = vrml_PointLight (...)   - Vrml PointLight node
##  
##  s is a string of the form :
##  ------------------------------------------------------------------
##  PointLight { 
##    exposedField SFFloat ambientIntensity  0       ## [0,1]
##    exposedField SFVec3f attenuation       1 0 0   ## [0,inf)
##    exposedField SFColor color             1 1 1   ## [0,1]
##    exposedField SFFloat intensity         1       ## [0,1]
##    exposedField SFVec3f location          0 0 0   ## (-inf,inf)
##    exposedField SFBool  on                TRUE 
##    exposedField SFFloat radius            100     ## [0,inf)
##  }
##  ------------------------------------------------------------------
##
## Options :
## All the fields of the node
##
## Example : s = vrml_PointLight ("location",[0 0 1]);
##
## See also : vrml_DirectionalLight

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>

function s = vrml_PointLight (varargin)

  h = struct ();

  if nargin, h = leval ("setfield", varargin); end

tpl = struct ("ambientIntensity", "%8.3f",\
	      "intensity",        "%8.3f",\
	      "radius",           "%8.3f",\
	      "on",               "%s",\
	      "attenuation",      "%8.3f %8.3f %8.3f",\
	      "color",            "%8.3f %8.3f %8.3f",\
	      "location",         "%8.3f %8.3f %8.3f");

body = "";
for [val,key] = h,

    if strcmp (key, "DEF")
      continue;
    elseif !(isnumeric(val) && isnan (val))

				# Check validity of field
    if ! struct_contains (tpl, key)
      error (sprintf ("vrml_PointLight : unknown field '%s'",key));
    end


    body = [body,\
	    sprintf("   %-20s   %s\n",key, 
		    sprintf (getfield (tpl,key), val))];
  end
end
s = sprintf ("PointLight {\n%s}\n", body);
if struct_contains (h,"DEF") && !isempty (h.DEF)
  s = ["DEF ",h.DEF," ",s];
end 
