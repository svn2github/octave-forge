md5="97083a71bccb17d4e04c6b9adbbb71fe";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} gamrnd (@var{a}, @var{b}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} gamrnd (@var{a}, @var{b}, @var{sz})
Retorna una matriz de @var{r} por @var{c} o @code{size (@var{sz})} de  
muestras aleatorias de la distribuci@'on Gamma con par@'ametros @var{a} 
y @var{b}. Tanto @var{a} como @var{b} deben ser escalares o de tama@~{n}o 
@var{r} por @var{c}. 

Si se omite @var{r} y @var{c}, el tama@~{n}o de la matriz resultante es 
el tama@~{n}o com@'un entre @var{a} y @var{b}.
@seealso{gamma, gammaln, gammainc, gampdf, gamcdf, gaminv}
@end deftypefn
