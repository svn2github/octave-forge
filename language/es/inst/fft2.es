md5="00d4c8ec18ed5ac00d14a382646e5b9b";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} fft2 (@var{a}, @var{n}, @var{m})
Calcula la FFT de dos dimensiones de @var{a} usando las subrutinas de 
@sc{Fftw}. Los argumentos opcionales @var{n} y @var{m} puede ser usado para
especificar el número de filas y columnas de @var{a} que se van a usar.  
Si alguno de estos es mayor que el tama@~{n}o de @var{a}, se redimensiona 
@var{a} y se completa con ceros.

Si @var{a} es una matriz multidemensional, cada submatriz de dos dimensiones 
de @var{a} es tratada separadamente.
@seealso {ifft2, fft, fftn, fftw}
@end deftypefn
