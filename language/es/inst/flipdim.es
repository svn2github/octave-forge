md5="7536ce2616d1ff694375c315b42a82b9";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} flipdim (@var{x}, @var{dim})
Retorna una copia de @var{x} reflejada en la dimensión @var{dim}.
Por ejemplo 

@example
@group
flipdim ([1, 2; 3, 4], 2)
@result{}  2  1
         4  3
@end group
@end example
@seealso{fliplr, flipud, rot90, rotdim}
@end deftypefn
