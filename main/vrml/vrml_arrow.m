## s = vrml_arrow (sz, col)     - Arrow pointing in "y" direction
##
## s is vrml code representing an arrow consisting of a rod and a cone. 
##
## INPUT ----------- 
## Arguments are optional. NaN's are replaced by default values.
##
## sz = [len, rad, crlen crrad].
##   len    : Total length of arrow                           default=1
##   rad    : Radius of rod                                   default=len/24
##   crlen  : Length of cone relative to total length.        default=1/4
##   crrad  : Radius of cone relative to radius of rod.       default=1/12
## 
##
## sz = [len, alen, dc, dr] has size 1, 2, 3 or 4, where
##   len  : total length                         default : 1
##   alen : length of arrow/total length         default : 1/4
##   dc   : Diameter of cone base/total length   default : 1/12
##   dr   : Diameter of rod/total length         default : min(dc, sz(1)/24)
##
##   NaN's in sz will be replaced by default value.
##
## col    : 3 or 3x2 : Color of body and cone    default : [0.3 0.4 0.9]
##

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function v = vrml_arrow (sz, col, emit)

if nargin < 3, emit = 1; end

if nargin<2  || isempty (col),    col = [0.3 0.4 0.9;0.3 0.4 0.9];
elseif prod (size (col)) == 3,    col = [1;1]*col(:)';
elseif all (size (col) == [3,2]), col = col';
elseif any (size (col) != [2,3]),
  error ("vrml_arrow : col has size %d x %d. This won't do\n",size(col));
  ## keyboard
end
col = col' ;

s0 = [1, 1/4, 1/16, 1/32];
				# Get absolute size
if nargin<1 || isempty (sz) || isnan (sz),  sz = s0 ;

elseif length (sz) == 4,      sz = [sz(1),sz(2),sz(3),sz(4)];
elseif length (sz) == 3,      sz = [sz(1),sz(2),sz(3),s0(4)];
elseif length (sz) == 2,      sz = [sz(1),sz(2),s0(3),s0(4)];
elseif length (sz) == 1,      sz = [sz(1),s0(2),s0(3),s0(4)];
else 
  error ("vrml_arrow : sz has size %d x %d. This won't do\n",size(sz));
  ## keyboard
end
if any (tmp = isnan(sz)), sz(find (tmp)) = s0(find (tmp)) ; end
sz .*= [1, sz([1 1 1])]; 

				# Do material nodes
smat1 = vrml_material (col(1:3), emit);
smat2 = vrml_material (col(4:6), emit);

v = sprintf (["Group {\n",\
              "  children [\n",\
              "    Transform {\n",\
              "      translation  %8.3g %8.3g %8.3g\n",\
              "      children [\n",\
              "        Shape {\n",\
              "          appearance Appearance {\n",\
	      smat1,\
	      "          }\n"\
              "          geometry Cylinder {\n",\
	      "            radius %8.3g\n",\
	      "            height %8.3g\n",\
	      "          }\n",\
              "        }\n",\
              "      ]\n",\
              "    }\n",\
              "    Transform {\n",\
              "      translation  %8.3g %8.3g %8.3g\n",\
              "      children [\n",\
              "        Shape {\n",\
              "          appearance Appearance {\n",\
	      smat2,\
              "          }\n",\
              "          geometry Cone { \n",\
              "            bottomRadius  %8.3g \n",\
              "            height  %8.3g\n",\
              "          }\n",\
              "        }\n",\
              "      ]\n",\
              "    }\n",\
              "  ]\n",\
              "}\n"],\
	     [0,(sz(1)-sz(2))/2,0],\
	     sz(4),\
	     sz(1)-sz(2),\
	     [0,sz(2)/2+sz(1)-sz(2),0],\
	     sz(3),\
	     sz(2));
