md5="3451b6f0fd510e6cb2a7308d2b76b261";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} demo ('@var{name}',@var{n})
Ejecuta cualquier ejemplo asociado con la funci@'on '@var{name}'.  
Los ejemplos est@'an guardados en un archivo de script, o en un archivo con el 
mismo nombre sin extensi@'on en alguna parte en el path. Para mantenerlos 
separados de los scripts de c@'odigo usuales, todas las l@'ineas tienen el 
prefijo @code{%!}. Cada ejemplo se introduce con la palabra clave 'demo' 
a la izquierda del prefijo, y sin espacios. El resto del ejemplo puede contener 
c@'odigo arbitrario de Octave. Por ejemplo:

@example
   %!demo
   %! t=0:0.01:2*pi; x = sin(t);
   %! plot(t,x)
   %! %-------------------------------------------------
   %! % la ventana de figura muestra un ciclo de la funci@'on seno
@end example

N@'otese que el c@'odigo se muestra antes de ser ejecutado, un simple
comentario al final es suficiente. Generalmente, no es necesario usar 
@code{disp} o @code{printf} dentro del demo.

Los demos se ejecutan dentro del entorno de una funci@'on sin acceso a 
variable externas. Esto significa que todos los demos en una funci@'on deben
usar c@'odigos separados de inicializaci@'on. Alternativamente, se pueden 
combinar los demos dentro de un demo m@'as grande, con el c@'odigo:

@example
   %! input("Presione <enter> para continuar: ","s");
@end example

entre las secciones, pero no es recomendado. Otras t@'ecnicas 
incluyen la utilizaci@'on de m@'ultiples gr@'aficas mencionando la figuras 
entre cada una, o usando una subgr@'afica para mostrar m@'ultiples gr@'aficas 
en la misma ventana.

Tambi@'en, puesto que el demo se evalua dentro del contexto de una funci@'on, 
no se puede definir funciones dentro de un demo. En cambio, se puede usar 
@code{eval(example('function',n))} para verlas. Porque @code{eval} solamente 
evalua una l@'inea, o una sentencia si la sentencia implica m@'ultiple l@'ineas, 
se debe delimitar el demo entre "if 1 <demo stuff> endif" donde el 'if' est@'a 
en la misma l@'inea como 'demo'. Por ejemplo,

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
