md5="ecec3a8319408045246e0c3c04b75007";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{yi} =} griddatan (@var{x}, @var{y}, @var{xi}, @var{method}, @var{options})
Produce una malla regular a partir de datos irregulares usando interpolación. 
Esta función se define mediante @code{@var{y} = f (@var{x})}. Los puntos de 
interpolación son todos @var{xi}.

El método de interpolación puede ser el más cercano @code{"nearest"} o 
lineal @code{"linear"}. Si se omite el método, su usa @code{"linear"}.
@seealso{griddata, delaunayn}
@end deftypefn
