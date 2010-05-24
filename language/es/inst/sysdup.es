md5="1d5051f1422542c0b15a5584e723ce1a";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{retsys} =} sysdup (@var{asys}, @var{out_idx}, @var{in_idx})
Duplica una conexión especificada entrada/salida de un sistema

@strong{Entradas}
@table @var
@item asys
estructura de datos del sistema
@item out_idx
@itemx in_idx
los índices o los nombres de señales deseadas (Vea @code{sigidx}).
duplicados son de @code{y(out_idx(ii))} and @code{u(in_idx(ii))}.
@end table

@strong{Salida}
@table @var
@item retsys
Resultando sistema de bucle cerrado:
duplicado i/o los nombres se anexan con un sufijo @code{"+"}.

@end table

@strong{Método}

@code{sysdup} crea copias de las entradas y salidas seleccionadas, como
se muestra a continuación. @var{u1}, @var{y1} es el conjunto de las
entradas/salidas, y @var{u2}, @var{y2} es el conjunto de entradas/salidas
duplicadas en el orden especificado en @var{in_idx}, @var{out_idx},
respectivamente

@example
@group
          ____________________
u1  ----->|                  |----> y1
          |       asys       |
u2 ------>|                  |----->y2
(in_idx)  -------------------- (out_idx)
@end group
@end example
@end deftypefn 