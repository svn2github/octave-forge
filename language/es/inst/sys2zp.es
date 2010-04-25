md5="452d41ac731bf9d53bc0082efd31ba1b";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{zer}, @var{pol}, @var{k}, @var{tsam}, @var{inname}, @var{outname}] =} sys2zp (@var{sys})
Extrae la información de los coeficientes cero/polo/inicial de 
la estructura de datos del sistema.

Véase @command{zp} para la descripciíb de los parámetros.

@strong{Ejemplo}
@example
octave:1> sys=ss([1 -2; -1.1,-2.1],[0;1],[1 1]);
octave:2> [zer,pol,k] = sys2zp(sys)
zer = 3.0000
pol =
  -2.6953
   1.5953
k = 1
@end example
@end deftypefn
