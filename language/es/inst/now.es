md5="71e638eb1843143ee5381678eef413af";rev="6315";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {t =} now ()
Retorna la hora local actual como el n@'umero de d@'ias desde el 
1 de Enero de 0000. Usando este c@'alculo, el 1 de Enero de 1970 
corresponde con el n@'umero 719529.

La parte entera, @code{floor (now)} corresponde a hoy 00:00:00. 

La parte decimal, @code{rem (now, 1)} curresponde a la hora actual 
el 1 de Enero de 0000.

El valor retornado tamb@'ien es llamado "n@'umero de fecha serial"
(v@'ease @code{datenum}).
@seealso{clock, date, datenum}
@end deftypefn
