md5="e294dd9d61ce88cceccb7bdf40815b48";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} colorbar (@var{s})
@deftypefnx {Archivo de función} {} colorbar ('peer', @var{h}, @dots{})
Agrega una barra de colores a los ejes actuales. Los valores válidos para 
@var{s} son

@table @asis
@item 'EastOutside'
Ubica una barra de colores fuera de la gráfica, a la derecha. Esta es la 
opción predeterminada.
@item 'East'
Ubica la barra de colores dentro de la gráfica, a la derecha.
@item 'WestOutside'
Ubica la barra de colores fuera de la gráfica, a la izquierda.
@item 'West'
Ubica la barra de colores dentro de la gráfica, a la izquierda.
@item 'NorthOutside'
Ubica la barra de colores encima de la gráfica.
@item 'North'
Ubica la barra de colores arriba de la gráfica.
@item 'SouthOutside'
Ubica la barra de colores encima de la gráfica.
@item 'South'
Ubica la barra de colores debajo de la gráfica.
@item 'Off', 'None'
Remueve cualquier barra de colores existente en la gráfica.
@end table

Si se suministra el argumento 'peer', el siguiente argumento se trata como 
el apuntador de ejes sobre el cual se agrega la barra de colores.
@end deftypefn
