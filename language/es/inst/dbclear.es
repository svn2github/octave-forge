md5="e20bc80697e66bf03f7bb594f34c12f1";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} dbclear (@var{func}, @var{line}, @dots{})
Elimina un punto de interrupción en una función
@table @code
@item func
Cadena que representa el nombre de la función. Cuando está en modo de 
depuración, debería omitirse y solo suministrar la línea.
@item line
Línea en donde se eliminará el punto de interrupción. Múltiples 
lineas pueden ser suministradas como argumentos o como un vector.
@end table
No se realiza ninguna verificación para asegurarse que la línea solicitada 
realmente es un punto de interrupción. No se producirá ningún problema 
si la  línea es erronea.
@seealso{dbstop, dbstatus, dbwhere}
@end deftypefn
