md5="d117d7cd582c5d8bd48998b2b4c21021";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} strncmpi (@var{s1}, @var{s2}, @var{n})
Ignorando mayúsculas y minúsculas, devuelve 1 si los primeros @var{n}
caracteres de las cadenas de caracteres @var{s1} y  @var{s2} son los
mismos, y 0 en el caso contrario.

Si bien @var{s1} o @var{s2} es un arreglo de cadenas, entonces un arreglo
del mismo tama@~{n}o es devuelto, conteniendo los valores descritos
anteriormente para cada miembro del arreglo. El otro argumento también
puede ser una arreglo de cadenas (del mismo tama@~{n}o o con un solo
elemento), matriz char o string.

@strong{Precaución:} Para la compatibilidad @sc{Matlab},la función  
Octave strncmpi devuelve 1 si las cadenas de caracteres son iguales,
y 0 en caso contrario. Esto es justo lo contrario de la función C 
correspondiente de la libreria.
@seealso{strcmp, strcmpi, strncmp}
@end deftypefn