md5="ae85a230a3e07bf490045b1964556b3e";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} barh (@var{x}, @var{y})
@deftypefnx {Archivo de función} {} barh (@var{y})
@deftypefnx {Archivo de función} {} barh (@var{x}, @var{y}, @var{w})
@deftypefnx {Archivo de función} {} barh (@var{x}, @var{y}, @var{w}, @var{style})
@deftypefnx {Archivo de función} {@var{h} =} barh (@dots{}, @var{prop}, @var{val})
@deftypefnx {Archivo de función} {} barh (@var{h}, @dots{})
Produce un gráfico de barras horizontales a partir de dos vectores de datos @var{x}-@var{y}.

Si únicamente un argumento es dado, es tomado como un vector de valores en @var{y} 
y las coordenadas en @var{x} son tomadas de los índices de los elementos.

El ancho predeterminado de 0.8 para las barras puede ser cambiado usando @var{w}.

Si @var{y} es una matriz, entonces cada columna de @var{y} es tomada como un 
gráfico de barras separado y es graficado en la misma gráfica. En forma 
predeterminada, las columnas son graficadas de lado a lado. Este comportamiento 
puede ser alterado mediante el argumento @var{style}, el cual toma los valores 
de @code{"grouped"} (predeterminado) o @code{"stacked"}.

El valor opcional retornado @var{h} provee un apuntador al objeto de tipo patch.
Mientras que la opción de entrada del apuntador @var{h} permite que un apuntador 
de ejes sea pasado. Las propiedades del objeto gráfico patch pueden ser modificadas 
usando las parejas @var{prop} y @var{val}.

@seealso{bar, plot}
@end deftypefn
