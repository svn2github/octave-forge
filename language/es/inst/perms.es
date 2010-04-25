md5="50ea6efd4be73eb904dca36d23a73fc1";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} perms (@var{v})
Genera todas las permutaciones de @var{v}, una fila porpermutación. 
El resultado tiene el tama@~{n}o @code{factorial (@var{n}) * @var{n}}, 
donde @var{n} es la longitud de @var{v}.

Por ejemplo, @code{perms([1, 2, 3])} retorna la matriz 
@example
  1   2   3
  2   1   3
  1   3   2
  2   3   1
  3   1   2
  3   2   1
@end example
@end deftypefn
