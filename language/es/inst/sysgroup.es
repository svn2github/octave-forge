md5="91dbb9e71dd24d8492d16f03f3f615ea";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{sys} =} sysgroup (@var{asys}, @var{bsys})
Combina dos sistemas en un único sistema.

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
La función también reordena el estado-espacio interno de realización
de @var{sys} de modo que los estados continuos van en primer lugar y los
estados discretos vienen después. Si no hay nombres duplicados, el 
segundo nombre tiene un sufijo único agregado a la final del nombre.
@end deftypefn