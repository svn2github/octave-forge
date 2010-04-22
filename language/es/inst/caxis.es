md5="46d14a3426b2b23eaa88f5da5d2d4505";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} caxis (@var{limits})
@deftypefnx {Archivo de función} {} caxis (@var{h}, @dots{})
Ajusta el límite de color para los ejes para las gráficas.

El argumento @var{limits} debería ser un vector de 2 elementos
especificando los límites inferior y superior para asignar el 
primer y último valor en el mapa de colores. Los valores fuera de 
este rango se fijan a la primera y la última entradas de colores.

Si @var{limits} es 'auto', se aplica escala de mapa de colores 
automática, mientras que si @var{limits} es 'manual' se aplica escala 
de mapa de colores manual.

Una llamada sin argumentos retorna los actuales límites de colores de ejes.

Si un apuntador de ejes se pasa como primer argumento, opera sobre los mismos 
ejes en lugar de los ejes actuales.
@end deftypefn
