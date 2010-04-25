md5="f7901b1c3911e273ddb7f014ede4f8d4";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} lognrnd (@var{mu}, @var{sigma}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} lognrnd (@var{mu}, @var{sigma}, @var{sz})
Retorna una matriz de @var{r} por @var{c} de muestras aleatorias de 
la distribución lognormal con parámetros @var{mu} y @var{sigma}. 
Tanto @var{mu} como @var{sigma} deben ser escalares o de tama@~{n}o 
@var{r} por @var{c}. O si @var{sz} es un vector, crea una matriz de 
tama@~{n}o @var{sz}.

Si se omiten @var{r} y @var{c}, la matriz resultante tiene el tama@~{n}o 
común entre @var{mu} y @var{sigma}.
@end deftypefn
