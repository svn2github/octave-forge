md5="398f996316a5c4ff347efc451a918fa2";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} path (@dots{})
Modifica o muestra la variable @code{LOADPATH} de Octave.

Si @var{nargin} y @var{nargout} son cero, muestra los elementos 
de code{LOADPATH} en un formato de f@'acil lectura. 

Si @var{nargin} es cero y @var{nargout} es mayor que cero, retorna 
el valor actual de @code{LOADPATH}.

Si @var{nargin} es mayor que cero, concatena los argumentos, 
separ@'andolos con @code{pathsep()}, asigna la ruta interna de b@'usqueda 
al resultado y la retorna.

No se realizan verificaciones de elementos duplicados.
@seealso{addpath, rmpath, genpath, pathdef, savepath, pathsep}
@end deftypefn
