md5="67449c1e465da0a44c6812d2ee2c69b9";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{retsys} =} sysprune (@var{asys}, @var{out_idx}, @var{in_idx})
Extrae especificas entradas/salidas de un sistema 

@strong{Entradas}
@table @var
@item asys
estructura de datos del sistema
@item out_idx
@itemx in_idx

Índices o nombres de las se@~{n}ales de las salidas y entradas que se
encuentran en el sistema de retorno; conexiones restantes son ``pruned''
off. Podrá seleccionar como [] (matriz vacía) para especificar todas
las salidas/entradas.

@example
retsys = sysprune (Asys, [1:3,4], "u_1");
retsys = sysprune (Asys, @{"tx", "ty", "tz"@}, 4);
@end example

@end table

@strong{Salidas}
@table @var
@item retsys
Sistema resultante.
@end table
@example
@group
           ____________________
u1 ------->|                  |----> y1
 (in_idx)  |       Asys       | (out_idx)
u2 ------->|                  |----| y2
  (deleted)-------------------- (deleted)
@end group
@end example
@end deftypefn