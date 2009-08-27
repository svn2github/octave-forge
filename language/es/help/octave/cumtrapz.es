md5="489c9e6af85773da54ac7c2d491cb4e0";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{z} =} cumtrapz (@var{y})
@deftypefnx {Archivo de funci@'on} {@var{z} =} cumtrapz (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {@var{z} =} cumtrapz (@dots{}, @var{dim})

Realiza la integraci@'on num@'erica usando el m@'etodo del trapecio.
@code{cumtrapz (@var{y})} calcula la integral acumulada de 
@var{y} a lo largo de la primera dimensi@'on compuesta. Si se omite 
el argumento @var{x}, se asume un vector igualmente espaciado. @code{cumtrapz 
(@var{x}, @var{y})} evalua la integral acumulada con repecto a @var{x}.
 
@seealso{trapz,cumsum}
@end deftypefn
