md5="cdc2fa69fe325c50df24a51a1b0e71d2";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} ifft (@var{a}, @var{n}, @var{dim})
Calcular la FFT inversa de @var{a} utilizando subrutinas de @sc{Fftw}.
La FFT inversa se calcula a lo largo de la primera dimensi@'on 
non-singleton de la matriz. As@'i, si @var{a}es una matriz, @code{fft (@var{a})}
calcula la FFT inversa para cada columna de @var{a}.

Si se llama con dos argumentos, @var{n} se espera que sea un entero que
especifica el n@'umero de elementos de @var{a} a utilizar, o una matriz
vac@'ia para especificar que su valor debe ser ignorado. Si @var{n} es 
mayor que la dimensi@'on en la que se calcula la FFT inversa, entonces
@var{a} se cambia el tama@~{n}o y rellena con ceros. De lo contrario,
si @var{n} es menor que la dimensión en la que se calcula la FFT inversa,
entconces @var{a} se trunca.

Si se llama con tres argumentos, @var{dim} es un entero que especifica la
dimensi@'on de la matriz a lo largo de la cual se realiza la FFT inversa
@seealso{fft, ifft2, ifftn, fftw}
@end deftypefn
