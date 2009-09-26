md5="90d0cb7a4ffe0e5f663f450613b0b594";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{h}, @var{w}] =} freqz (@var{b}, @var{a}, @var{n}, "whole")
Retorna la matri de respuesta de frecuencia @var{h} del filtro racional IIR 
cuyos coeficientes de numerador y denominador son @var{b} y @var{a},
respectivamente. La respuesta se evalua en @var{n} frecuencias angulares 
entre 0 y
@ifinfo
 2*pi.
@end ifinfo
@iftex
@tex
 $2\pi$.
@end tex
@end iftex

@noindent
El valor de salida @var{w} es un vector de frecuencias.

Se se omite el cuarto argumento, la respuesta se evalua en las 
frecuencias entre 0 y 
@ifinfo
 pi.
@end ifinfo
@iftex
@tex
 $\pi$.
@end tex
@end iftex

Si se omite @var{n}, se asume 512.

Si se omite @var{a}, se asume que el denominador es 1 (este 
valor corresponde a un filtro FIR sencillo).

Para c@'alculos m@'as r@'apidos, la variable @var{n} deber@'ia ser m@'ultiplo 
de n@'umeros primos peque@~{n}os.

@deftypefnx {Archivo de funci@'on} {@var{h} =} freqz (@var{b}, @var{a}, @var{w})
Evalua la respuesta a las frecuencias espec@'ificas en el vector @var{w}. 
Se asume que los valores de @var{w} est@'an en radianes.

@deftypefnx {Archivo de funci@'on} {[@dots{}] =} freqz (@dots{}, @var{Fs})
Retorna las frecuencias en Hz en lugar de radians, asumiendo una tasa de muestreo 
@var{Fs}. Se se est@'a evaluando la respuesta de una frecuencia espec@'ifica 
@var{w}, estas frecuencias deber@'ian es estar representadas en Hz en lugar de radianes.

@deftypefnx {Archivo de funci@'on} {} freqz (@dots{})
Grafica el pasa banda, banda eliminada y la respuesta en fase de @var{h} en lugar 
de retornarlos.
@end deftypefn
