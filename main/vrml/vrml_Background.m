##  s = vrml_Background (...)   - Vrml Background node
##  
##  s is a string of the form :
##  ------------------------------------------------------------------
##  Background { 
##    skyColor          [0 0 0]
##    skyAngle          [0]   
##    groundColor       [0 0 0]   
##    groundangle       [0]   
##    backUrl           ""
##    bottomUrl         ""
##    frontUrl          ""
##    leftUrl           ""
##    rightUrl          ""
##    topUrl            ""
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

hash = struct(varargin{:});

opts = struct ("skyColor",         3,
	       "groundColor",      3,
               "skyAngle",         1,
	       "groundAngle",      1,
	       "backUrl",          0,
	       "bottomUrl",        0,
	       "frontUrl",         0,
	       "leftUrl",          0,
	       "rightUrl",         0,
	       "topUrl",           0);

body = "";
for [val,key] = hash,
  if struct_contains (opts, key)
    n = opts.(key);
    if (n == 0)
      if (ischar(val))
        body = [ body, sprintf('   %-20s   "%s"\n', key, val) ];
      else
        error ("vrml_Background: field '%s' expects string", key);
      endif
    elseif (n == 1)
      if (isscalar(val))
        body = [ body, sprintf('   %-20s   [ %8.3f ]\n', key, val) ];
      else
        error ("vrml_Background: field '%s' expects scalar", key);
      endif
    else
      if (isvector(val) && length(val) == 3)
        body = [body, sprintf('   %-20s   [ %8.3f %8.3f %8.3f ]\n', key, val)];
      else
        error ("vrml_Background: field '%s' expects [r g b]", key);
      endif
    endif
  else
    error ("vrml_Background : unknown field '%s'",key);
  end
end
s = sprintf ("Background { \n%s}\n", body);
