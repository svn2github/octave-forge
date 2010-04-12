md5="33f78343957e12cf824037fb5c3bc6c6";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} fftfilt (@var{b}, @var{x}, @var{n})

Con dos argumentos, @code{fftfilt} filtra @var{x} con el filtro FIR 
@var{b} usando la FFT. 

Dado el tercer argumento opcional, @var{n}, @code{fftfilt} use el 
m@'etodo de superposici@'on aditiva para filtrar @var{x} con @var{b} 
usando una FFT de N puntos.

Si @var{x} es una matriz, filtra cada columna de la matriz.
@end deftypefn
