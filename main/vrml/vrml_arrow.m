## s = vrml_arrow (sz, col)     - Arrow pointing in "y" direction
##
## INPUT :
## -------
## Arguments are optional. NaN's are replaced by default values.
##                                                         <default>
## sz = [len, alen, dc, dr] has size 1, 2, 3 or 4, where
##
##   len  : total length                                   <1>
##   alen : length of arrow/total length                   <len/4>
##   dc   : Diameter of cone base/total length             <len/16>
##   dr   : Diameter of rod/total length                   <min(dc, len/32)>
##
## col    : 3 or 3x2 : Color of body and cone              <[0.3 0.4 0.9]>
##
## OUTPUT :
## --------
## s      : string   : vrml representation of an arrow (a rod and a cone)

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>

function v = vrml_arrow (sz, col, emit)

if nargin < 3, emit = 1; end

if nargin<2  || isempty (col),    col = [0.3 0.4 0.9;0.3 0.4 0.9];
elseif prod (size (col)) == 3,    col = [1;1]*col(:)';
elseif all (size (col) == [3,2]), col = col';
elseif any (size (col) != [2,3]),
  error("vrml_arrow : col has size %dx%d (should be 3 or 3x2)\n",size(col));
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
  error ("vrml_arrow : sz has size %dx%d. (should be in 1-4)\n", size(sz));
  ## keyboard
end
if any (tmp = isnan(sz)), sz(find (tmp)) = s0(find (tmp)) ; end
sz .*= [1, sz([1 1 1])]; 

				# Do material nodes
smat1 = vrml_material (col(:,1), emit);
smat2 = vrml_material (col(:,2), emit);

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
