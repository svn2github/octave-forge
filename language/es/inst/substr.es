md5="d456495b55bcaa6269241c9396e7a518";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} substr (@var{s}, @var{offset}, @var{len})
Retorna la subcadena de @var{s}, la cual comienza en la posición del 
caracter @var{offset} y tiene @var{len} caracteres de longitud. 

Si @var{offset} es negativo, la extracción comienza a esa misma 
distancia desde el final de la cadena. Si se omite @var{len}, se 
extiende la subcadena hasta el final de @var{s}. 

Por ejemplo, 

@example
substr ("This is a test string", 6, 9)
@result{} "is a test"
@end example

Esta función esta basada en AWK. Es posible obtener el mismo 
resultado mediante @code{@var{s} (@var{offset} : (@var{offset} 
+ @var{len} - 1))}.
@end deftypefn
