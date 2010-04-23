md5="b53f872eb77231555b501e6948d96795";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} geornd (@var{p}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} geornd (@var{p}, @var{sz})
Retorna una matriz de @var{r} por @var{c} muestras aleatorias de la 
distribución geométrica con parámetro @var{p}, el cual debe ser 
un escalar o de tama@~{n}o @var{r} por @var{c}.

Si se suministran @var{r} y @var{c}, crea una matriz con @var{r} filas y 
@var{c} columnas. O si @var{sz} es un vector, crea una matriz de tama@~{n}o 
@var{sz}.
@end deftypefn
