md5="0ff7aec6cd20f66ced207b6e5fa90810";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} surface (@var{x}, @var{y}, @var{z}, @var{c})
@deftypefnx {Archivo de función} {} surface (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de función} {} surface (@var{z}, @var{c})
@deftypefnx {Archivo de función} {} surface (@var{z})
@deftypefnx {Archivo de función} {} surface (@dots{}, @var{prop}, @var{val})
@deftypefnx {Archivo de función} {} surface (@var{h}, @dots{})
@deftypefnx {Archivo de función} {@var{h} = } surface (@dots{})
Gráfica una superficie de objeto gráfico dadas las matrices @var{x}, y
@var{y} de @code{meshgrid} y una matriz @var{z} correspondiente a la 
@var{x} y @var{y} coordenadas de la superficie. Si @var{x} y @var{y} son
vectores, entonces, un típico vértice es (@var{x}(j), @var{y}(i), @var{z}(i,j)).
Por lo tanto, las columnas de @var{z} corresponden a diferentes @var{x}
los valores y las filas de @var{z} corresponden a diferentes @var{y} valores.
Si  @var{x} y @var{y} están desaparecidos, se construyen a partir del
tamaño de la matriz @var{z}.

Las propiedades adicionales pasadas se les asigna la superficie de la ..
@seealso{surf, mesh, patch, line}
@end deftypefn
