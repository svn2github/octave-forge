## v = vrml_group (s1, s2 ... ) - Form a group node with children s1,...
## 
##
## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function v = vrml_group ( varargin )

nargin = nargin();
if nargin == 0, return end

s = "";

				# beginpre 2.1.38
# if (nargin > 0) 
#   varargin = list(varargin, all_va_args); 
# end
				# endpre 2.1.38
if nargin > 0, s = nth (varargin, 1); end
if nargin > 1
  for i = 2:nargin, s = [s,",\n", nth(varargin, i)]; end
end
## indent s
ni = 4;
s = [blanks(ni), strrep(s,"\n",["\n",blanks(ni)])(:)'];

v = sprintf (["Group {\n",\
              "  children [\n",\
	      "%s",\
              " ]\n",\
	      "}\n"],\
	     s);
