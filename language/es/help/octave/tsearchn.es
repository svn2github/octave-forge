md5="28baa87ad2b1c6ab0f05e2f054d2892f";rev="6315";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{idx}, @var{p}] =} tsearchn (@var{x}, @var{t}, @var{xi})
Busca en la envolvente convexa adjunta de Delaunay. Para @code{@var{t} =
delaunayn (@var{x})}, encuentra el @'indice @var{t} con los puntos @var{xi}. 
Para los puntos exteriores de la envolvente convexa, @var{idx} es NaN. Si se 
solicita, @code{tsearchn} tambi@'en retorna las coordenadas baric@'entricas 
@var{p} de los tri@'angulos adjuntos.
@seealso{delaunay, delaunayn}
@end deftypefn
