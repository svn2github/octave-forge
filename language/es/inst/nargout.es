md5="30c7b99ce451d471bf50ffea84885e99";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} nargout ()
@deftypefnx {Función incorporada} {} nargout (@var{fcn_name})
Dentro de una función, regresa el númenro de valores que su 
invocación espera recibir. Si se invoca con el argumento opcional
@var{fcn_name}, regresa el número máximo de los valores de la
función invocada puede producir, o -1 si la fución puede producir
un número variable de valores.

For example,

@example
f ()
@end example

@noindent
causará @code{nargout} retorne 0 dentro de la función @code{f} y

@example
[s, t] = f ()
@end example

@noindent
causará @code{nargout} retorne 2 dentro de la función
@code{f}.

El nivel superior,@code{nargout} no está definido.
@seealso{nargin, varargin, varargout}
@end deftypefn
