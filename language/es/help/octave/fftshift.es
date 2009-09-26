md5="12238b4aaed1c866ba6d80db31a77c2b";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} fftshift (@var{v})
@deftypefnx {Archivo de funci@'on} {} fftshift (@var{v}, @var{dim})
Realiza un corrimiento del vector @var{v}, para usar con las funciones 
@code{fft} y @code{ifft}, para mover la frecuencia 0 al centro del 
vector o matriz.

Si @var{v} es un vector de @math{N} elementos correspondiente a @math{N} 
muestras de tiempo espaciadas @math{Dt} entre si, entonces @code{fftshift (fft
(@var{v}))} corresponde a las frecuencias 

@example
f = ((1:N) - ceil(N/2)) / N / Dt
@end example

Si @var{v} es una matriz, los mismo aplica para filas y columnas. Si 
@var{v} es un arreglo, entonces lo mismo aplica a lo largo de cada dimensi@'on.

El argumento opcional @var{dim} puede ser usado para limitar la dimensi@'on 
a lo largo de la cual occurre la permutaci@'on.
@end deftypefn
