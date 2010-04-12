md5="46d14a3426b2b23eaa88f5da5d2d4505";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} caxis (@var{limits})
@deftypefnx {Archivo de funci@'on} {} caxis (@var{h}, @dots{})
Ajusta el l@'imite de color para los ejes para las gr@'aficas.

El argumento @var{limits} deber@'ia ser un vector de 2 elementos
especificando los l@'imites inferior y superior para asignar el 
primer y @'ultimo valor en el mapa de colores. Los valores fuera de 
este rango se fijan a la primera y la última entradas de colores.

Si @var{limits} es 'auto', se aplica escala de mapa de colores 
autom@'atica, mientras que si @var{limits} es 'manual' se aplica escala de mapa de colores manual.

Una llamada sin argumentos retorna los actuales l@'imites de colores de ejes.

Si un manejador de ejes se pasa como primer argumento, opera sobre los mismos ejes en lugar de los ejes actuales.
@end deftypefn
