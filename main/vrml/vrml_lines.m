## s = vrml_lines(x,f,...)
##
## x : 3xP   : The 3D points
## f : 3xQ   : The indexes of the points forming the lines. Indexes
##             should be in 1:P.
##
## Returns a Shape -> IndexedLineSet vrml node.
##
## No check is done on anything
##
## Options :
## 
## "col" , col  : 3x1 : Color, default = [1,0,0]
##

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

## pre 2.1.39 function s = vrml_lines(x,f,...)
function s = vrml_lines(x,f,varargin) ## pos 2.1.39

col = [1, 0, 0] ;

opt1 = " col " ;
opt0 = " " ;

verbose = 0 ;

nargin -= 2 ;
i=1;
## pre 2.1.39 while nargin>0 ,
while nargin>=i , ## pos 2.1.39
  ## pre 2.1.39   tmp = va_arg() ; nargin-- ;
  tmp = nth (varagin, i++) ;	# pos 2.1.39
  if ! isstr(tmp) ,
    error ("vrml_lines : Non-string option : \n") ;
    ## keyboard

  end
  if index(opt1,[" ",tmp," "]) ,
    
    ## pre 2.1.39     tmp2 = va_arg() ; nargin-- ;
    tmp2 = nth (varargin, i++); # pos 2.1.39
    ## nargin-- ;
    eval([tmp,"=tmp2;"]) ;

    if verbose , printf ("vrml_lines : Read option : %s.\n",tmp); end

  elseif index(opt0,[" ",tmp," "]) ,
    
    eval([tmp,"=1;"]) ;
    if verbose , printf ("vrml_lines : Read boolean option : %s\n",tmp); end

  else
    error ("vrml_lines : Unknown option : %s\n",tmp) ;
    ## keyboard
  end
endwhile

if exist("col")!=1,  col = [0.5, 0.5, 0.8]; end

s = sprintf([... 			# string of indexed face set
	     "Shape {\n",...
	     "  appearance Appearance {\n",...
	     "    material Material {\n",...
	     "      diffuseColor %8.3f %8.3f %8.3f \n",...
	     "      emissiveColor %8.3f %8.3f %8.3f\n",...
	     "    }\n",...
	     "  }\n",...
	     "  geometry IndexedLineSet {\n",...
	     "    coordIndex [\n%s]\n",...
	     "    coord Coordinate {\n",...
	     "      point [\n%s]\n",...
	     "    }\n",...
	     "  }\n",...
	     "}\n",...
	     ],...
	    col,col,...
	    sprintf("                    %4d, %4d, %4d, -1,\n",f-1),...
	    sprintf("                 %8.3f %8.3f %8.3f,\n",x)) ;


