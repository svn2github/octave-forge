md5="796a3de57014e97ce682d4628205339a";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{total}, @var{user}, @var{system}] =} cputime ();
Retorna es tiempo de CPU usado por la sesión de Octave. La primer salida es
el tiempo total empleado en la ejecución de su proceso y es igual a la suma de 
la segunda y tercera salidas, las cuales con el número de segundos de CPU empleados
en la ejecución del modo de usuario y el número de segundos de CPU empledos en la 
ejecición del modo de sistema, respectivamente. Si su sistema no tiene forma de reportar 
el uso de tiempo de CPU, @code{cputime} retorna cero para cada uno de los valores de salida.
Nótese que Octave usa tiempo de CPU para iniciar, es razonable verificar si
@code{cputime} funciona si el tiempo total de CPU es distinto de cero.
@end deftypefn
