md5="c28c72595707aa74a4403aa92a5264d5";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} imagesc (@var{a})
@deftypefnx {Archivo de función} {} imagesc (@var{x}, @var{y}, @var{a})
@deftypefnx {Archivo de función} {} imagesc (@dots{}, @var{limits})
@deftypefnx {Archivo de función} {} imagesc (@var{h}, @dots{})
@deftypefnx {Archivo de función} { @var{h} = } imagesc (@dots{})
Visualizar una versión a escala de la matriz @var{a} como una imagen
en color. El mapa de colores se escala a fin de que las entradas de la
matriz de ocupen todo el mapa de colores. Si @var{limits} = [@var{lo},
@var{hi}] se dan, entonces tiene la opción de 'clim' de los ejes
actuales.

El eje de los valores correspondientes a los elementos de matriz se
especifican en @var{x} y @var{y}, ya sea como pares dado los valores
mínimo y máximo para los ejes respectivos, o como valores para
cada fila y columna de la matriz @var{a}.

@seealso{image, imshow, clim, caxis}
@end deftypefn
