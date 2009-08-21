md5="80576b2135bed98cdde82f277176b2db";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{T} =} delaunayn (@var{P})
@deftypefnx {Archivo de funci@'on} {@var{T} =} delaunayn (@var{P}, @var{opt})
Forma la triangulaci@'on de Delaunay para un conjunto de puntos.
La triangulaci@'on de Delaunay es una tesselaci@'on de la envolvente convexa de los 
puntos tal que ninguna n-esfera definida por el n-tri@'angulo contiene
cualquier otro punto del conjunto.

La matriz de entrada @var{P} de tama@~{n}o @code{[n, dim]} contiene @var{n}
puntos en un espacio de dimensi@'on @var{dim}. La matriz retornada @var{T} 
tiene el tama@~{n}o @code{[m, dim+1]}. Esta contiene por cada fila un conjunto 
de @'indices a los puntos, los cuales describen un simplificaci'on de dimensi@'on 
@var{dim}. Por ejemplo, una simplificaci'on 2d es un tri@'angulo y una 
simplificaci'on 3d es un tetrahedro.

Las opciones adicionales para el comando subyasciente qhull pueden ser especificadas por
el segundo argumento. Este argumento es un arreglo de celdas de cadenas. La opci@'on 
predetermianda depende en la dimensi@'on de la entrada: 

@itemize 
@item  2D y 3D: @var{opt} = @code{@{"Qt", "Qbb", "Qc"@}}
@item  4D y higher: @var{opt} = @code{@{"Qt", "Qbb", "Qc", "Qz"@}} 
@end itemize

Si @var{opt} es [], se usan los argumentos predetermiandos. Si @var{opt}
es @code{@{"@w{}"@}}, ninguno de los argumentos predeterminados es usado por qhull. 
V@'ease la documentaci@'on de Qhull acerca de las opciones disponibles. 

Todas las opciones puede ser especificadas como una cadena sencilla, por ejemplo 
@code{"Qt Qbb Qc Qz"}.

@end deftypefn
