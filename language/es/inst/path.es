md5="398f996316a5c4ff347efc451a918fa2";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} path (@dots{})
Modifica o muestra la variable @code{LOADPATH} de Octave.

Si @var{nargin} y @var{nargout} son cero, muestra los elementos 
de code{LOADPATH} en un formato de fácil lectura. 

Si @var{nargin} es cero y @var{nargout} es mayor que cero, retorna 
el valor actual de @code{LOADPATH}.

Si @var{nargin} es mayor que cero, concatena los argumentos, 
separándolos con @code{pathsep()}, asigna la ruta interna de búsqueda 
al resultado y la retorna.

No se realizan verificaciones de elementos duplicados.
@seealso{addpath, rmpath, genpath, pathdef, savepath, pathsep}
@end deftypefn
