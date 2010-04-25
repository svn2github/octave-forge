md5="2a6524607200badc428a0723ab594b46";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} starp (@var{P}, @var{K}, @var{ny}, @var{nu})
El producto estrella de Redheffer o upper/lower LFT, respectivamente.

@example
@group

               +-------+
     --------->|       |--------->
               |   P   |
          +--->|       |---+  ny
          |    +-------+   |
          +-------------------+
                           |  |
          +----------------+  |
          |                   |
          |    +-------+      |
          +--->|       |------+ nu
               |   K   |
     --------->|       |--------->
               +-------+
@end group
@end example
Si @var{ny} y @var{nu} ``consume'' todas las entradas y salidas de 
@var{K} entonces el resultado es una transformación lower fraccionada. 
Si @var{ny} y @var{nu} ``consume'' todas las entradas y salidas de
@var{P} entonces el resultado es una transformación upper fraccionada.

@var{ny} y/o @var{nu} puede ser negativa (es decir, retroalimentación
negativa).
@end deftypefn
