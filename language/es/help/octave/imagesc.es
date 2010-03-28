md5="c28c72595707aa74a4403aa92a5264d5";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} imagesc (@var{a})
@deftypefnx {Archivo de funci@'on} {} imagesc (@var{x}, @var{y}, @var{a})
@deftypefnx {Archivo de funci@'on} {} imagesc (@dots{}, @var{limits})
@deftypefnx {Archivo de funci@'on} {} imagesc (@var{h}, @dots{})
@deftypefnx {Archivo de funci@'on} { @var{h} = } imagesc (@dots{})
Visualizar una versi@'on a escala de la matriz @var{a} como una imagen
en color. El mapa de colores se escala a fin de que las entradas de la
matriz de ocupen todo el mapa de colores. Si @var{limits} = [@var{lo},
@var{hi}] se dan, entonces tiene la opci@'on de 'clim' de los ejes
actuales.

El eje de los valores correspondientes a los elementos de matriz se
especifican en @var{x} y @var{y}, ya sea como pares dado los valores
m@'inimo y m@'aximo para los ejes respectivos, o como valores para
cada fila y columna de la matriz @var{a}.

@seealso{image, imshow, clim, caxis}
@end deftypefn
