## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## SECS2D is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
##
## AUTHOR: Carlo de Falco <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{mesh}]} = Umsh2pdetool(@var{geometry})
##
## Constructs an unstructured 2D mesh making use of the free software gmsh. Gives as output the PDE-tool like mesh structure.
##
## Input:
## @itemize @minus
## @item @var{geometry}: name of the ".geo" file describing the 2D geometry. Required by gmsh to start the meshing operation.
## @end itemize
## For more information refer to gmsh manual, or gmsh site:
## 
## http://www.geuz.org/gmsh/
##
## Output: mesh basic structure, composed of the following fields
## @itemize @minus
## @item @var{p}: matrix with size 2 times number of mesh point. 
## @itemize @bullet
## @item 1st row: x-coordinates of the points.
## @item 2nd row: y-coordinates of the points.
## @end itemize
## @item @var{e}: matrix with size 7 times number of mesh border edges.
## @itemize @bullet
## @item 1st row: p-matrix column number of the first edge-vertex.
## @item 2nd row: p-matrix column number of the second edge-vertex.
## @item 3rd row: not initialized, only for compatibility with standard PDE-tool like mesh.
## @item 4th row: not initialized, only for compatibility with standard PDE-tool like mesh.
## @item 5th row: number of the geometrical border upon which the referred mesh edge is lying on.
## @item 6th row: number of the region to the right of the referred mesh edge.
## @item 7th row: number of the region to the left of the referred mesh edge.
## @end itemize
## @item @var{t}:
## @itemize @bullet
## @item 1st row: p-matrix column number of the first trg-vertex.
## @item 2nd row: p-matrix column number of the second trg-vertex.
## @item 3rd row: p-matrix column number of the third trg-vertex.
## @item 4th row: number of the region upon which the referred trg is lying on.
## @end itemize
## @end itemize 
##
## @end deftypefn

function msh = Umsh2pdetool(filename);

awk_command = "BEGIN {  filename = ARGV[1] ; gsub(/\\./,""_"",filename) }\n\
\n\
/\\$NOD/,/\\$ENDNOD/ { \n\
    if ( FNR>2 ) \n\
    {  \n\
	if($0 ~ /^[^\\$]/  )  \n\
	{\n\
	    print ""p ( "" $1 "" ,:) = ["" $2 "" ""  $3""];""  > filename ""_p.m"" \n\
	}\n\
    } \n\
} \n\
\n\
/\\$ELM/,/\\$ENDNELM/ { \n\
    if (  $1 ~ /\\$ELM/   )\n\
    {\n\
	gsub(/\\$ELM/,""t=["")\n\
	print > filename ""_t.m""\n\
	gsub(/t=\\[/,""e=["")\n\
	print > filename ""_e.m""\n\
\n\
    } else if  ($1 ~ /\\$ENDELM/ ){\n\
		gsub(/\\$ENDELM/,""];"")\n\
		print > filename ""_t.m""\n\
		print > filename ""_e.m""\n\
    }\n\
    else if ( $2 == ""2"" )\n\
    {\n\
	print ( $6 "" "" $7 "" "" $8 "" "" $4)  > filename ""_t.m"" \n\
    }\n\
    else if ( $2 == ""1"" )\n\
    {\n\
	print ( $6 "" "" $7 "" 0 0 "" $4 "" 0 0"")  > filename ""_e.m"" \n\
    }\n\
    else if ( $2 == ""9"" )\n\
    {\n\
     print ( $6 "" "" $7 "" "" $8 "" "" $9 "" "" $10 "" "" $11 "" "" \
	    $4)  > filename ""_t.m"" \n\
    }\n\
    else if ( $2 == ""8"" )\n\
    {\n\
     print ( $6 "" "" $7 "" "" $8 "" 0 "" $4)  > filename ""_e.m"" \n\
    }\n\
}\n\
\n\
{ }"

system(["awk '" awk_command "' " filename ".msh"]);
eval([ filename "_msh_p"]);
eval([ filename "_msh_e"]);
eval([ filename "_msh_t"]);


msh=struct("p",p',"t",t',"e",e');

endfunction