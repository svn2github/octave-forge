md5="91dbb9e71dd24d8492d16f03f3f615ea";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{sys} =} sysgroup (@var{asys}, @var{bsys})
Combina dos sistemas en un @'unico sistema.

@strong{Entradas}
@table @var
@item asys
@itemx bsys
estructura de datos del sistema
@end table

@strong{Salidas}
@table @var
@item sys
@math{sys = @r{block diag}(asys,bsys)}
@end table
@example
@group
         __________________
         |    ________    |
u1 ----->|--> | asys |--->|----> y1
         |    --------    |
         |    ________    |
u2 ----->|--> | bsys |--->|----> y2
         |    --------    |
         ------------------
              Ksys
@end group
@end example
La funci@'on tambi@'en reordena el estado-espacio interno de realizaci@'on
de @var{sys} de modo que los estados continuos van en primer lugar y los
estados discretos vienen despu@'es. Si no hay nombres duplicados, el 
segundo nombre tiene un sufijo @'unico agregado a la final del nombre.
@end deftypefn