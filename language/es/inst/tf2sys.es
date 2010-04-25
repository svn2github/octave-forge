md5="773eb83b523226f850d33bfd464eb235";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} tf2sys (@var{num}, @var{den}, @var{tsam}, @var{inname}, @var{outname})
Construye un sistema de estructura de datos al formato de datos 
de la función de transferencia.

@strong{Entrada}
@table @var
@item  num
@itemx den
coeficientes de numerador/denominador polinómicos
@item tsam
intervalo de muestreo. Por defecto: 0 (tiempo continuo)
@item inname
@itemx outname
nombre de las se@~{n}ales de entrada/salida; puede ser una cadena de 
caracteres o un arreglo con una sola cadena.
@end table

@strong{Salida}
@table @var
@item sys
estructura de datos del sistema
@end table

@strong{Example}
@example
octave:1> sys=tf2sys([2 1],[1 2 1],0.1);
octave:2> sysout(sys)
Entrada(s)
        1: u_1
Salida(s):
        1: y_1 (discrete)
Intervalo de muestreo: 0.1
función transferencia de:
2*z^1 + 1
-----------------
1*z^2 + 2*z^1 + 1
@end example
@end deftypefn