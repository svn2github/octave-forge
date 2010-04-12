md5="0611e633c011b1bed3176fc22527728c";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} strncmp (@var{s1}, @var{s2}, @var{n})
Regresa 1 si los primeros @var{n} caracteres de las cadenas @var{s1} y @var{s2}
son las mismas, y 0 en caso contrario.

@example
@group
strncmp ("abce", "abcd", 3)
     @result{} 1
@end group
@end example

Si bien @var{s1} o @var{s2} es una matriz de cadenas de caracteres,
entonces un arreglo del mismo tama@~{n}o se devuelve, y contiene los
valores descritos anteriormente para cada miembro de la matriz de 
cadena de caracteres. El otro argumento tambi@'en puede ser una matriz
de cadenas de caracteres (del mismo tama@~{n}o o con un solo elemento),
las matriz de caracteres char o string.

@example
@group
strncmp ("abce", @{"abcd", "bca", "abc"@}, 3)
     @result{} [1, 0, 1]
@end group
@end example

@strong{Preacaucion:} Para la compatibilidad con @sc{Matlab},la funci@'on
Octave strncmp devuelve 1 si las cadenas de caracteres son iguales, y 0 en
caso contrario. Esto es justo lo contrario de la funci@'on C correspondiente
a la biblioteca.
@seealso{strncmpi, strcmp, strcmpi}
@end deftypefn
