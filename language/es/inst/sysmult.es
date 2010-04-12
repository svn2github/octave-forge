md5="382efa9edd02be455bb6bbb7c91e2cd9";rev="6405";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{sys} =} sysmult (@var{Asys}, @var{Bsys})
Calcula @math{sys = Asys*Bsys} (conexi@'on en serie):
@example
@group
u   ----------     ----------
--->|  Bsys  |---->|  Asys  |--->
    ----------     ----------
@end group
@end example
Ocurre una advertencia si existe una retroalimentaci@'on directa 
entre una entrada o un estado continuo de @var{Bsys}, a trav@'es de 
una salida discreta de @var{Bsys}, y un estado continuo o salida en 
@var{Asys} (la estructura de datos del sistena no reconoce entradas 
discretas).
@end deftypefn
