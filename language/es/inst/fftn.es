md5="c46199e477eda0ddf807069b881a6fb5";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} fftn (@var{a}, @var{size})
Calcula la FFT de N dimensiones de @var{a} usando las subrutinas de 
@sc{Fftw}. El vector argumento opcional @var{size} puede ser usado para 
especificar las dimensiones del arreglo que se va a usar. Si un elemento 
de @var{size} es más peque@~{n}o que la dimensión correspondiente, 
entonces la dimensión se trunca previo a la aplicación de la FFT. 
En otro caso, si un elemento de @var{size} es mayor que la dimensión 
correspondiente de @var{a}, se redimensiona y completa con ceros.
@seealso {ifftn, fft, fft2, fftw}
@end deftypefn
