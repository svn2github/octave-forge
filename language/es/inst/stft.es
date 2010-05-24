md5="850ac1e823d83c78e9e4c8ea203abf73";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{y}, @var{c}] =} stft (@var{x}, @var{win_size}, @var{inc}, @var{num_coef}, @var{w_type})
Calcule a corto plazo la transformada de Fourier del vector @var{x} con
@var{num_coef} mediante la aplicación de coeficientes de una ventana de 
@var{win_size} puntos de datos y un incremento de @var{inc} puntos.

Antes de calcular la transformada de Fourier, una de las siguientes ventanas
se aplica:

@table @asis
@item hanning
w_type = 1
@item hamming
w_type = 2
@item rectangle
w_type = 3
@end table

La ventana de nombres se pueden pasar como cadenas o por el número
@var{w_type} number.

Si no se especifican todos los argumentos, los valores por defecto que
se utilizan son los siguientes:
@var{win_size} = 80, @var{inc} = 24, @var{num_coef} = 64, y
@var{w_type} = 1.

@code{@var{y} = stft (@var{x}, @dots{})} devuelve los valores absolutos
de los coeficientes de Fourier de acuerdo con @var{num_coef} frecuencias
positivas.

@code{[@var{y}, @var{c}] = stft (@code{x}, @dots{})} devuelve toda la 
STFT-matriz @var{y} y un vector de 3-elementos @var{c} que contiene el
tamaño de la ventana, incremento y tipo de ventana, que es necesaria 
por la función de síntesis.
@end deftypefn
