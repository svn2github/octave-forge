md5="8c9b6928f5070f630035519e2af60cf5";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{y} =} shiftdim (@var{x}, @var{n})
@deftypefnx {Archivo de función} {[@var{y}, @var{ns}] =} shiftdim (@var{x})
Cambios de la dimensión de @var{x} por @var{n}, donde @var{n} debe ser
un escalar entero. Cuando @var{n} es positivo, las dimensiones de @var{x}
se desplazan a la izquierda, con las dimensiones principales distribuidas
hasta el final. Si @var{n} es negativa, entonces las dimensiones de @var{x}
se desplazan a la derecha, con @var{n} principal dimension unitarias 
agregada.

La llamada con un solo argumento, @code{shiftdim}, elimina las dimensiones
principales unitarias, devolviendo el número de dimensiones eliminadas
en la segunda salida argumento @var{ns}.

Por ejemplo

@example
@group
x = ones (1, 2, 3);
size (shiftdim (x, -1))
@result{} [1, 1, 2, 3]
size (shiftdim (x, 1))
@result{} [2, 3]
[b, ns] = shiftdim (x);
@result{} b =  [1, 1, 1; 1, 1, 1]
@result{} ns = 1
@end group
@end example
@seealso {reshape, permute, ipermute, circshift, squeeze}
@end deftypefn 