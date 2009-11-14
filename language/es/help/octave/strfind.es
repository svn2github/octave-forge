md5="605dbacf3f2d6d5abbdce5230488619a";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{idx} =} strfind (@var{str}, @var{pattern})
@deftypefnx {Archivo de funci@'on} {@var{idx} =} strfind (@var{cellstr}, @var{pattern})

Busca el patr@'on @var{pattern} en la cadena @var{str} y retorna el 
@'indice inicial de cada aparici@'on en el vector @var{idx}. Si no 
se encuentra, o si @var{pattern} es m@'as largo que @var{str}, entonces 
@var{idx} es una cadena vacia @code{[]}.

Si se especifica el arreglo de celdas de cadenas @var{cellstr} en lugar de la 
cadena @var{str}, entonces @var{idx} es un arreglo de celdas de vectores, como 
se especific@'o anteriormente.

@seealso{findstr, strmatch, strcmp, strncmp, strcmpi, strncmpi}
@end deftypefn
