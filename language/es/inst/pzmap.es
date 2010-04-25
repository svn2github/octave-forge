md5="0eca7784d0da9f6e38b42ad4d8e43bb3";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{zer}, @var{pol}] =} pzmap (@var{sys})
Grafica los ceros y polos de un sistema en el plano complejo.

@strong{Entrada}
@table @var
@item sys
Estructura de datos del sistema.
@end table

@strong{Salidas}
@table @var
@item pol
@item zer
Si se omite, se grafican los polos y ceros en la pantalla. 
En otro caso, los polos y ceros se retornan en la variables 
@var{pol} y @var{zer} respectivamente (véase @command{sys2zp} 
para información adicional acerca del llamado de la función).
@end table
@end deftypefn
