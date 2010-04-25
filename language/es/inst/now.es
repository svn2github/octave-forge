md5="71e638eb1843143ee5381678eef413af";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {t =} now ()
Retorna la hora local actual como el número de días desde el 
1 de Enero de 0000. Usando este cálculo, el 1 de Enero de 1970 
corresponde con el número 719529.

La parte entera, @code{floor (now)} corresponde a hoy 00:00:00. 

La parte decimal, @code{rem (now, 1)} curresponde a la hora actual 
el 1 de Enero de 0000.

El valor retornado tambíen es llamado "número de fecha serial"
(véase @code{datenum}).
@seealso{clock, date, datenum}
@end deftypefn
