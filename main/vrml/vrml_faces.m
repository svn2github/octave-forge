## s = vrml_faces(x,f,...)
##
## x : 3xP   : The 3D points
## f : 3xQ   : The indexes of the points forming the faces. Indexes
##             should have values in 1:P.
##
## Returns a Shape -> IndexedFaceSet vrml node.
##
## No check is done on anything
##
## Options :
## 
## "col" , col  : 3   : Color,                      default = [0.3,0.4,0.9]
##             or 3xP : Color of vertices
##             or 3xQ : Color of facets   (use "colorPerVertex" below to
##                                         disambiguate the case P==Q).
## 
## "emit", em   : 3   : Emissive color of the surface
##              : 3XP : (same as color)
##              : 3xQ :
##              : 1   : Use color as emissive color too         default = 0
##
## "tran", tran : 1x1 : Transparency,                           default = 0
##
## "creaseAngle", a 
##              :  1  : vrml creaseAngle value. The browser may smoothe the
##                      crease between facets whose angle is less than a.
##                                                              default = 0
## "tex", texfile 
##              : string : Name of file containing texture.   default : none
##
## "imsz", sz   : 2   : Size of texture image 
##                                       default is determined by imginfo()
##
## "tcoord", tcoord
##              : 2x3Q : Coordinates of vertices in texture image. Each 2x3
##                       block contains coords of one facet's corners. The
##                       coordinates should be in [0,1], as in a VRML
##                       TextureCoordinate node.
##                                       default assumes faces are returned
##                                       by extex()
##
## "smooth"           : same as "creaseAngle",pi.
## "convex"
## "colorPerVertex", c: If 1, col specifies color of vertices. If 0,
##                       col specifies color of facets.         Default = 1
##
## "DEFcoord",n : string : DEF the coord VRML node with name n. Default = ''
## "DEFcol",  n : string : DEF the color VRML node with name n. Default = ''
##
## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>

function s = vrml_faces (x,f,varargin)

  ## mytic; starttime = cputime();

tran = 0 ;
col = [0.3, 0.4, 0.9] ;
emit = 0;
convex = tcoord = imsz = tex = smooth = creaseAngle = nan ;
colorPerVertex = nan;
DEFcol = DEFcoord = "";

## Read options ######################################################
opt1 = " tex DEFcoord DEFcol imsz tcoord tran col creaseAngle colorPerVertex emit " ;
opt0 = " smooth convex " ;

verbose = 0 ;

nargin -= 2 ;
i = 1;
while nargin>=i	
  tmp = nth (varargin, i++);
  if ! isstr(tmp) ,
    error ("vrml_faces : Non-string option : \n") ;
    ## keyboard
  end

  if index(opt1,[" ",tmp," "]) ,
    
    tmp2 = nth (varargin, i++) ;

    eval([tmp,"=tmp2;"]) ;

    if verbose , printf ("vrml_faces : Read option : %s.\n",tmp); end

  elseif index(opt0,[" ",tmp," "]) ,
    
    eval([tmp,"=1;"]) ;
    if verbose , printf ("vrml_faces : Read boolean option : %s\n",tmp); end

  else
    error ("vrml_faces : Unknown option : %s\n",tmp) ;
    ## keyboard
  end
endwhile
## printf ("  Options : %f\n",mytic()); ## Just for measuring time
## End of reading options ############################################

if !isempty (DEFcol), col_def_str = ["DEF ",DEFcol]; 
else                  col_def_str = ""; 
end



if ! isnan (smooth), creaseAngle = pi ; end

## printf ("creaseAngle = %8.3f\n",creaseAngle);

if is_list (f), nfaces = length (f); else nfaces = columns (f); end

if ! isnan (tcoord)

  col_str_1 = sprintf (["  appearance Appearance {\n",...
			"    texture ImageTexture {\n",...
			"      url \"%s\"\n",...
			"    }\n",...
			"  }\n"],...
		       tex);

  texcoord_point_str = sprintf ("    %8.5f %8.5f\n", tcoord);
  
  col_str_2 = sprintf (["  texCoord TextureCoordinate {\n",\
			"    point [\n      %s]\n",\
			"  }\n"\
			],\
		       texcoord_point_str\
		       );
  
				# If texture has been provided
elseif isstr (tex),		# Assume triangles

  ## printf ("Using texture\n");
		       
  col_str_1 = sprintf (["  appearance Appearance {\n",...
			"    texture ImageTexture {\n",...
			"      url \"%s\"\n",...
			"    }\n",...
			"  }\n"],...
		       tex);
		       
				# Eventually determine size of image
  if isnan(imsz), imsz = imginfo (tex); end

  if isnan (tcoord),

    nb = ceil (nfaces/2);	# n of blocks
    lo = [0:nb-1]/nb; hi = [1:nb]/nb;
    on = ones (1,nb); ze = zeros (1,nb);
    
    sm = (1/nb) /(imsz(2)+1);	
    tcoord = [lo; on; lo; ze; hi-sm; ze;  lo+sm; on; hi-sm; on; hi-sm; ze];
    tcoord = reshape (tcoord, 2, 6*nb);
    tcoord = tcoord (:,1:3*nfaces);
  end

  col_str_2 = sprintf (["  texCoord TextureCoordinate {\n",\
			"    point [\n      %s]\n",\
			"  }\n",\
			"  texCoordIndex [\n      %s]\n",\
			"  coordIndex [\n      %s]\n",\
			],\
		       sprintf ("%10.8f %10.8f,\n      ",tcoord),\
		       sprintf ("%-4d, %-4d, %-4d, -1,\n     ",0:3*nfaces-1),\
		       sprintf ("%-4d, %-4d, %-4d, -1,\n     ",f-1)
		       );
				
  
