md5="ad3496b9ff7264d29a88c30ec863bcbe";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{K} =} hinf_ctr (@var{dgs}, @var{f}, @var{h}, @var{z}, @var{g})
Llamado por @code{hinfsyn} para calcular el 
@iftex
@tex
$ { \cal H }_\infty $
@end tex
@end iftex
@ifinfo
H-infinity
@end ifinfo
controlador @'optimo. 

@strong{Entradas}
@table @var
@item dgs
Estructura de datos retornada por @code{is_dgkf}
@item f
@itemx h
Retroalimentaci@'on y ganancia filtrada (no particionada)
@item g
Valor gamma final
@end table
@strong{Salidas}
@table @var
@item K
Controlador (estructura de datos del sistema)
@end table

No intente usar esto en casa; no se realiza verificaci@'on de 
ninguno de los argumentos.
@end deftypefn
