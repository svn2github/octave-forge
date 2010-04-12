md5="1a0cdc743ebcfff521031711d2dc6f65";rev="6224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} detrend (@var{x}, @var{p})
Si @var{x} es un vector, remueve el mejor ajuste del polinomio 
de orden @var{p} de los datos @var{x}.

Si @var{x} es una matriz, hace lo mismo para cada columna 
en @var{x}.

El segundo argumento es opcional. Si no se especifica, se asume el 
valor 1. Este corresponde a remover la tendencia lineal.
@end deftypefn