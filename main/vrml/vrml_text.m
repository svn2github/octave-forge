##       s = vrml_text(t,...) 
##
## Makes vrml Shape node representing string t
## 
## Options : 
##
## "col" , col             : default = [ 0.3 0.4 0.9 ]
## "size" , size           : default = 1.0
## "family", family        : default = "SERIF". 
##                           (could also be : "TYPEWRITER", "SANS")
## "style", style          : default = "PLAIN". 
##                           (could also be : "BOLD", "ITALIC", "BOLDITALIC")
## "justify", justify      : default = "MIDDLE"
##                           (could also be "FIRST", "BEGIN", "END")

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

## pre 2.1.39 function s = vrml_text(t,...) 
function s = vrml_text(t,varargin)  ## pos 2.1.39

col     = [0.3,0.4,0.9] ;
size    = 1.0 ;
family  = "SERIF" ;
justify = "MIDDLE" ;
style   = "PLAIN" ;
verbose = 0 ;

filename = "vrml_text" ;
if nargin > 1
  op1 = " col size family justify style " ;
  op0 = " verbose " ;

  df = tar (col, size, family, justify, style, verbose);
  ## pre 2.1.39   s = read_options (list (all_va_args), "op1",op1,"op0",op0, "default",df);
  s = read_options (varargin{:}, "op1",op1,"op0",op0, "default",df); ## pos 2.1.39
  [col,size,family,justify,style,verbose] = \
      getfield (s, "col","size","family","justify","style","verbose");
  ## nargin-- ;
  ## read_options_old 
end
s = sprintf (["Shape {\n",\
	      "  appearance Appearance {\n",\
	      "    material Material {\n",\
	      "      diffuseColor  %8.3f %8.3f %8.3f\n",\
	      "      emissiveColor %8.3f %8.3f %8.3f\n",\
	      "    }\n",\
	      "  }\n",\
	      "  geometry Text {\n",\
	      "    string \"%s\"\n"\
	      "    fontStyle FontStyle {\n",\
	      "      family  \"%s\"\n",\
	      "      justify \"%s\"\n",\
	      "      style   \"%s\"\n",\
	      "      size     %-8.3f\n",\
	      "    }\n",\
	      "  }\n",\
	      "}\n",\
	      ],\
	     col,\
	     col,\
	     t,\
	     family,\
	     justify,\
	     style,\
	     size\
	     );

