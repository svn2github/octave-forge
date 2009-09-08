md5="1a1a375796d9a1442298ec7212e210b4";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} discrete_rnd (@var{n}, @var{v}, @var{p})
@deftypefnx {Archivo de funci@'on} {} discrete_rnd (@var{v}, @var{p}, @var{r}, @var{c})
@deftypefnx {Archivo de funci@'on} {} discrete_rnd (@var{v}, @var{p}, @var{sz})
Genera un vector fila con una muestra aleatoria de tama@~{n}o @var{n} a partir 
de la distribuci@'on univariada la cual asume los valores en @var{v} con 
probabilidades @var{p}. @var{n} debe ser un escalar.

Si se suministran @var{r} y @var{c}, crea una matriz con @var{r} filas y 
@var{c} columnas. O si @var{sz} es un vector, crea una matriz de tama@~{n}o 
@var{sz}.
@end deftypefn
