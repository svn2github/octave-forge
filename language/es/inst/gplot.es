md5="812533c201ff64df6bc6f070e16fc98f";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} gplot (@var{a}, @var{xy})
@deftypefnx {Archivo de función} {} gplot (@var{a}, @var{xy}, @var{line_style})
@deftypefnx {Archivo de función} {[@var{x}, @var{y}] =} gplot (@var{a}, @var{xy})
Traza una gráfica definida por @var{A} y @var{xy} en el sentido de la
teoría de grafos. @var{A} es la matriz de adyacencia de la matriz a ser
trazada y @var{xy} es una matriz @var{n}-por-2  que contiene las 
coordenadas de los nodos de la gráfica.

El parámetro opcional @var{line_style} definén el estilo de salida para
ser trazada. invocarla sin argumentos de salida la gráfica es trazada
directamente. de otro modo, regresa las coordenadas del trazo en @var{x}
y @var{y}.
@seealso{treeplot, etreeplot, spy}
@end deftypefn