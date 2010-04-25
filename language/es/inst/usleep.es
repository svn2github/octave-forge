md5="473b0d7686601b3a39fa1b4a057bda8a";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} usleep (@var{microseconds})
Suspende la ejecuciq'on del programa por un determiando número de 
microsegundos. En sistemas donde no es posible suspender la 
ejecución por periodos de tiempo menores que un segundo, 
@code{usleep} pausa la ejecución por 
@code{round (@var{microseconds} / 1e6)} segundos.
@end deftypefn
