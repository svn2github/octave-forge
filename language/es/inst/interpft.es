md5="90cb3dc00d57d60e3aede69199dcdfd2";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} interpft (@var{x}, @var{n})
@deftypefnx {Archivo de función} {} interpft (@var{x}, @var{n}, @var{dim})

Interpolación de Fourier. Si @var{x} es un vector, se toman @var{n} nuevas  
 muestras de @var{x}. Se asume que los datos en @var{x} están equiespaciados. 
Si @var{x} es un arreglo, realiza la operación en cada columna del 
arreglo separadamente. Si se especifica @var{dim}, interpola en la dimensión 
de @var{dim}.

La función @code{interpft} asume que la función interpolada es periódica, 
al igual que los puntos finales de la interpolación.

@seealso{interp1}
@end deftypefn
