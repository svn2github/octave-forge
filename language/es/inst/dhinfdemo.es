md5="c7b777119b2f8cced492fa52977b2ffe";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} dhinfdemo ()
Muestra las funciones disponibles para dise@~{n}ar el controlador 
@iftex
@tex
$ { \cal H }_\infty $
@end tex
@end iftex
@ifinfo
H-infinity
@end ifinfo
discreto. Este no es un dise@~{n}o discreto verdadero. El dise@~{n}o
se realiza en tiempo continuo mientras que el efecto del muestro se 
describe mediante trasnformaciones bilineales del sistema muestreado.
Este método funciona bien si el periodo de muestro es "peque@~{n}o" 
comparado con las constantes de tiempo de planta.

Planta continua:
@iftex
@tex
$$ G(s) = { 1 \over (s+2) (s+1) } $$
@end tex
@end iftex
@ifinfo
@example
@group
                  1
     G(s) = --------------
            (s + 2)(s + 1)
@end group
@end example
@end ifinfo

Planta discretizada con @acronym{ZOH} (Periodo de muestreo = @var{Ts} = 1 segundo):
@iftex
@tex
$$ G(z) = { 0.39958z + 0.14700 \over (z - 0.36788) (z - 0.13533) } $$
@end tex
@end iftex
@ifinfo
@example
@group
                0.39958z + 0.14700
     G(z) = --------------------------
            (z - 0.36788)(z - 0.13533)
@end group
@end example
@end ifinfo

@example
@group
                              +----+
         -------------------->| W1 |---> v1
     z   |                    +----+
     ----|-------------+                   || T   ||     => min.
         |             |                       vz   infty
         |    +---+    v      +----+
         *--->| G |--->O--*-->| W2 |---> v2
         |    +---+       |   +----+
         |                |
         |    +---+       |
         -----| K |<-------
              +---+
@end group
@end example

@noindent
W1 y W2 son las funciones ponderadas de robustes y desempe@~{n}o.
@end deftypefn
