md5="217718d89004a1a57c7bdd74224042be";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} fftconv (@var{a}, @var{b}, @var{n})
Retorna la convoluaci@'on de los vectores @var{a} y @var{b}, como un vector 
de longitud igual a @code{length (a) + length (b) - 1}. Si @var{a} 
y @var{b} son los vectores de coeficientes de dos polinomios, el valor 
retornado es el vector de coeficientes del producto polinomial. 

El c@'alculo usa la FFT mediante la funci@'on @code{fftfilt}. Si 
se especifica el argumento opcional @var{n}, se usa una FFT de N puntos.
@end deftypefn
