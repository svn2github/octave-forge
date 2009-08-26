md5="afee366501d78517bcc09c25754d7579";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} buildssic (@var{clst}, @var{ulst}, @var{olst}, @var{ilst}, @var{s1}, @var{s2}, @var{s3}, @var{s4}, @var{s5}, @var{s6}, @var{s7}, @var{s8})

Forma un sistema complejo arbitrario (de lazo abierto o cerrado) en
forma de espacios de estados de varios sistemas. @command{buildssic} puede
(apesar de su cr@'iptica sintaxis) integrar funciones de transferencia 
facilmente a partir de un diagrama de bloques complejo en un sistema sencillo con un solo llamado.
Esta funci@'on es @'util especialmente para contruir interconexiones de lazo 
abierto para dise@~nos
@iftex
@tex
$ { \cal H }_\infty $ y $ { \cal H }_2 $
@end tex
@end iftex
@ifinfo
H-infinito y H-2
@end ifinfo
o para lazos cerrados con estos controles.

Aunque esta funci@'on es de uso general, la utilizaci@'on de @command{sysgroup}
@command{sysmult}, @command{sysconnect} y similares se recomienda para 
operaciones est@'andares ya que pueden manejar sistemas discretos mixtos 
y continuos y tambi@'en los nombres de las entradas, salidas, y estados.

Los par@'ameteros consisten en cuatro listas que describen las conexiones, 
salidas y entradas y hasta 8 sistemas @var{s1}--@var{s8}.
Formato de las listas:
@table @var
@item  clst
Lista de conexiones, describe la se@~nal de entrada de
cada sistemas. El n@'umero m@'aximo de filas de @var{clst} es
igual a la suma de todas las entradas de @var{s1}--@var{s8}.

Example:
@code{[1 2 -1; 2 1 0]} implica que: la entrada nueva 1 es la entrada antigua 1
+ salida 2 - salida 1, y la entrada nueva 2 es entrada antigua 2
+ salida 1. El orden de las filas es arbitrario.

@item ulst
Si no se vac@'ia las antiguas entradas en el vector @var{ulst} se agregar@'a
a las salidas. Esto es necesario si se quiere ``estirar'' la entrada de un 
sistema. Los elementos son los n@'umero de entrada de @var{s1}--@var{s8}.

@item olst
Lista de salida, especifica las salidas de los sistemas resultantes. 
Los elementos son n@'umeros de salida @var{s1}--@var{s8}.
Los n@'umeros pueden ser negativos y pueden aparecer en cualquier orden. 
Una matriz vac@'ia promedia todas las salidas.

@item ilst
Lista de entrada, especifica las entradas del sistema resultante. 
Elements are input numbers of @var{s1}--@var{s8}.
Los n@'umeros pueden ser negativos y pueden aparecer en cualquier orden. 
Una matriz vac@'ia promedia todas las entradas.
@end table

Ejemplo: Sistema muy sencillo de lazo cerrado.
@example
@group
w        e  +-----+   u  +-----+
 --->o--*-->|  K  |--*-->|  G  |--*---> y
     ^  |   +-----+  |   +-----+  |
   - |  |            |            |
     |  |            +----------------> u
     |  |                         |
     |  +-------------------------|---> e
     |                            |
     +----------------------------+
@end group
@end example

El sistema de lazo cerrado @var{GW} puede ser obtenido mediante
@example
GW = buildssic([1 2; 2 -1], 2, [1 2 3], 2, G, K);
@end example
@table @var
@item clst
1ra fila: conecta la entrada 1 (@var{G}) con la salida 2 (@var{K}).
2da fila: conecta la entrada 2 (@var{K}) con la salida negativa 1 (@var{G}).
@item ulst
A@~nade la entrada de 2 (@var{K}) a el n@'umero de salidas.
@item olst
Salidas son salida de 1 (@var{G}), 2 (@var{K}) y 
la salida a@~nadida 3 (from @var{ulst}).
@item ilst
La @'unica entrada es 2 (@var{K}).
@end table

Aqui, un ejemplo real:
@example
@group
                         +----+
    -------------------->| W1 |---> v1
z   |                    +----+
----|-------------+
    |             |
    |    +---+    v      +----+
    *--->| G |--->O--*-->| W2 |---> v2
    |    +---+       |   +----+
    |                |
    |                v
   u                  y
@end group
@end example
@iftex
@tex
$$ { \rm min } \Vert GW_{vz} \Vert _\infty $$  
@end tex
@end iftex
@ifinfo
@example
min || GW   ||
         vz   infty
@end example
@end ifinfo

El sistema de lazo cerrado @var{GW} 
@iftex
@tex
from $ [z, u]^T $ to $ [v_1, v_2, y]^T $
@end tex
@end iftex
@ifinfo
from [z, u]' to [v1, v2, y]' 
@end ifinfo
puede ser obtenido mediante (todos los sistemas @acronym{SISO}):
@example
GW = buildssic([1, 4; 2, 4; 3, 1], 3, [2, 3, 5],
               [3, 4], G, W1, W2, Uno);
@end example
donde ``Uno'' es la funci@'on de ganancia unitaria (auxiliar) de orden 0.
(p.e. @code{Uno = ugain(1);})
@end deftypefn
