md5="ad3496b9ff7264d29a88c30ec863bcbe";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{K} =} hinf_ctr (@var{dgs}, @var{f}, @var{h}, @var{z}, @var{g})
Llamado por @code{hinfsyn} para calcular el 
@iftex
@tex
$ { \cal H }_\infty $
@end tex
@end iftex
@ifinfo
H-infinity
@end ifinfo
controlador óptimo. 

@strong{Entradas}
@table @var
@item dgs
Estructura de datos retornada por @code{is_dgkf}
@item f
@itemx h
Retroalimentación y ganancia filtrada (no particionada)
@item g
Valor gamma final
@end table
@strong{Salidas}
@table @var
@item K
Controlador (estructura de datos del sistema)
@end table

No intente usar esto en casa; no se realiza verificación de 
ninguno de los argumentos.
@end deftypefn
