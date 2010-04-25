md5="680b748bfe822067371e62864ab6c589";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} spectral_adf (@var{c}, @var{win}, @var{b})
Retorna un estimador de la densidad espectral del vector de autocovariances @var{c}, 
nombre de ventana @var{win}, y ancho de banda @var{b}.

El nombre de la ventana, p.e., @code{"triangle"} o @code{"rectangle"} es 
usado para buscar una función llamada @code{@var{win}_sw}.

Si se omite @var{win}, se usa la ventana triangular. Si se omite @var{b}, 
se usa @code{1 / sqrt (length (@var{x}))}.
@end deftypefn
