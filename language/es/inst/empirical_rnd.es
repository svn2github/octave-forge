md5="5cc6d041b5b997994f0ed99dca7c32b9";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} empirical_rnd (@var{n}, @var{data})
@deftypefnx {Archivo de función} {} empirical_rnd (@var{data}, @var{r}, @var{c})
@deftypefnx {Archivo de función} {} empirical_rnd (@var{data}, @var{sz})
Generate una muestra inicial de tama@~{n}o @var{n} de la distribución 
empírica obtenida a partir de la muestra univariada @var{data}.

Si se dan @var{r} y @var{c}, crea una matriz de @var{r} filas y 
@var{c} columnas. O si @var{sz} es un vector, crea una matriz de 
tama@~{n}o @var{sz}.
@end deftypefn
