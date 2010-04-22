md5="0853a5c0c86e3daf6592b245db7523e9";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{err}, @var{y1}, @dots{}] =} common_size (@var{x1}, @dots{})
Determina si todos los argumentos de entrada son escalares o de 
tama@~{n}o común.  Si es asi, @var{err} es cero, y @var{yi} es una 
matriz del tama@~{n}o común con todas las entradas iguales a @var{xi} si este es un escalar o, @var{xi} en otro caso.  Si las entradas no tienen tama@~{n}o común, errorcode es 1, y @var{yi} es @var{xi}. Por ejemplo,

@example
@group
[errorcode, a, b] = common_size ([1 2; 3 4], 5)
@result{} errorcode = 0
@result{} a = [ 1, 2; 3, 4 ]
@result{} b = [ 5, 5; 5, 5 ]
@end group
@end example

@noindent
Esta función es útil para implementar funciones que donde los argumentos pueden ser escalares o de tama@~{n}o común.
@end deftypefn
