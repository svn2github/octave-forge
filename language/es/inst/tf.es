md5="9c938dbb0986311c984ad9c1cc2028f1";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} tf (@var{num}, @var{den}, @var{tsam}, @var{inname}, @var{outname})
Construye un sistema de estructura de datos al formato de datos 
de la funci@'on de transferencia.

@strong{Entrada}
@table @var
@item  num
@itemx den
coeficientes de numerador/denominador polinomicos
@item tsam
intervalo de muestreo. por defecto: 0 (tiempo continuo)
@item inname
@itemx outname
nombre de las se@~{n}ales de entrada/salida; puede ser una cadena de 
caracteres o un arreglo con una sola cadena.
@end table

@strong{Salida}
@var{sys} = estructura de datos del sistema

@strong{Example}
@example
octave:1> sys=tf([2 1],[1 2 1],0.1);
octave:2> sysout(sys)
Entrada(s)
        1: u_1
Salida(s):
        1: y_1 (discrete)
Intervalo de muestreo: 0.1
funci@'on transferencia de:
2*z^1 + 1
-----------------
1*z^2 + 2*z^1 + 1
@end example
@end deftypefn