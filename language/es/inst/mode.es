md5="402c7b84f2641cebdb4d885988120cba";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{m}, @var{f}, @var{c}] =} mode (@var{x}, @var{dim})
Cuenta el valor que aparece con mayor frecuencia. La funci@'on @code{mode} 
cuenta la frecuencia a lo largo de la primera dimensi@'on no singleton y 
y si dos o mas valores tienen la misma frecuencia, retorna el menor de los 
dos en @var{m}. La dimensi@'on a lo largo de la cual se cuenta se puede 
especificar mediante el par@'ametro @var{dim}.

La variable @var{f} cuenta la frecuencia de cada uno de los elementos que 
ocurren con mayor frecuencia. El arreglo de celdas @var{c} contiene todos 
los elementos con m@'axima frecuencia.
@end deftypefn
