md5="33c6f652d75db318a4bd596d5df540ab";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} tril (@var{a}, @var{k})
@deftypefnx {Archivo de función} {} triu (@var{a}, @var{k})
Regresa una nueva matriz formada por extraer la menor (@code{tril}) o
superior (@code{triu}) parte triangular de la matriz @var{a}, y el 
establecimiento de todos los demás elementos a cero. El segundo argumento
es opcional, y especifica cómo muchas diagonales por encima o por debajo
de la diagonal principal también se debe establecer en cero.

El valor predeterminado de @var{k} es cero, por lo que @code{triu} y @code{tril}
incluyen normalmente la diagonal principal como parte del resultado
de la matriz.

Si el valor de @var{k} es negativo, por encima de elementos adicionales
(para @code{tril}) o menor (para @code{triu}) de la diagonal principal
son también seleccionados.

El valor absoluto de @var{k} no debe ser mayor que el número de sub- o 
super-diagonales.

Por ejemplo,

@example
@group
tril (ones (3), -1)
@result{}  0  0  0
         1  0  0
         1  1  0
@end group
@end example

@noindent
and

@example
@group
tril (ones (3), 1)
@result{}  1  1  0
         1  1  1
         1  1  1
@end group
@end example
@seealso{triu, diag}
@end deftypefn
