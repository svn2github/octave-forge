md5="ecec3a8319408045246e0c3c04b75007";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{yi} =} griddatan (@var{x}, @var{y}, @var{xi}, @var{method}, @var{options})
Produce una malla regular a partir de datos irregulares usando interpolaci@'on. 
Esta funci@'on se define mediante @code{@var{y} = f (@var{x})}. Los puntos de 
interpolaci@'on son todos @var{xi}.

El m@'etodo de interpolaci@'on puede ser el m@'as cercano @code{"nearest"} o 
lineal @code{"linear"}. Si se omite el m@'etodo, su usa @code{"linear"}.
@seealso{griddata, delaunayn}
@end deftypefn
