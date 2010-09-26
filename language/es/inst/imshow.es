-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} imshow (@var{im})
@deftypefnx {Archivo de funci@'on} {} imshow (@var{im}, @var{limits})
@deftypefnx {Archivo de funci@'on} {} imshow (@var{im}, @var{map})
@deftypefnx {Archivo de funci@'on} {} imshow (@var{rgb}, @dots{})
@deftypefnx {Archivo de funci@'on} {} imshow (@var{filename})
@deftypefnx {Archivo de funci@'on} {} imshow (@dots{}, @var{string_param1}, @var{value1}, @dots{})
Mostrar la imagen @var{im}, donde  @var{im} puede ser bi-dimensional
(en escala de grises de la imagen) o tri-dimensiones (imagen RGB)
de la matriz.

Si @var{limits} es un vector de 2 elementos @code{[@var{low}, 
@var{high}]}, la imagen se muestra con una amplia pantalla entre 
@var{low} y @var{high}. Si una matriz vacía se pasa para @var{limits},
el rango de muestra se calcula como el intervalo entre el mínimo y el
máximo valor en la imagen.

Si @var{map} es un mapa de color válido, la imagen se mostrará como una
imagen indexada con el mapa de color proporcionada.

Si es un nombre de archivo dado en lugar de una imagen, el archivo será
leído y se muestra.

Si dados, los parametros @var{string_param1} tiene un valor
@var{value1}. @var{string_param1} puede ser cualquiera de los siguientes:
@table @samp
@item "displayrange"
@var{value1} es el rango de visualización como se describe anteriormente.
@end table
@seealso{image, imagesc, colormap, gray2ind, rgb2ind}
@end deftypefn
