md5="384dfb84bdaff3102439b4ca4874fad0";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{dsys}, @var{adc}, @var{cdc}] =} sysdisc (@var{sys})

@strong{Entrada}
@table @var
@item sys
Estructura de datos del sistema.
@end table

@strong{Salidas}
@table @var
@item dsys
Porción discreta de @var{sys} (Si no hay una ruta discreta 
pura entre la entrada y las salidas, retorna vacio).
@item    adc
@itemx   cdc
Conexiones entre los estados continuos y discretos y las salidas, 
respectivamente.
@end table
@end deftypefn
