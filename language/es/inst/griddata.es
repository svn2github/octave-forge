md5="71b7702f2086102585e28aedf7ef2756";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{zi} =} griddata (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi}, @var{method})
@deftypefnx {Archivo de función} {[@var{xi}, @var{yi}, @var{zi}] =} griddata (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi}, @var{method})
Genera una malla regular de datos irregulares usando interpolación.
La función esta definida por @code{@var{z} = f (@var{x}, @var{y})}.
Los puntos de interpolación son todos @code{(@var{xi}, @var{yi})}. Sí
@var{xi}, @var{yi} son vectores entonces son tomados en una malla 2D. 

El método de interpolación puede ser @code{"nearest"}, @code{"cubic"}
o @code{"linear"}. Si el método es omitido por defecto será 
@code{"linear"}.
@seealso{delaunay}
@end deftypefn
