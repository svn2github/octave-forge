md5="7148f229f6995b0a743ffefb10a8fd99";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} spkron (@var{a}, @var{b})
Forma producto de Kronecker entre dos matrices dispersas. 
Este producto se define bloque por bloque como 

@example
x = [a(i, j) b]
@end example

Por ejemplo, 

@example
@group
kron(speye(3),spdiag([1,2,3]))
@result{}
Compressed Column Sparse (rows = 9, cols = 9, nnz = 9)

  (1, 1) ->  1
  (2, 2) ->  2
  (3, 3) ->  3
  (4, 4) ->  1
  (5, 5) ->  2
  (6, 6) ->  3
  (7, 7) ->  1
  (8, 8) ->  2
  (9, 9) ->  3
@end group
@end example
@end deftypefn
