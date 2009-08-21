md5="9529a2df91ccd1c8fa571ec7e747e704";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {rline =} dbstop (@var{func}, @var{line}, @dots{})
Establece un punto de interrupci@'on en una funci@'on 
@table @code
@item func
Cadena que representa el nombre de la funci@'on. Cuando est@'a en modo de 
depuraci@'on, deber@'ia omitirse y solo suministrar la l@'inea.
@item line
L@'inea en donde se eliminar@'a el punto de interrupci@'on. M@'ultiples 
lineas pueden ser suministradas como argumentos o como un vector.
@end table

La variable retornada @var{rline} es la l@'inea real en la cual el 
punto de interrupci@'on fue establecido.
@seealso{dbclear, dbstatus, dbnext}
@end deftypefn
