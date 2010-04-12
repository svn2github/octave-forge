md5="70e466ebc5006106273463e0c8aceeb1";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{pv} =} sysreorder (@var{vlen}, @var{list})

@strong{Entradas}
@table @var
@item vlen
Longitud del vector.
@item list
Subconjunto de @code{[1:vlen]}.
@end table

@strong{Salida}
@table @var
@item pv
Vector de permutaciones para ordenar los elementos de @code{[1:vlen]} en 
@code{list} al final de un vector.
@end table

Esta funci@'on la usa internamente @code{sysconnect} para permutar los elementos del 
vector a su ubicaci@'on deseada.
@end deftypefn
