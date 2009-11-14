md5="90cb3dc00d57d60e3aede69199dcdfd2";rev="6461";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} interpft (@var{x}, @var{n})
@deftypefnx {Archivo de funci@'on} {} interpft (@var{x}, @var{n}, @var{dim})

Interpolaci@'on de Fourier. Si @var{x} es un vector, se toman @var{n} nuevas  
 muestras de @var{x}. Se asume que los datos en @var{x} est@'an equiespaciados. 
Si @var{x} es un arreglo, realiza la operaci@'on en cada columna del 
arreglo separadamente. Si se especifica @var{dim}, interpola en la dimensi@'on 
de @var{dim}.

La funci@'on @code{interpft} asume que la funci@'on interpolada es peri@'odica, 
al igual que los puntos finales de la interpolaci@'on.

@seealso{interp1}
@end deftypefn
