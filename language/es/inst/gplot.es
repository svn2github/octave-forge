md5="812533c201ff64df6bc6f070e16fc98f";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} gplot (@var{a}, @var{xy})
@deftypefnx {Archivo de funci@'on} {} gplot (@var{a}, @var{xy}, @var{line_style})
@deftypefnx {Archivo de funci@'on} {[@var{x}, @var{y}] =} gplot (@var{a}, @var{xy})
Traza una gr@'afica definida por @var{A} y @var{xy} en el sentido de la
teor@'ia de grafos. @var{A} es la matriz de adyacencia de la matriz a ser
trazada y @var{xy} es una matriz @var{n}-por-2  que contiene las 
coordenadas de los nodos de la gr@'afica.

El par@'ametro opcional @var{line_style} defin@'en el estilo de salida para
ser trazada. invocarla sin argumentos de salida la gr@'afica es trazada
directamente. de otro modo, regresa las coordenadas del trazo en @var{x}
y @var{y}.
@seealso{treeplot, etreeplot, spy}
@end deftypefn