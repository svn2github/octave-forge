md5="6ef2c7ba4a528a03e934350ab11d97e6";rev="6367";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} sumsq (@var{x}, @var{dim})
Suma los cuadrados de los elementos a lo largo de la dimensi@'on @var{dim}. 
Si se omite @var{dim}, se utiliza el valor 1 (suma los cuadrados en 
el sentido de las columnas).

Como caso especial, si @var{x} es un vector y se omite @var{dim}, 
retorna la suma de los cuadrados de los elementos.

Esta funci@'on es conceptualmente equivalente a calcular 
@example
sum (x .* conj (x), dim)
@end example
pero use menos memoria y evita los llamados a @code{conj} si @var{x} es 
real.
@end deftypefn
