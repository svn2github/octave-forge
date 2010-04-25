md5="4b2b9599190912fb7d69d1fa84514aef";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} sysupdate (@var{sys}, @var{opt})
Actualiza la representación interna de un sistema.

@strong{Entradas}
@table @var
@item sys:
estructura de datos del sistema
@item opt
string:
@table @code
@item "tf"
formulario de Actualización función de transferencia
@item "zp"
formulario de actualización forma zero-pole
@item "ss"
formulario de actualización espacio de estado
@item "all"
todos los anteriores
@end table
@end table

@strong{Salidas}
@table @var
@item retsys
Contiene la unión de datos en sys y los datos solicitados.
Si los datos solicitados en @var{sys} ya están actualizados entonces 
@var{retsys}=@var{sys}.
@end table
La conversión a @command{tf} o @command{zp} sale con un error si el 
sistema es mixto continuo/digital.
@seealso{tf, ss, zp, sysout, sys2ss, sys2tf, sys2zp}
@end deftypefn