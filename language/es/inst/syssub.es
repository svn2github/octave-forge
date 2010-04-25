md5="5cdc3678930054a1635eb45c801b050c";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{sys} =} syssub (@var{Gsys}, @var{Hsys})
Retorna @math{sys = Gsys - Hsys}.

@strong{Método}

Los subsistemas @var{Gsys} y @var{Hsys} están conectados en 
parallelo. 

El vector de entrada está conectado con los dos sistemas; las 
salidas son restadas. Los nombres del sistema retornado son los 
de @var{Gsys}.

@example
@group
         +--------+
    +--->|  Gsys  |---+
    |    +--------+   |
    |                +|
u --+                (_)--> y
    |                -|
    |    +--------+   |
    +--->|  Hsys  |---+
         +--------+
@end group
@end example
@end deftypefn
