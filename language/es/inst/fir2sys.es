md5="3e22563d39ba230e58e267e74f04cd91";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} fir2sys (@var{num}, @var{tsam}, @var{inname}, @var{outname})
Construye una estructura de datos de sistema de descripción @acronym{FIR} 

@strong{Inputs}
@table @var
@item num
vector de coeficientes
@ifinfo
[c0, c1, @dots{}, cn]
@end ifinfo
@iftex
@tex
$ [c_0, c_1, \ldots, c_n ]$
@end tex
@end iftex
de el @acronym{SISO} @acronym{FIR} función de transferencia
@ifinfo
C(z) = c0 + c1*z^(-1) + c2*z^(-2) + @dots{} + cn*z^(-n)
@end ifinfo
@iftex
@tex
$$ C(z) = c_0 + c_1z^{-1} + c_2z^{-2} + \ldots + c_nz^{-n} $$
@end tex
@end iftex

@item tsam
muestra el tiempo (predetermiando: 1)

@item inname
nombre de la se@~{n}al de entrada; puede ser una cadena o lista con una
entrada sencilla.

@item outname
nombre de la se@~{n}al de salida; puede ser una cadena o lista con una
entrada sencilla.
@end table

@strong{Output}
@table @var
@item sys
estructura de información del sistema
@end table

@strong{Example}
@example
octave:1> sys = fir2sys([1 -1 2 4],0.342,\
> "A/D input","filter output");
octave:2> sysout(sys)
Input(s)
        1: A/D input

Output(s):
        1: filter output (discrete)

Sampling interval: 0.342
transfer function form:
1*z^3 - 1*z^2 + 2*z^1 + 4
-------------------------
1*z^3 + 0*z^2 + 0*z^1 + 0
@end example
@end deftypefn
