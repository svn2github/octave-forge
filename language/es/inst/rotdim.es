md5="56c8e1d6a31f8f58adb182797f7f00d0";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} rotdim (@var{x}, @var{n}, @var{plane})
Devuelve una copia de @var{x} con los elementos rotados hacia la
izquierda en incrementos de 90 grados. El segundo argumento es opcional,
y especifica el número de rotaciones de 90 grados que se deben aplicar
(el valor predeterminado es 1). El tercer argumento es también opcional
y define el plano de la rotación. Como tal @var{plane} es un vector de
dos elementos que contiene dos diferentes dimensiones válidas de la
matriz. Si @var{plane} no se da entonces las primeras dos dimensiones 
son utilizada.

Valores negativos de @var{n} rota la matriz hacia la dirección derecha.
Por ejemplo,

@example
@group
rotdim ([1, 2; 3, 4], -1, [1, 2])
@result{}  3  1
         4  2
@end group
@end example

@noindent
gira en hacia la izquierda la matriz dada en 90 grados. Los siguientes
son todos las llamadas equivalentes:

@example
@group
rotdim ([1, 2; 3, 4], -1, [1, 2])
rotdim ([1, 2; 3, 4], 3, [1, 2])
rotdim ([1, 2; 3, 4], 7, [1, 2])
@end group
@end example
@seealso{rot90, flipud, fliplr, flipdim}
@end deftypefn 