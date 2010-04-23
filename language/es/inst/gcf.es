md5="41869ff26572c2b98ee73b7b97f38aec";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} gcf ()
Retorna el apuntador de la figura actual. Si no existe una figura, crea 
una y retorna su apuntador. El apuntador puede ser usado para examinar 
o establecer las propiedades de la figura. Por ejemplo, 

@example
@group
fplot (@@sin, [-10, 10]);
fig = gcf ();
set (fig, "visible", "off");
@end group
@end example

@noindent
grafica la función seno, encuentra el apuntador de la figura actual, 
y la hace invisible. Asignando @code{"on"} a la propiedad visible de la 
figure, hace que la figura se muestre nuevamente.
@seealso{get, set}
@end deftypefn