elseif prod (size (col))==3,	# One color has been specified for the whole
				# surface

  col_str_1 = ["  appearance Appearance {\n",...
	       vrml_material (col, emit, tran,DEFcol),\
	       "  }\n"];

  col_str_2 = "";
else
  ##  col_str_1 = sprintf(["  appearance Appearance {\n",...
  ##  		       "    material Material {\n",...
  ##  		       "      diffuseColor  0.3 0.4 0.9\n",...
  ##  		       "      emissiveColor  0.9 0.4 0.1\n",...
  ##  		       "    }\n",...
  ##  		       "  }\n"]);
  # col_str_1 = ["  appearance Appearance {\n",...
# 	       vrml_material (col, emit, tran),\
# 	       "  }\n"];
  if (emit)			# Color is emissive by default
    col_str_1 = "";

  else				# If there's a material node, it is not
				# emissive.
    col_str_1 = ["appearance Appearance {\n",\
		 "    material Material {}\n}\n"];
  end
  if isnan (colorPerVertex)
    if     prod (size (col)) == 3*columns (x), colorPerVertex = 1;
    elseif prod (size (col)) == 3*columns (f), colorPerVertex = 0;
    end
  end
  if colorPerVertex, cPVs = "TRUE"; else cPVs = "FALSE"; end

  col_str_2 = sprintf (["     colorPerVertex %s\n",\
			"     color %s Color {\n",\
			"       color [\n%s\n",\
			"       ]\n",\
			"     }"],\
		       cPVs,\
		       col_def_str,\
                       sprintf("         %8.3f %8.3f %8.3f,\n",col));
end

## printf ("  Colors  : %f\n",mytic()); ## Just for measuring time

etc_str = "" ;
if ! isnan (creaseAngle),
  etc_str = [etc_str, sprintf ("    creaseAngle    %8.3f\n",creaseAngle)];
end

				# Faces 
if is_list (f), nfaces = length (f); else nfaces = columns (f); end


tpl0 = sprintf ("%%%dd, ",floor (log10 (columns (x)))+1);
ltpl0 = length (tpl0);

ptsface = zeros (1,nfaces);

				# Determine total number of vertices, number
				# of vertices per face and indexes of
				# vertices of each face
if is_list (f)			

  npts = 0;
  for i = 1:length (f), npts += ptsface(i) = length (nth (f,i)); end
  ii = [0, cumsum (ptsface)]';
  all_indexes = zeros (1,npts);
  for i = 1:length (f), all_indexes(ii(i)+1:ii(i+1)) = nth (f,i) - 1; end
else

  npts = sum (ptsface = (sum (!! f)));
  all_indexes = nze (f) - 1;
end

if 1
				# Big string with template
tpl = setstr ((ones (npts+nfaces,1)*toascii (tpl0))'(:)');
				# Replace some of the %Xd's with "-1\n"

				# Positions of -1's 
jj = ltpl0 * cumsum (ptsface+1) - 4;
jj = [jj; jj+1; jj+2; jj+3; jj+4](:);
## size (jj)
## size (setstr (ones (nfaces,1)*toascii ("-1\n"))'(:)')
tpl(jj) = setstr (ones (nfaces,1)*toascii ("  -1\n"))'(:)';

coord_str = sprintf (tpl, all_indexes);

else
				# Determine length of faces's string
coord_str = blanks (ltpl0 * npts + (4+16) * nfaces);

## coord_str = "";

if isnan (convex), convex = 1; end
curpos = 1;
for i = 1:nfaces
  if is_list (f), fpts = nth (f, i)-1; else fpts = nze (f(:,i))-1; end
  fpts = fpts(:)';
  if convex && length (fpts) > 3, convex = 0; end
  template = setstr ((ones(length(fpts),1)*toascii (tpl0))'(:)');
  template = sprintf ("                %s -1\n",template);

  tmplen = length (tmp = sprintf (template, fpts));

  coord_str(curpos:curpos+tmplen-1) = tmp;
  curpos += tmplen;
end
end
## printf ("  Faces  : %f\n",mytic()); ## Just for measuring time

if ! convex, etc_str = [etc_str,"    convex FALSE\n"]; end

if !isempty (DEFcoord), coord_def_str = ["DEF ",DEFcoord]; 
else                    coord_def_str = ""; 
end

s = sprintf([... 			# string of indexed face set
	     "Shape {\n",...
	     col_str_1,...
	     "  geometry IndexedFaceSet {\n",...
	     "    solid FALSE     # Show back of faces too\n",...
	     col_str_2,...
	     etc_str,...
	     "    coordIndex [\n%s]\n",...
	     "    coord %s Coordinate {\n",...
	     "      point [\n%s]\n",...
	     "    }\n",...
	     "  }\n",...
	     "}\n",...
	     ],...
	    coord_str,...
	    coord_def_str,...
	    sprintf("                 %8.3f %8.3f %8.3f,\n",x)) ;
## printf ("  Assembly :  %f\n",mytic()); ## Just for measuring time
## printf ("Total Time : %f\n",cputime() - starttime);