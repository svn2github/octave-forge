md5="e61ba05f05d3b8eddca31f816e843b11";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{retsys}, @var{nc}, @var{no}] =} sysmin (@var{sys}, @var{flg})
Devuelve una m@'inima (o reducci@'on de orden) del sistema

@strong{Entradas}
@table @var
@item sys
estructura de datos del sistema
@item flg
Cuando igual a 0 (valor predeterminado), retorna los m@'inimos del 
sistema, los nombres de estado en el que se pierden; cuando igual a 1,
el sistema vuelve con los estados de eliminaci@'on f@'isicos que son
incontrolable o no observables (no se puede reducir a@'un m@'as sin 
descartar el significado f@'isico de los estados).
@end table
@strong{Salidas}
@table @var
@item retsys
Sistema devuelto
@item nc
N@'umero de estados controlables en el sistema devuelto.
@item no
N@'umero de estados observables en el sistema devuelto.
@item cflg
@code{is_controllable(retsys)}.
@item oflg
@code{is_observable(retsys)}.
@end table
@end deftypefn