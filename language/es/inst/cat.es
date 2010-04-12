md5="1959483d6739316e5de11b9799525846";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} cat (@var{dim}, @var{array1}, @var{array2}, @dots{}, @var{arrayN})
Retorna la concatenaci@'on de N-D objetos de tipo arreglo, 
@var{array1}, @var{array2}, @dots{}, @var{arrayN} a lo largo de la 
dimensi@'on @var{dim}.

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
de la segunda dimensi@'on de la siguiente forma:

@example
@group
[A, B].
@end group
@end example

@var{dim} puede ser mayor que las dimensiones de los N-d objetos de 
tipo arreglo y el resultado entonces tendr@'a @var{dim} dimensiones 
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
