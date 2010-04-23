md5="30a117cf3f9b215acff5dc3d4f8c9469";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} exponential_rnd (@var{lambda}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} exponential_rnd (@var{lambda}, @var{sz})
Retorna una matriz de @var{r} por @var{c} de muestras aleatorias de la 
distribución exponencial con parámetro @var{lambda}, el cual debe ser 
escalar o de tama@~{n}o @var{r} por @var{c}. O si @var{sz} es un vector, 
crea una matriz de tama@~{n}o @var{sz}.

Si se omiten @var{r} y @var{c}, el tama@~{n}o de la matriz de resultado es 
el mismo de @var{lambda}.
@end deftypefn
