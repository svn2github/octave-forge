##  s = vrml_Background (...)   - Vrml Background node
##  
##  s is a string of the form :
##  ------------------------------------------------------------------
##  Background { 
##    exposedField MFColor  skyColor          0 0 0
##    exposedField MFFloat  skyAngle          []   
##    exposedField MFColor  groundColor       []   
##    exposedField MFFloat  groundangle       []   
##    exposedField MFString backUrl           []
##    exposedField MFString bottomUrl         []
##    exposedField MFString frontUrl          []
##    exposedField MFString leftUrl           []
##    exposedField MFString rightUrl          []
##    exposedField MFString topUrl            []
##  }
##  ------------------------------------------------------------------
##
## Options :
## All the fields of the node
##
## Example : s = vrml_Background ("skyColor",[0 0 1]);
##

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002


function s = vrml_Background (varargin)

hash.dummy = 0;


if nargin, hash = leval ("setfield", varargin); end
## hash = rmfield (hash, "dummy");

tpl1 = struct (\
	       "skyColor",         "%8.3f %8.3f %8.3f",\
	       "skyAngle",         "%8.3f",\
	       "groundColor",      "%8.3f %8.3f %8.3f",\
	       "groundAngle",      "%8.3f");

tpl2 = struct (\
	       "backUrl",          "%s",\
	       "bottomUrl",        "%s",\
	       "frontUrl",         "%s",\
	       "leftUrl",          "%s",\
	       "rightUrl",         "%s",\
	       "topUrl",           "%s");

body = "";
for [val,key] = hash,
				# Ignore dummy field
  if !strcmp (key, "dummy") && (!isnumeric (val) || !isnan (val)),

				# Check validity of field


				# Add numeric field
    if struct_contains (tpl1, key)

      body = [body,\
	      sprintf ("   %-20s   [ %s ]\n",key,\
		       sprintf (getfield (tpl1,key), val))];


				# Add string field
    elseif struct_contains (tpl2, key)

      body = [body,\
	      sprintf ("   %-20s   \"%s\"\n",key,\
		       sprintf (getfield (tpl2,key), val))];
    else
      error (sprintf ("vrml_Background : unknown field '%s'",key));
    end
				# Add field
  end
end
s = sprintf ("Background { \n%s}\n", body);
