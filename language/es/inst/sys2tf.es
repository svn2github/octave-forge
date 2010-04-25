md5="046d71b4fb4d330ea2fd1a764c554018";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{num}, @var{den}, @var{tsam}, @var{inname}, @var{outname}] =} sys2tf (@var{sys})
Extrae los datos de la función de transferencia de la estructura de datos 
del sistema.

Véase el comando @command{tf} para la descripción de los parámetros. 

@strong{Ejemplo}
@example
octave:1> sys=ss([1 -2; -1.1,-2.1],[0;1],[1 1]);
octave:2> [num,den] = sys2tf(sys)
num = 1.0000  -3.0000
den = 1.0000   1.1000  -4.3000
@end example
@end deftypefn
