md5="e61ba05f05d3b8eddca31f816e843b11";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{retsys}, @var{nc}, @var{no}] =} sysmin (@var{sys}, @var{flg})
Devuelve una mínima (o reducción de orden) del sistema

@strong{Entradas}
@table @var
@item sys
estructura de datos del sistema
@item flg
Cuando igual a 0 (valor predeterminado), retorna los mínimos del 
sistema, los nombres de estado en el que se pierden; cuando igual a 1,
el sistema vuelve con los estados de eliminación físicos que son
incontrolable o no observables (no se puede reducir aún más sin 
descartar el significado físico de los estados).
@end table
@strong{Salidas}
@table @var
@item retsys
Sistema devuelto
@item nc
Número de estados controlables en el sistema devuelto.
@item no
Número de estados observables en el sistema devuelto.
@item cflg
@code{is_controllable(retsys)}.
@item oflg
@code{is_observable(retsys)}.
@end table
@end deftypefn