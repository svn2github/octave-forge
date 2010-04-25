md5="ba695687fff89f21c8c3e85ce435f1ec";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{z} =} trapz (@var{y})
@deftypefnx {Archivo de función} {@var{z} =} trapz (@var{x}, @var{y})
@deftypefnx {Archivo de función} {@var{z} =} trapz (@dots{}, @var{dim})
Realiza integración numérica usando el método trapezoidal. 
La función @code{trapz(@var{y})} calcula la integral de @var{y} a lo 
largo de la primera dimensión no singleton. Si se omite el argumento 
@var{x}, se asume un vetor igualmente espaciado. La función 
@code{trapz (@var{x}, @var{y})} evalua la integral con respecto a @var{x}.
@seealso{cumtrapz}
@end deftypefn
