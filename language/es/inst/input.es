-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} input (@var{prompt})
@deftypefnx {Funci@'on incorporada} {} input (@var{prompt}, "s")
Imprimir un mensaje y esperar a la entrada del usuario.
Por ejemplo,

@example
input ("Elija un número, ¡cualquier número! ")
@end example

@noindent
imprime el mensaje

@example
Pick a number, any number!Elija un número, ¡cualquier número!
@end example

@noindent
y espera a que el usuario introduzca un valor. La cadena introducida por
el usuario se evalúa como una expresión, lo que puede ser una constante
literal, un nombre de variable, o cualquier expresión válida otros.

Actualmente, @code{input} sólo devuelve un valor, independientemente del
número de valores producidos por la evaluación de la expresión.

Si sólo está interesado en obtener un valor de cadena literal, puede 
llamar @code{input} con la cadena de caracteres @code{"s"} como el segundo
argumento. Esto le dice a Octave para devolver la cadena introducida por
el usuario directamente, sin evaluar primero.

Porque puede haber salida en espera de ser mostrada por el localizador,
es una buena idea llamar siempre @code{fflush (stdout)} antes de llamar 
@code{input}. Esto asegurará que todos los resultados pendientes se 
escriban en la pantalla antes de su mensaje.
@end deftypefn
