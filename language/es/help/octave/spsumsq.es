md5="c34e3ab084588dd53930f40f939252fc";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{y} =} spsumsq (@var{x},@var{dim})
Suma los cuadrados de los elementos a lo largo de la dimensi@'on @var{dim}. 
Si se omite @var{dim}, el valor predeterminado es 1 (suma de cuadrados en el 
sentido de las columnas).

Esta funci@'on es equivalente a 
@example
spsum (x .* spconj (x), dim)
@end example
pero usa menos memoria y evita los llamados a la funci@'on @code{spconj} si 
@var{x} es real.
@seealso{spprod, spsum}
@end deftypefn
