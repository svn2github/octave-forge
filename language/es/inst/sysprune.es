md5="67449c1e465da0a44c6812d2ee2c69b9";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{retsys} =} sysprune (@var{asys}, @var{out_idx}, @var{in_idx})
Extrae especificas entradas/salidas de un sistema 

@strong{Entradas}
@table @var
@item asys
estructura de datos del sistema
@item out_idx
@itemx in_idx

@'Indices o nombres de las se@~{n}ales de las salidas y entradas que se
encuentran en el sistema de retorno; conexiones restantes son ``pruned''
off. Podr@'a seleccionar como [] (matriz vac@'ia) para especificar todas
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