## Copyright (C) 2002 Etienne Grossmann.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##

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

## Author:        Etienne Grossmann <etienne@cs.uky.edu>

function s = vrml_PointLight (varargin)

if mod(nargin,2) != 0, usage("vrml_PointLight('key',val,...)"); end
h = struct (varargin{:});

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
