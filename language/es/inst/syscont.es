md5="1b5f2764192c7185177dd5d08064dff0";rev="6405";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{csys}, @var{acd}, @var{ccd}] =} syscont (@var{sys})
Extrae los subsistemas puremente continuos de un sistema. 

@strong{Entrada}
@table @var
@item sys
Estructura de datos del sistema.
@end table

@strong{Salidas}
@table @var
@item csys
Conexiones entrada/saldia puremente continuas de @var{sys}
@item acd
@itemx ccd
Conecciones de los estados discretos a los estados continuos, 
estados discretos a salidas continuas, respectivamente. 

Si no existe una ruta continua, @var{csys} ser@'a vacio. 
@end table
@end deftypefn
