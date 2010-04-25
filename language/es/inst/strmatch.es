md5="9b567ace09c1fa256b7d40bfb1362b6c";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} strmatch (@var{s}, @var{a}, "exact")
Retorna los índices de las entradas de @var{a} que coinciden con la cadena 
@var{s}. El segundo argumento @var{a} puede ser una matriz de cadenas o un 
arreglo de celdas de cadenas. Si se omite el tercer argumento @code{"exact"}, 
@var{s} solo necesita coincidir con @var{a} hasta la longitud de @var{s}. Los 
caracteres nulos coinciden con los blancos. Los resultados se retornan como 
vectores columna.
@end deftypefn
