md5="f38588f0339daa44656d805318797fbe";rev="5835";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} c2d (@var{sys}, @var{opt}, @var{t})
@deftypefnx {Archivo de funci@'on} {} c2d (@var{sys}, @var{t})

Convierte la estructura de datos del sistema descrito:
@iftex
@tex
$$ \dot x = A_cx + B_cu $$
@end tex
@end iftex
@ifinfo
@example
.
x = Ac x + Bc u
@end example
@end ifinfo
en un modelo equivalente en tiempo discreto:
@iftex
@tex
$$ x_{n+1} = A_dx_n + B_du_n $$
@end tex
@end iftex
@ifinfo
@example
x[n+1] = Ad x[n] + Bd u[n]
@end example
@end ifinfo
por medio de la matriz exponencial o la transformaci@'on bilineal.

@strong{Inputs}
@table @var
@item sys
estructura de datos del sistema (puede tener tanto subsistemas 
continuos como de tiempo discreto)
@item opt
argumento de tipo cadena; opci@'on de conversi@'on (argumento
opcional; se puede omitir como se muestra arriba)
@table @code
@item "ex"
usa la matriz exponencial (predeterminado)
@item "bi"
usa la transformaci@'on bilineal
@iftex
@tex
$$ s = { 2(z-1) \over T(z+1) } $$
@end tex
@end iftex
@ifinfo
@example
    2(z-1)
s = -----
    T(z+1)
@end example
@end ifinfo
FIXME: This option exits with an error if @var{sys} is not purely
continuous. (The @code{ex} option can handle mixed systems.)
@item "matched"
Usa la transformaci@'on equivalente de emparejamiento de polos/
ceros (actualmente solo funciona con sistemas puramente continuos 
@acronym{SISO}).
@end table
@item t
tiempo de muestreo; requerido si @var{sys} es puramente continuo.

@strong{N@'otese} que si el segundo argumento no es una cadena, 
@code{c2d()} asume que el segundo argumento es @var{t} y ejecuta 
la revisi@'on de los argumentos apropiados.
@end table

@strong{Output}
@table @var
@item dsys 
tiempo discreto equivalente via sostenimiento de orden cero,
muestreo cada @var{t} segundos.
@end table

Esta funci@'on a@~{n}ade el sufijo @code{_d}
a los nombres de los nuevos estados discretos.
@end deftypefn
