##       v = vrml_transfo(s,t,r,c)
##  
## s : string of vrml code.
## t : 3      Translation                          default : [0,0,0]
## r : 3x3    Rotation matrix, or                  default : eye(3)
##     3      Scaled rotation axis.
## c : 3 or 1 Scale                                default : 1
##
## v : string v is s, enclosed in a Transform {} vrml node with
##     rotation, translation and scale params given by r, t and c.
##

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function v = vrml_transfo(s,t,r,c)

## Hint : if s is "%s", you may later do v2 = sprintf (v,s2) which should be
##        equal to  vrml_transfo (s2,etc)

verbose = 0 ;
## 

if nargin<2 || isnan (t), t = [0,0,0] ; end # Default translation
if nargin<3 || isnan (r), r = eye(3) ; end #  Default rotation
if nargin<4 || isnan (c), c = [1,1,1] ; end # Default scale
## if nargin<4, s = "%s" ; end

if prod(size(c))==1, c = [c,c,c]; end


if all(size(r)==3),
  [axis,ang] = rotparams(r) ;
elseif prod(size(r))==3,
  ang = norm(r);
  if abs(ang)>eps, 
    axis = r/ang;
  else
    axis = [0,1,0]; ang = 0;
  end
else
  error ("vrml_transfo : rotation should have size 3x3 or 3\n");
end
if verbose,
  printf (["vrml_transfo : %8.3f %8.3f %8.3f %8.3f\n",...
	   "               %8.3f %8.3f %8.3f\n"],...
	  axis,ang,t);
  printf ("length of string is %i\n",prod(size(s)));
end

				# Indent s by 4
if strcmp(s(prod(size(s))),"\n"), s = s(1:prod(size(s))-1) ; end
## strrep is slow, as if it copied everything by hand ...
#  mytic() ;
#  s = ["    ",strrep(s,"\n","\n    ")] ;
#  mytic()
if verbose, printf ("   done indenting s\n"); end

v = sprintf(["Transform {\n",...
	     "  rotation    %8.3f %8.3f %8.3f %8.3f\n",...
	     "  translation %8.3f %8.3f %8.3f\n",...
	     "  scale       %8.3f %8.3f %8.3f\n",...
	     "  children [\n%s\n",...
	     "           ]\n",...
	     "}\n",...
	     ],...
	    axis,ang,...
	    t,...
	    c,...
	    s) ;

