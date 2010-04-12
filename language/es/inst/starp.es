md5="2a6524607200badc428a0723ab594b46";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} starp (@var{P}, @var{K}, @var{ny}, @var{nu})
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
@var{K} entonces el resultado es una transformaci@'on lower fraccionada. 
Si @var{ny} y @var{nu} ``consume'' todas las entradas y salidas de
@var{P} entonces el resultado es una transformaci@'on upper fraccionada.

@var{ny} y/o @var{nu} puede ser negativa (es decir, retroalimentaci@'on
negativa).
@end deftypefn
