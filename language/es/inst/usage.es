md5="004f84ee8c2092d19261b38620a78f7c";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} usage (@var{msg})
Imprimir el mensaje @var{msg}, precedido por la cadena @samp{usage: }:,
y fijar el estado de error interno de Octave de forma que el control
volverá al nivel superior sin evaluar más comandos. Esto es útil
para abortar de las funciones.

Después @code{usage} es evaluado, Octave imprimirá una función de
rastreo de todas las llamadas que conduce al mensaje de uso.

Usted debe utilizar esta función para informar sobre los problemas de
errores que resultan de una llamada a una función inadecuada, como
llamar a una función con un número incorrecto de argumentos o con
argumentos del tipo equivocado. Por ejemplo, la mayoría de las 
funciones de distribución con Octave comienzan con un código como
este

@example
@group
if (nargin != 2)
  usage ("foo (a, b)");
endif
@end group
@end example

@noindent
para comprobar el número correcto de argumentos.
@end deftypefn