md5="28baa87ad2b1c6ab0f05e2f054d2892f";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{idx}, @var{p}] =} tsearchn (@var{x}, @var{t}, @var{xi})
Busca en la envolvente convexa adjunta de Delaunay. Para @code{@var{t} =
delaunayn (@var{x})}, encuentra el índice @var{t} con los puntos @var{xi}. 
Para los puntos exteriores de la envolvente convexa, @var{idx} es NaN. Si se 
solicita, @code{tsearchn} también retorna las coordenadas baricéntricas 
@var{p} de los triángulos adjuntos.
@seealso{delaunay, delaunayn}
@end deftypefn
