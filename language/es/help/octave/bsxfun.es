md5="c9a9f0cd685ac71e176d42f78bd77995";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
 -*- texinfo -*-
@deftypefn {Funci@'on cargable} {} bsxfun (@var{f}, @var{a}, @var{b})
Aplica una funci@'on binaria @var{f} elemento a elemento sobre dos matrices argumentos @var{a} y @var{b}. La funci@'on @var{f} debe ser capaz de aceptar 
dos vectores columna de igual longitud como argumentos, o un vector columna
y un escalar como argumento.

Las dimensiones de @var{a} y @var{b} deben ser iguales o singleton. Las 
dimensiones singleton de las matrices ser@'an expandidas a la misma
dimensionalidad como la otra matriz.

@seealso{arrayfun, cellfun}
@end deftypefn
