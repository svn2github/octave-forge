md5="bcb602861b775dfc74048410ebaf5d08";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} nargin ()
@deftypefnx {Función incorporada} {} nargin (@var{fcn_name})
Dentro de una función, retorna el número de argumentos pasados 
a la función. En el nivel superior, retorna el número de argumentos 
de la línea de comandos pasados a Octave. Si se llama con el argumento 
opcional @var{fcn_name}, retorna el número máximo de argumentos que 
que acepta la función, o -1 si la función acepta una número 
variable de argumentos.
@seealso{nargout, varargin, varargout}
@end deftypefn
