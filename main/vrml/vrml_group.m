## v = vrml_group (s1, s2 ... ) - Form a group node with children s1,...
## 
##
## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function v = vrml_group ( ... )

if nargin == 0, return end

s = "";
if nargin--,
  s = va_arg (); 
  while nargin--,
    s = [s,",\n",va_arg ()];
  end
end

## indent s
ni = 4;
s = [blanks (ni), strrep (s,"\n",["\n",blanks(ni)])(:)'];

v = sprintf (["Group {\n",\
              "  children [\n",\
	      "%s",\
              " ]\n",\
	      "}\n"],\
	     s);
