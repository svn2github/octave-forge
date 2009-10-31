md5="68a9defd15a0a9e798bbf83e7b096222";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{retval}, @var{u}] =} is_observable (@var{a}, @var{c}, @var{tol})
@deftypefnx {Archivo de funci@'on} {[@var{retval}, @var{u}] =} is_observable (@var{sys}, @var{tol})
Retorna 1 si el sistema @var{sys} o el par (@var{a}, @var{c}) es 
observable, 0 en otro caso.

El valor predeterminado de @var{tol} es @code{tol = 10*norm(a,'fro')*eps}.

V@'ease @command{is_controllable} para la descripci@'on detallada de los 
argumentos y los valores predetermiandos.
@seealso{size, rows, columns, length, ismatrix, isscalar, isvector}
@end deftypefn
