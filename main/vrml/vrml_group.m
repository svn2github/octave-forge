## v = vrml_group (s1, s2 ... ) - Form a group node with children s1,...
## 
##
## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function v = vrml_group ( varargin )
## pre 2.1.39 function v = vrml_group ( ... )

if nargin == 0, return end

s = "";

				# beginpost 2.1.39
if nargin > 0, s = nth (varargin, 1); end
if nargin > 1
  for i = 2:nargin, s = [s,",\n", nth (varargin, i)]; end
end

				# beginpre 2.1.38
# if nargin--,
#   s = va_arg (); 
#   while nargin--,
#     s = [s,",\n",va_arg ()];
#   end
# end
				# endpre 2.1.38
## indent s
ni = 4;
s = [blanks (ni), strrep (s,"\n",["\n",blanks(ni)])(:)'];

v = sprintf (["Group {\n",\
              "  children [\n",\
	      "%s",\
              " ]\n",\
	      "}\n"],\
	     s);
