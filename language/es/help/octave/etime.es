md5="87beecaef87652fcb919cea817be041f";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} etime (@var{t1}, @var{t2})
Retorna la diferencia (en segundos) entre dos tiempos retornados por 
@code{clock}. Por ejemplo:

@example
t0 = clock ();
 muchas operaciones despu@'es...
elapsed_time = etime (clock (), t0);
@end example

@noindent
establece la variable @code{elapsed_time} al numero de segundos desde que la 
variable @code{t0} fue establecida.
@seealso{tic, toc, clock, cputime}
@end deftypefn
