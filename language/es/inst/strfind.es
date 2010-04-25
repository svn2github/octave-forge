md5="605dbacf3f2d6d5abbdce5230488619a";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{idx} =} strfind (@var{str}, @var{pattern})
@deftypefnx {Archivo de función} {@var{idx} =} strfind (@var{cellstr}, @var{pattern})

Busca el patrón @var{pattern} en la cadena @var{str} y retorna el 
índice inicial de cada aparición en el vector @var{idx}. Si no 
se encuentra, o si @var{pattern} es más largo que @var{str}, entonces 
@var{idx} es una cadena vacia @code{[]}.

Si se especifica el arreglo de celdas de cadenas @var{cellstr} en lugar de la 
cadena @var{str}, entonces @var{idx} es un arreglo de celdas de vectores, como 
se especificó anteriormente.

@seealso{findstr, strmatch, strcmp, strncmp, strcmpi, strncmpi}
@end deftypefn
