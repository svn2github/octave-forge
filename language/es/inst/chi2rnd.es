md5="34cb57496d8e6cff8715c693709d44de";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} chi2rnd (@var{n}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} chi2rnd (@var{n}, @var{sz})
Retorna una matriz de @var{r} by @var{c} o @code{size (@var{sz})} de
muestras aleatorias de una distribución chi-cuadrado con @var{n} 
grados de libertad. @var{n} debe ser un escalar o de tama@~{n}o @var{r} 
por @var{c}.

Si @var{r} y @var{c} se omiten, la matriz resultante será del tama@~{n}o 
de @var{n}.
@end deftypefn
