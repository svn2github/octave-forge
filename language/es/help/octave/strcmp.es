md5="2bb35b552641f2bf0d682e6092c4c7ca";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} strcmp (@var{s1}, @var{s2})
Retorna 1 si las cadena de caracteres @var{s1} y @var{s2} son iguales
y 0 si no lo son.

Si bien @var{s1} o @var{s2} es un arreglo de cadenas de caracteres,
entoces un arreglo de igual tama@~{n}o es devuelto, conteniendo los 
valores descritos anteriormente para cada miembro del arreglo de
caracteres. El otro argumento tambi@'en puede ser un arrego de cadena
de caracteres (de el mismo tama@~{n}o o con un solo elemento) matriz
de caracteres (char)  o cadenas de caracteres (string).

@strong{Precauci@'on:} Para compatibilidad con @sc{Matlab}, en Octave's
la funci@'on strcmp retorna 1 si las cadenas de caracteres son iguales,
y 0 si no lo son. Esto es justamente lo opuesto a la correspondiente 
funci@'on C en la libreria.
@seealso{strcmpi, strncmp, strncmpi}
@end deftypefn