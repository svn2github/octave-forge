md5="e5ed04b0098938fbea30f2ac1aa77292";rev="6315";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} spectral_xdf (@var{x}, @var{win}, @var{b})
Retorna el estimador de la densidad espectral de un vector de datos
@var{x}, con nombre de ventana @var{win}, y ancho de banda, @var{b}.

El nombre de ventana, p.e., @code{"triangle"} o @code{"rectangle"} se 
usa para buscar una funci@'on llamada @code{@var{win}_sw}.

Si se omite @var{win}, se usa la ventana triangular. Si se omite 
@var{b}, se usa @code{1 / sqrt (length (@var{x}))}.
@end deftypefn
