##        s = vrml_points(x,options)
## 
## x : 3xP  : 3D points
##
## Makes a vrml2 "point [ ... ]" node from a 3xP matrix x.
## 
## Options :
##
## "name", name : The Coordinate node will be called name
##                (default="allpoints").
## "hide"       : The points will be defined, but not showed.
##
## "balls"      : Displays spheres rather than points. Overrides the
##                "hide" options and no Coordinate node is defined;makes
##                "name" ineffective.
##
## "boxes" or
## "cubes"      : Displays cubes rather than points. Overrides the "hide"
##                options and no Coordinate node is defined;makes "name"
##                ineffective. 
##
## "rad",  rad  : radius of balls/size of cubes                default = 0.1
##
## "nums"       : Displays numbers rather than points. Overrides the
##                "hide" options and no Coordinate node is defined;
##                makes "name" ineffective.
##
##       WARNING : This option seems to make freewrl 0.34 hang, so that it
##                 is necessary to kill it (do vrml_browse ("-kill")). Other
##                 browsers can can view the code produced by this option.
##
##  "col", 3x1  : Points will have RGB col.          default = [0.3,0.4,0.9]
##      or 3xP  : The color of each point.
##  "tran", 1x1 : Transparency                                   default = 0
##  "emit", e   : Use or not emissiveColor                       default = 1

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

## pre 2.1.39 function s = vrml_points(x,...)
function s = vrml_points(x,varargin) ## pos 2.1.39
## varargin
hide = 0;
cubes = balls = nums = 0;
rad = 0.1 ;
name = "allpoints" ;
col = [0.3 0.4 0.9];
emit = 1;
tran = 0;

i = 1; nargin--;		# pos 2.1.39

## pre 2.1.39 while --nargin,
while i < nargin ## pos 2.1.39
  ## pre 2.1.39   tmp = va_arg(); 
  tmp = nth (varargin,i++);  ## pos 2.1.39
  if strcmp(tmp,"hide") ,
    hide = 1;
  elseif strcmp(tmp,"balls") ,
    balls = 1;
  elseif strcmp(tmp,"cubes") || strcmp(tmp,"boxes") ,
    cubes = 1;
  elseif strcmp(tmp,"rad") ,
    ## pre 2.1.39     rad = va_arg() ; nargin-- ;
    rad = nth (varargin,i++); ## pos 2.1.39
  elseif strcmp(tmp,"nums") ,
    nums = 1;
  elseif strcmp(tmp,"emit") ,
    ## pre 2.1.39     emit = va_arg() ; nargin-- ;
    emit = nth (varargin,i++); ## pos 2.1.39
  elseif strcmp(tmp,"col") ,
    ## pre 2.1.39     col = va_arg() ; nargin-- ;
    col = nth (varargin,i++); ## pos 2.1.39
  elseif strcmp(tmp,"name") ,
    ## pre 2.1.39     name = va_arg() ; nargin-- ;
    name = nth (varargin,i++); ## pos 2.1.39
  elseif strcmp(tmp,"tran") ,
    tran = nth (varargin,i++);
  end
end

if rows (x) != 3,
  if columns (x) == 3,
    x = x' ;
  else
    error ("vrml_points : input is neither 3xP or Px3\n");
    ## keyboard
  end
end
P = columns (x) ;
				# Produce a PointSet
if !balls && !cubes && !nums,

  if prod (size (col)) == 3*P	# One color per point
    smat = "";
    scol = sprintf ("  color Color { color [\n   %s]\n   }\n",\
		    sprintf ("      %8.3f %8.3f %8.3f\n", col));
  else				# One color
    smat = ["  appearance Appearance {\n",\
	    vrml_material (col, emit),"\n",\
	    "  }\n"];
    scol = "";
  end

  s = sprintf(["Shape {\n",\
	       smat,\
	       "  geometry PointSet {\n",\
	       scol,\
	       "  coord DEF %s Coordinate {\n  point [\n  " ],name); # ] 
  
  
  s0 = sprintf("%10.6g %10.6g %10.6g ,\n  ",x);
  
  s = sprintf("%s%s]\n  }\n  }\n  }\n",s,s0); # [
  
  if hide ,
    s = sprintf(["Switch {\nchoice\n[\n",s,"\n]\n}"]);
  end
elseif nums,
  s = "";
  if prod (size (col)) == 3, col = col(:) * ones (1,P); end
  for i = 1:P,
    s0 = sprintf([\
		  "Transform {\n",\
		  "  translation %10.6g %10.6g %10.6g\n",\
		  "  children [\n",\ # ]
		  "    Billboard {\n",\
		  "      children [\n",\ # ]
		  "        Shape {\n",\
		  "          appearance Appearance {\n",\
		  vrml_material (col(:,i), emit, tran),"\n",\
		  "          }\n",\
		  "          geometry Text {\n",\
		  "            string \"%s\"\n",\
		  "            fontStyle FontStyle { size 0.25 }\n",\
		  "          }\n",\
		  "        }\n",\
		  "      ]\n",\
		  "    }\n",\
		  "  ]\n",\
		  "}\n"],\ # [
		 x(:,i),sprintf("%d",i-1));
		 ## x(:,i),col,col,sprintf("%d",i-1));
    ## "              emissiveColor %8.3f %8.3f %8.3f\n",\
    ## "      axisOfRotation 0.0 0.0 0.0\n",\ 

    s = sprintf("%s%s",s,s0);
  end
else
  if balls, shape = sprintf("Sphere { radius %8.3f}",rad) ; 
  else      shape = sprintf("Box { size %8.3f %8.3f %8.3f}",rad,rad,rad) ;
  end
  if prod (size (col)) == 3, col = col(:) * ones (1,P); end
  s = "";
  for i = 1:P,
    s0 = sprintf([\
		  "Transform {\n",\
		  "  translation %10.6g %10.6g %10.6g\n",\
		  "  children [\n",\ # ]
		  "    Shape {\n",\
		  "      appearance Appearance {\n",\
		  vrml_material (col(:,i), emit),"\n",\
		  "      }\n",\
		  "      geometry %s\n",\
		  "    }\n",\
		  "  ]\n",\
		  "}\n"],\
		 x(:,i), shape);
    ## "          emissiveColor %8.3f %8.3f %8.3f\n",\
    ##		 x(:,i),col,col,shape);
    s = sprintf("%s%s",s,s0);
  end
end
