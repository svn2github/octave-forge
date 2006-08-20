## Copyright (C) 2002 Etienne Grossmann.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## This is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##

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

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: Setembro 2002


function s = vrml_text(t,varargin)

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

  s = read_options (varargin{:}, "op1",op1,"op0",op0, "default",df);
  col=       s.col;
  size=      s.size;
  family=    s.family;
  justify=   s.justify;
  style=     s.style;
  verbose=   s.verbose;
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

endfunction

