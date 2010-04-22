md5="489c9e6af85773da54ac7c2d491cb4e0";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{z} =} cumtrapz (@var{y})
@deftypefnx {Archivo de función} {@var{z} =} cumtrapz (@var{x}, @var{y})
@deftypefnx {Archivo de función} {@var{z} =} cumtrapz (@dots{}, @var{dim})

Realiza la integración numérica usando el método del trapecio.
@code{cumtrapz (@var{y})} calcula la integral acumulada de 
@var{y} a lo largo de la primera dimensión compuesta. Si se omite 
el argumento @var{x}, se asume un vector igualmente espaciado. @code{cumtrapz 
(@var{x}, @var{y})} evalua la integral acumulada con repecto a @var{x}.
 
@seealso{trapz,cumsum}
@end deftypefn
