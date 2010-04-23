md5="2d596fbaa29aca07e42ea40727d13ff7";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} frnd (@var{m}, @var{n}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} frnd (@var{m}, @var{n}, @var{sz})
Retorna una matriz de @var{r} por @var{c} de muestra aleatorias de la 
distribución F con @var{m} y @var{n} grados de libertad. Tanto 
@var{m} como @var{n} deben ser escalares o de tama@~{n}o @var{r} por @var{c}.
Si @var{sz} es un vector, retorna las muestras aleatorias en una matriz 
de tama@~{n}o @var{sz}.

Si se omite @var{r} y @var{c}, el tama@~{n}o de la matriz resultante será 
el tama@~{n}o común de @var{m} y @var{n}.
@end deftypefn
