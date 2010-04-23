md5="9529a2df91ccd1c8fa571ec7e747e704";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {rline =} dbstop (@var{func}, @var{line}, @dots{})
Establece un punto de interrupción en una función 
@table @code
@item func
Cadena que representa el nombre de la función. Cuando está en modo de 
depuración, debería omitirse y solo suministrar la línea.
@item line
Línea en donde se eliminará el punto de interrupción. Múltiples 
lineas pueden ser suministradas como argumentos o como un vector.
@end table

La variable retornada @var{rline} es la línea real en la cual el 
punto de interrupción fue establecido.
@seealso{dbclear, dbstatus, dbnext}
@end deftypefn
