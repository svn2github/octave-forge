md5="a966245ea2c32a7f1169948f829a5c59";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} chisquare_rnd (@var{n}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} chisquare_rnd (@var{n}, @var{sz})
Retorna una matriz de @var{r} by @var{c} o @code{size (@var{sz})} de
muestras aleatorias de una distribución chi-cuadrado con @var{n} 
grados de libertad. @var{n} debe ser un escalar o de tama@~{n}o @var{r} 
por @var{c}.

Si @var{r} y @var{c} se omiten, la matriz resultante será del tama@~{n}o 
de @var{n}.
@end deftypefn
