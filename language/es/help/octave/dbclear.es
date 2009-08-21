md5="e20bc80697e66bf03f7bb594f34c12f1";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} dbclear (@var{func}, @var{line}, @dots{})
Elimina un punto de interrupci@'on en una funci@'on
@table @code
@item func
Cadena que representa el nombre de la funci@'on. Cuando est@'a en modo de 
depuraci@'on, deber@'ia omitirse y solo suministrar la l@'inea.
@item line
L@'inea en donde se eliminar@'a el punto de interrupci@'on. M@'ultiples 
lineas pueden ser suministradas como argumentos o como un vector.
@end table
No se realiza ninguna verificaci@'on para asegurarse que la l@'inea solicitada 
realmente es un punto de interrupci@'on. No se producir@'a ning@'un problema 
si la  l@'inea es erronea.
@seealso{dbstop, dbstatus, dbwhere}
@end deftypefn
