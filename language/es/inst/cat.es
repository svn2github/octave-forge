md5="1959483d6739316e5de11b9799525846";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} cat (@var{dim}, @var{array1}, @var{array2}, @dots{}, @var{arrayN})
Retorna la concatenación de N-D objetos de tipo arreglo, 
@var{array1}, @var{array2}, @dots{}, @var{arrayN} a lo largo de la 
dimensión @var{dim}.

@example
@group
A = ones (2, 2);
B = zeros (2, 2);
cat (2, A, B)
@result{} ans =

     1 1 0 0
     1 1 0 0
@end group
@end example

Alternativamente, se puede concatenar @var{A} y @var{B} a lo largo 
de la segunda dimensión de la siguiente forma:

@example
@group
[A, B].
@end group
@end example

@var{dim} puede ser mayor que las dimensiones de los N-d objetos de 
tipo arreglo y el resultado entonces tendrá @var{dim} dimensiones 
como se muestra en el siguiente ejemplo:
@example
@group
cat (4, ones(2, 2), zeros (2, 2))
@result{} ans =

   ans(:,:,1,1) =

     1 1
     1 1

   ans(:,:,1,2) =
     0 0
     0 0
@end group
@end example
@seealso{horzcat, vertcat}
@end deftypefn
