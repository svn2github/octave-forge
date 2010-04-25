md5="402c7b84f2641cebdb4d885988120cba";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{m}, @var{f}, @var{c}] =} mode (@var{x}, @var{dim})
Cuenta el valor que aparece con mayor frecuencia. La función @code{mode} 
cuenta la frecuencia a lo largo de la primera dimensión no singleton y 
y si dos o mas valores tienen la misma frecuencia, retorna el menor de los 
dos en @var{m}. La dimensión a lo largo de la cual se cuenta se puede 
especificar mediante el parámetro @var{dim}.

La variable @var{f} cuenta la frecuencia de cada uno de los elementos que 
ocurren con mayor frecuencia. El arreglo de celdas @var{c} contiene todos 
los elementos con máxima frecuencia.
@end deftypefn
