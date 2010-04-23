md5="3451b6f0fd510e6cb2a7308d2b76b261";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} demo ('@var{name}',@var{n})
Ejecuta cualquier ejemplo asociado con la función '@var{name}'.  
Los ejemplos están guardados en un archivo de script, o en un archivo con el 
mismo nombre sin extensión en alguna parte en el path. Para mantenerlos 
separados de los scripts de código usuales, todas las líneas tienen el 
prefijo @code{%!}. Cada ejemplo se introduce con la palabra clave 'demo' 
a la izquierda del prefijo, y sin espacios. El resto del ejemplo puede contener 
código arbitrario de Octave. Por ejemplo:

@example
   %!demo
   %! t=0:0.01:2*pi; x = sin(t);
   %! plot(t,x)
   %! %-------------------------------------------------
   %! % la ventana de figura muestra un ciclo de la función seno
@end example

Nótese que el código se muestra antes de ser ejecutado, un simple
comentario al final es suficiente. Generalmente, no es necesario usar 
@code{disp} o @code{printf} dentro del demo.

Los demos se ejecutan dentro del entorno de una función sin acceso a 
variable externas. Esto significa que todos los demos en una función deben
usar códigos separados de inicialización. Alternativamente, se pueden 
combinar los demos dentro de un demo más grande, con el código:

@example
   %! input("Presione <enter> para continuar: ","s");
@end example

entre las secciones, pero no es recomendado. Otras técnicas 
incluyen la utilización de múltiples gráficas mencionando la figuras 
entre cada una, o usando una subgráfica para mostrar múltiples gráficas 
en la misma ventana.

También, puesto que el demo se evalua dentro del contexto de una función, 
no se puede definir funciones dentro de un demo. En cambio, se puede usar 
@code{eval(example('function',n))} para verlas. Porque @code{eval} solamente 
evalua una línea, o una sentencia si la sentencia implica múltiple líneas, 
se debe delimitar el demo entre "if 1 <demo stuff> endif" donde el 'if' está 
en la misma línea como 'demo'. Por ejemplo,

@example
  %!demo if 1
  %!  function y=f(x)
  %!    y=x;
  %!  endfunction
  %!  f(3)
  %! endif
@end example
@seealso{test, example}
@end deftypefn
