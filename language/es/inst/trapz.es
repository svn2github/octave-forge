md5="ba695687fff89f21c8c3e85ce435f1ec";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{z} =} trapz (@var{y})
@deftypefnx {Archivo de funci@'on} {@var{z} =} trapz (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {@var{z} =} trapz (@dots{}, @var{dim})
Realiza integraci@'on num@'erica usando el m@'etodo trapezoidal. 
La funci@'on @code{trapz(@var{y})} calcula la integral de @var{y} a lo 
largo de la primera dimensi@'on no singleton. Si se omite el argumento 
@var{x}, se asume un vetor igualmente espaciado. La funci@'on 
@code{trapz (@var{x}, @var{y})} evalua la integral con respecto a @var{x}.
@seealso{cumtrapz}
@end deftypefn
