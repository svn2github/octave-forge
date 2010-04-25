md5="dc8b19d2f70dbaa3dc2836b8e52f3a4c";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{ind} =} sub2ind (@var{dims}, @var{i}, @var{j})
@deftypefnx {Archivo de función} {@var{ind} =} sub2ind (@var{dims}, @var{s1}, @var{s2}, @dots{}, @var{sN})
Convierte subíndices en índices lineales.

El siguiente ejemplo muestra como convertir el índice de dos 
dimensiones @code{(2,3)} de una matriz de 3 por 3 en un índice 
lineal.

@example
linear_index = sub2ind ([3, 3], 2, 3)
@result{} 8
@end example
@seealso{ind2sub}
@end deftypefn
