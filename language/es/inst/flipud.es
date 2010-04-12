md5="7f39c8ab10577f0088bd47b51ccc92f2";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} flipud (@var{x})
Retorna una copia de @var{x} con columnas en orden inverso. 
Por ejemplo,

@example
@group
flipud ([1, 2; 3, 4])
@result{}  3  4
         1  2
@end group
@end example

Debido a la dificultad para definir en que eje se va a realizar la 
transformaci@'on de la matriz, @code{flipud} solo funciona para arreglos 
de dos dimensiones. Para transformar arreglos de N dimensiones, 
use @code{flipdim}.
@seealso{fliplr, flipdim, rot90, rotdim}
@end deftypefn
