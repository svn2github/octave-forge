## save_vrml(outname,[options],s1,...)    - Save vrml code
## 
## Makes a vrml2 file from strings of vrml code. A "background" node is
## added.
## 
## Options :
## "nobg"
## "nolight"
## 
## Bugs :
## - "outname" should not contain the substring ".wrl" anywhere else
##   than as a suffix.
## - "outname" should only contain the character ">" as ">>" at the
##   beginning , to indicate append rather than overwriting the
##   file.

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002


function save_vrml(outname, varargin)

verbose = 0;
append = 0;

if ! isstr(outname) ,
  error "save_vrml wants a string as first arg"
end

if strcmp(outname(1:2),">>"),
  append = 1;
end
outname = strrep(outname,">","");

outname = strrep(outname,".wrl",'');			# No suffix.

fname = sprintf("%s.wrl",outname);			# Add suffix.
bg_col = [0.4 0.4 0.7];
## bg_col = [1 1 1];
l_intensity = 0.3 ;
l_ambientIntensity = 0.5 ;
l_direction = [0.57735  -0.57735   0.57735] ;

bg_node = sprintf (["Background {\n",...
		    "  skyColor    %8.3g %8.3g %8.3g\n",...
		    "}\n"],\
		   bg_col);
bg_node = "";

lightstr = sprintf (["PointLight {\n",\
		     "  intensity         %8.3g\n",\
		     "  ambientIntensity  %8.3g\n",\
		     "  direction         %8.3g %8.3g %8.3g\n",\
		     "}\n"],\
		    l_intensity, l_ambientIntensity, l_direction);
lightstr = "";

				# Read eventual options
ninit = nargin;


i = 1;
while --nargin,

  tmp = nth (varargin, i++);
  if     strcmp (tmp, "nobg"),
    bg_node = "";
  elseif strcmp (tmp, "nolight"),
    lightstr = "";
  else				# Reached non-options
    ## beginpre 2.1.39
    # va_start ();
    # n = ++nargin ;
    # while n++ < ninit, va_arg (); end
    ## nargin, ninit
    ## endpre 2.1.39
    i--; 			# pos 2.1.39
    break;
  end
end
bg_node = [bg_node, lightstr];
## No path.
if findstr(outname,"/"),
  outname = outname(max(findstr(outname,"/"))+1:size(outname,2)) ;
end

if append, fid = fopen(fname,"a");		# Saving.
else       fid = fopen(fname,"w"); 
end ;

if fid == -1 , error(sprintf("save_vrml : unable to open %s",fname)); end
 
## Put header.
fprintf(fid,"#VRML V2.0 utf8 \n# %s , created by save_vrml.m on %s \n%s",
	fname,datestr(now),bg_node);

while i <= length (varargin) ,

  if verbose, printf ("save_vrml : %i'th string\n",i); end

  fprintf (fid,"%s", nth (varargin, i)) ;
  i++ ;
end

fprintf(fid,"\n");
fclose(fid);
