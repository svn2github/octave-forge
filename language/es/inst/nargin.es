md5="bcb602861b775dfc74048410ebaf5d08";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} nargin ()
@deftypefnx {Funci@'on incorporada} {} nargin (@var{fcn_name})
Dentro de una funci@'on, retorna el n@'umero de argumentos pasados 
a la funci@'on. En el nivel superior, retorna el n@'umero de argumentos 
de la l@'inea de comandos pasados a Octave. Si se llama con el argumento 
opcional @var{fcn_name}, retorna el n@'umero m@'aximo de argumentos que 
que acepta la funci@'on, o -1 si la funci@'on acepta una n@'umero 
variable de argumentos.
@seealso{nargout, varargin, varargout}
@end deftypefn
