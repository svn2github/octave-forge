md5="758fcfd73a58d9195abb425f506a93e4";rev="6346";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} gca ()
Retorna un apuntador al objeto del eje actual. Si no existe 
ning@'un objeto eje, crea uno y retorns su apuntador. El apuntador 
puede entonces ser usado para examinar a establecer las propiedades 
de los ejes. Por ejemplo, 

@example
@group
ax = gca ();
set (ax, "position", [0.5, 0.5, 0.5, 0.5]);
@end group
@end example

@noindent
crea un objeto ejes vacio y cambia su ubicaci@'on y tama@~{n}o en la 
ventana de la figura.
@seealso{get, set}
@end deftypefn
