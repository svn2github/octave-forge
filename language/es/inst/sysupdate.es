md5="4b2b9599190912fb7d69d1fa84514aef";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} sysupdate (@var{sys}, @var{opt})
Actualiza la representaci@'on interna de un sistema.

@strong{Entradas}
@table @var
@item sys:
estructura de datos del sistema
@item opt
string:
@table @code
@item "tf"
formulario de Actualizaci@'on funci@'on de transferencia
@item "zp"
formulario de actualizaci@'on forma zero-pole
@item "ss"
formulario de actualizaci@'on espacio de estado
@item "all"
todos los anteriores
@end table
@end table

@strong{Salidas}
@table @var
@item retsys
Contiene la uni@'on de datos en sys y los datos solicitados.
Si los datos solicitados en @var{sys} ya est@'an actualizados entonces 
@var{retsys}=@var{sys}.
@end table
La conversi@'on a @command{tf} o @command{zp} sale con un error si el 
sistema es mixto continuo/digital.
@seealso{tf, ss, zp, sysout, sys2ss, sys2tf, sys2zp}
@end deftypefn