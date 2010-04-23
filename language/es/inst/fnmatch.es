md5="46763fcc66210450c07f83cb6714eafa";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} fnmatch (@var{pattern}, @var{string})
Retorna 1 para cada elemento de @var{string} que coincide con cualquira de 
los elementos del arreglo cadena @var{pattern}, usando las reglas del 
emparejamiento de patronos de nombres de archivos. Por ejemplo, 

@example
@group
fnmatch ("a*b", @{"ab"; "axyzb"; "xyzab"@})
     @result{} [ 1; 1; 0 ]
@end group
@end example
@end deftypefn
