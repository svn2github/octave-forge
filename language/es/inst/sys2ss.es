-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{a}, @var{b}, @var{c}, @var{d}, @var{tsam}, @var{n}, @var{nz}, @var{stname}, @var{inname}, @var{outname}, @var{yd}] =} sys2ss (@var{sys})
Extrae el espacio de representación del estado del sistema de
estructura de datos.

@strong{Entradas}
@table @var
@item sys
Estructura de daots del sistemas
@end table

@strong{Salidas}
@table @var
@item a
@itemx b
@itemx c
@itemx d
Estado matrices de espacio para @var{sys}.
@item tsam
Tiempo de muestreo de @var{sys} (0 si es continuo).

@item n
@itemx nz
Número de continuidad, estados discretos (estados discretos en último
lugar en vector de estado @var{x}).
@item stname
@itemx inname
@itemx outname
Nombres de señales (listas de cadenas);  nombre de estados,
entradeas, y salidas, respectivamente.

@item yd
Vector Binario; @var{yd}(@var{ii}) es 1 si la salidad @var{y}(@var{ii})
es discreta (incluidos en la muestra); de otro modo
@var{yd}(@var{ii}) es 0.

@end table
Una advertencia de mensaje se imprime si el sistema es un sistema
mixto continuo y discreto.

@strong{Ejemplo}
@example
octave:1> sys=tf2sys([1 2],[3 4 5]);
octave:2> [a,b,c,d] = sys2ss(sys)
a =
   0.00000   1.00000
  -1.66667  -1.33333
b =
  0
  1
c = 0.66667  0.33333
d = 0
@end example
@end deftypefn
