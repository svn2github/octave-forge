md5="ad58835d337aa5842fb1ab8706522fb9";rev="6351";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} trnd (@var{n}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} trnd (@var{n}, @var{sz})
Retorna una matriz de @var{r} por @var{c} muestras aleatorias de la 
distribuci@'on t (Student) con @var{n} grados de libertad. La variable 
@var{n} debe ser un escalar o de tama@~{n}o @var{r} por @var{c}. O si 
@var{sz} es un vector, crea una matriz de tama@~{n}o @var{sz}.

Si se omiten @var{r} y @var{c}, el tama@~{n}o de la matriz resultante es 
@var{n}.
@end deftypefn
