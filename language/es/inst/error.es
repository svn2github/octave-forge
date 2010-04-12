md5="828085a751f08090b4319a11931b6261";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} error (@var{template}, @dots{})
@deftypefnx {Funci@'on incorporada} {} error (@var{id}, @var{template}, @dots{})
Le da formato a los argumentos opcionales bajo control de la cadena de plantilla 
@var{template} usindo las mismas reglas como en la familia de funciones @code{printf} 
(@pxref{Formatted Output}) e imprime el mensaje resultante 
en la salida @code{stderr}. El mensaje se ajusta mendiante la cadena de caracteres 
@samp{error: }.

Cuando se llama @code{error}, tambi@'en se establece el estado de error interno de Octave 
tal que el control retornar@'a al niverl superior sin evaluar los comandos nuevamente. 
Esto es @'util para terminar la ejecuci@'on de funciones o scripts.

Si el mensaje de error no termina con el caracter de cambio de l@'inea, Octave imprime 
el restreo de todos los llamados de funciones que conducen al error. Por ejemplo, 
dadas las siguientes definiciones de funciones: 

@example
@group
function f () g (); end
function g () h (); end
function h () nargin == 1 || error ("nargin != 1"); end
@end group
@end example

@noindent
al llamar la funci@'on @code{f}, se retorna una lista de mensajes que 
pueden ayudar a identificar r@'apidamente la ubicaci@'on del error: 

@smallexample
@group
f ()
error: nargin != 1
error: evaluating index expression near line 1, column 30
error: evaluating binary operator `||' near line 1, column 27
error: called from `h'
error: called from `g'
error: called from `f'
@end group
@end smallexample

Si el mensaje de error termian con el caracter de cambio de l@'inea, imprime el 
mensaje pero no muestra el rastro de mensajes hasta el nivel superior. Por ejemplo, 
modificando el mensaje de error en el ejemplo anterior, Octave solo imprime el 
mensaje: 

@example
@group
function h () nargin == 1 || error ("nargin != 1\n"); end
f ()
error: nargin != 1
@end group
@end example
@end deftypefn
