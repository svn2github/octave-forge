md5="c46199e477eda0ddf807069b881a6fb5";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} fftn (@var{a}, @var{size})
Calcula la FFT de N dimensiones de @var{a} usando las subrutinas de 
@sc{Fftw}. El vector argumento opcional @var{size} puede ser usado para 
especificar las dimensiones del arreglo que se va a usar. Si un elemento 
de @var{size} es m@'as peque@~{n}o que la dimensi@'on correspondiente, 
entonces la dimensi@'on se trunca previo a la aplicaci@'on de la FFT. 
En otro caso, si un elemento de @var{size} es mayor que la dimensi@'on 
correspondiente de @var{a}, se redimensiona y completa con ceros.
@seealso {ifftn, fft, fft2, fftw}
@end deftypefn
