md5="e294dd9d61ce88cceccb7bdf40815b48";rev="5920";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} colorbar (@var{s})
@deftypefnx {Archivo de funci@'on} {} colorbar ('peer', @var{h}, @dots{})
Agrega una barra de colores a los ejes actuales. Los valores v@'alidos para 
@var{s} son

@table @asis
@item 'EastOutside'
Ubica una barra de colores fuera de la gr@'afica, a la derecha. Esta es la 
opci@'on predeterminada.
@item 'East'
Ubica la barra de colores dentro de la gr@'afica, a la derecha.
@item 'WestOutside'
Ubica la barra de colores fuera de la gr@'afica, a la izquierda.
@item 'West'
Ubica la barra de colores dentro de la gr@'afica, a la izquierda.
@item 'NorthOutside'
Ubica la barra de colores encima de la gr@'afica.
@item 'North'
Ubica la barra de colores arriba de la gr@'afica.
@item 'SouthOutside'
Ubica la barra de colores encima de la gr@'afica.
@item 'South'
Ubica la barra de colores debajo de la gr@'afica.
@item 'Off', 'None'
Remueve cualquier barra de colores existente en la gr@'afica.
@end table

Si se suministra el argumento 'peer', el siguiente argumento se trata como 
el manejador de ejes sobre el cual se agrega la barra de colores.
@end deftypefn
