md5="bca85677e55709a64898956c1fdfa6a2";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} strcmpi (@var{s1}, @var{s2})
Haciendo caso omiso, retorna 1 si la cadena de caracteres @var{s1} y @var{s2}
son igulaes, y 0 si no lo son.

Si bien @var{s1} o @var{s2} son un arreglo de cadenas de caracteres, entonces un
arreglo de el mismo tama@~{n}o es regresado, conteniendo los valores descritos
antes para cada miembro del arreglo. el otro argumento tambi@'en puede ser un
arreglo de cadenas (de el mismo tama@~{n}o o con un s@'olo elemento), matriz de 
caracteres (char) o cadenas de caracteres (string) .

@strong{Precauci@'on:}  para compatibilidad con @sc{Matlab},la funci@'on strcmpi en 
Octave's  retorna 1 si las cadenas de caracteres son iguales, y 0 si no lo son.
esto es justamente lo opuesto a la correspondiente funci@'on en C de la libreria.
@seealso{strcmp, strncmp, strncmpi}
@end deftypefn