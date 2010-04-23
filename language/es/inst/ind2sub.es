md5="1d2f0fcec5c3e0bee9c9088c5c0fedc7";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{s1}, @var{s2}, @dots{}, @var{sN}] =} ind2sub (@var{dims}, @var{ind})
Convierte un índice lineal en sub@'ndices. 

El siguiente ejemplo muestra como convertir el índice lineal @code{8} 
de una matriz de 3 por 3 en un sub@'ndice. 

@example
[r, c] = ind2sub ([3, 3], 8)
@result{} r =  2
c =  3
@end example
@seealso{sub2ind}
@end deftypefn
