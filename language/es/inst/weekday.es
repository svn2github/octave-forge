md5="46dedf239d433bc331dc83f18f2baa75";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{n}, @var{s}] =} weekday (@var{d}, [@var{form}])
Retorna el día de la semana como un número en @var{n} y una cadena en 
@var{s}, por ejemplo @code{[1, "Sun"]}, @code{[2, "Mon"]}, @dots{}, o 
@code{[7, "Sat"]}.

La variable @var{d} es el número de fecha serial o una fecha de tipo 
cadena. 

Si se suministra la cadena @var{form} y es @code{"long"}, la variable 
@var{s} contiene el nombre completo del día de la semana; en otro caso 
(o si @var{form} es @code{"short"}), la variable @var{s} contiene el nombre 
abreviado del día de la semana.
@seealso{datenum, datevec, eomday}
@end deftypefn
