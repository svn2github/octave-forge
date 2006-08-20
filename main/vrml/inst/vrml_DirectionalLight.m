##  s = vrml_DirectionalLight (...)   - Vrml DirectionalLight node
##
##  s is a string of the form :
##  ------------------------------------------------------------------
##  DirectionalLight { 
##    exposedField SFFloat ambientIntensity  0        # [0,1]
##    exposedField SFColor color             1 1 1    # [0,1]
##    exposedField SFVec3f direction         0 0 -1   # (-,)
##    exposedField SFFloat intensity         1        # [0,1]
##    exposedField SFBool  on                TRUE 
##  }
##  ------------------------------------------------------------------
##
## Options :
## All the fields of the node
##
## See also : vrml_PointLight

function s = vrml_DirectionalLight (varargin) # pos 2.1.39


hash = struct ();		# pos 2.1.39


if nargin, hash = setfield(varargin{:}); end # pos 2.1.39
## hash = rmfield (hash, "dummy");

tpl = struct ("ambientIntensity", "%8.3f",\
	      "intensity",        "%8.3f",\
	      "direction",        "%8.3f",\
	      "on",               "%s",\
	      "color",            "%8.3f %8.3f %8.3f");

body = "";
for [val,key] = hash,

  if !(isnumeric(val) && isnan (val)),

				# Check validity of field
    if ! struct_contains (tpl, key)
      error (sprintf ("vrml_PointLight : unknown field '%s'",key));
    end

    body = [body,\
	    sprintf ("   %-20s   %s\n",key, 
		     sprintf (getfield (tpl,key), val))];
  end
end
s = sprintf ("DirectionalLight { \n%s}\n", body);
endfunction

