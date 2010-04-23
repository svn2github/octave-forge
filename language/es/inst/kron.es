md5="2645197aa2fc38331493386b4520c624";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} kron (@var{a}, @var{b})
Realiza el producto de kronecker entre dos matrices, definifo bloque por bloque como: 

@example
x = [a(i, j) b]
@end example

Por ejemplo,

@example
@group
kron (1:4, ones (3, 1))
      @result{}  1  2  3  4
          1  2  3  4
          1  2  3  4
@end group
@end example
@end deftypefn
