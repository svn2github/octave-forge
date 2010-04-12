md5="30c7b99ce451d471bf50ffea84885e99";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} nargout ()
@deftypefnx {Funci@'on incorporada} {} nargout (@var{fcn_name})
Dentro de una funci@'on, regresa el n@'umenro de valores que su 
invocaci@'on espera recibir. Si se invoca con el argumento opcional
@var{fcn_name}, regresa el n@'umero m@'aximo de los valores de la
funci@'on invocada puede producir, o -1 si la fuci@'on puede producir
un n@'umero variable de valores.

For example,

@example
f ()
@end example

@noindent
causar@'a @code{nargout} retorne 0 dentro de la funci@'on @code{f} y

@example
[s, t] = f ()
@end example

@noindent
causar@'a @code{nargout} retorne 2 dentro de la funci@'on
@code{f}.

El nivel superior,@code{nargout} no est@'a definido.
@seealso{nargin, varargin, varargout}
@end deftypefn
