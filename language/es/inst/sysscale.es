md5="ac76d40979ca211e4e6b9a4a0f00d964";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{retsys} =} sysscale (@var{sys}, @var{outscale}, @var{inscale}, @var{outname}, @var{inname})
Escala la Entrda/Salida de un Sistema.

@strong{Inputs}
@table @var
@item sys
Estructura del sistema.
@item outscale
@itemx inscale
Matrices constantes de dimensión adecuada.
@item outname
@itemx inname
Listas de cadenas con los nombres de salidas y entradas,
respectivamente.
@end table

@strong{Output}
@table @var
@item retsys
sistema resultante de bucle abierto:
@smallexample
      -----------    -------    -----------
u --->| inscale |--->| sys |--->| outscale |---> y
      -----------    -------    -----------
@end smallexample
@end table
Si los nombres de entrada y salida de nombres (cada uno una lista de
cadenas) no se dan y la escala de las matrices no son cuadrados, Entonces,
los nombres por defecto se le dará a las entradas y/o salida

Un mensaje de advertencia se imprime si los intentos por fuera de escala 
al agregar sistemas continuos de salidas discretas, de lo contrario
@var{yd} es un valor apropiado en el valor devuelto @var{sys}.
@end deftypefn