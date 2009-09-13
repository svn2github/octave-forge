md5="9586849998638efa8647cb73c6e48c76";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{x}, @var{y}, @var{z}] =} ellipsoid (@var{xc},@var{yc}, @var{zc}, @var{xr}, @var{yr}, @var{zr}, @var{n})
@deftypefnx {Archivo de funci@'on} {} ellipsoid (@var{h}, @dots{})
Genera tres matrices en formato @code{meshgrid} las cuales definen un 
elipsoide. Cuando se llama sin artumentos de retorno, @code{ellipsoid} ejecuta 
directamente @code{surf (@var{x}, @var{y}, @var{z})}. Si se pasa un manejador de ejes 
como primer argumento, se grafica la superficie en los ejes dados.
@seealso{sphere}
@end deftypefn