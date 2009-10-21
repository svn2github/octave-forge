md5="0eca7784d0da9f6e38b42ad4d8e43bb3";rev="6351";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{zer}, @var{pol}] =} pzmap (@var{sys})
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
@var{pol} y @var{zer} respectivamente (v@'ease @command{sys2zp} 
para informaci@'on adicional acerca del llamado de la funci@'on).
@end table
@end deftypefn
