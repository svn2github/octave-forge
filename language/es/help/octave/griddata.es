md5="71b7702f2086102585e28aedf7ef2756";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{zi} =} griddata (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi}, @var{method})
@deftypefnx {Archivo de funci@'on} {[@var{xi}, @var{yi}, @var{zi}] =} griddata (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi}, @var{method})
Genera una malla regular de datos irregulares usando interpolaci@'on.
La funci@'on esta definida por @code{@var{z} = f (@var{x}, @var{y})}.
Los puntos de interpolaci@'on son todos @code{(@var{xi}, @var{yi})}. S@'i
@var{xi}, @var{yi} son vectores entonces son tomados en una malla 2D. 

El m@'etodo de interpolaci@'on puede ser @code{"nearest"}, @code{"cubic"}
o @code{"linear"}. Si el m@'etodo es omitido por defecto ser@'a 
@code{"linear"}.
@seealso{delaunay}
@end deftypefn
