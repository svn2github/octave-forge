md5="97083a71bccb17d4e04c6b9adbbb71fe";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} gamrnd (@var{a}, @var{b}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} gamrnd (@var{a}, @var{b}, @var{sz})
Retorna una matriz de @var{r} por @var{c} o @code{size (@var{sz})} de  
muestras aleatorias de la distribución Gamma con parámetros @var{a} 
y @var{b}. Tanto @var{a} como @var{b} deben ser escalares o de tama@~{n}o 
@var{r} por @var{c}. 

Si se omite @var{r} y @var{c}, el tama@~{n}o de la matriz resultante es 
el tama@~{n}o común entre @var{a} y @var{b}.
@seealso{gamma, gammaln, gammainc, gampdf, gamcdf, gaminv}
@end deftypefn
