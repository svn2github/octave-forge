md5="d117d7cd582c5d8bd48998b2b4c21021";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} strncmpi (@var{s1}, @var{s2}, @var{n})
Ignorando may@'usculas y min@'usculas, devuelve 1 si los primeros @var{n}
caracteres de las cadenas de caracteres @var{s1} y  @var{s2} son los
mismos, y 0 en el caso contrario.

Si bien @var{s1} o @var{s2} es un arreglo de cadenas, entonces un arreglo
del mismo tama@~{n}o es devuelto, conteniendo los valores descritos
anteriormente para cada miembro del arreglo. El otro argumento tambi@'en
puede ser una arreglo de cadenas (del mismo tama@~{n}o o con un solo
elemento), matriz char o string.

@strong{Precauci@'on:} Para la compatibilidad @sc{Matlab},la funci@'on  
Octave strncmpi devuelve 1 si las cadenas de caracteres son iguales,
y 0 en caso contrario. Esto es justo lo contrario de la funci@'on C 
correspondiente de la libreria.
@seealso{strcmp, strcmpi, strncmp}
@end deftypefn