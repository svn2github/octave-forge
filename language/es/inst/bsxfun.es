md5="c9a9f0cd685ac71e176d42f78bd77995";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
 -*- texinfo -*-
@deftypefn {Función cargable} {} bsxfun (@var{f}, @var{a}, @var{b})
Aplica una función binaria @var{f} elemento a elemento sobre dos matrices argumentos @var{a} y @var{b}. La función @var{f} debe ser capaz de aceptar 
dos vectores columna de igual longitud como argumentos, o un vector columna
y un escalar como argumento.

Las dimensiones de @var{a} y @var{b} deben ser iguales o singleton. Las 
dimensiones singleton de las matrices serán expandidas a la misma
dimensionalidad como la otra matriz.

@seealso{arrayfun, cellfun}
@end deftypefn
