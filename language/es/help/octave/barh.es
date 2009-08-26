md5="ae85a230a3e07bf490045b1964556b3e";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} barh (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {} barh (@var{y})
@deftypefnx {Archivo de funci@'on} {} barh (@var{x}, @var{y}, @var{w})
@deftypefnx {Archivo de funci@'on} {} barh (@var{x}, @var{y}, @var{w}, @var{style})
@deftypefnx {Archivo de funci@'on} {@var{h} =} barh (@dots{}, @var{prop}, @var{val})
@deftypefnx {Archivo de funci@'on} {} barh (@var{h}, @dots{})
Produce un gr@'afico de barras horizontales a partir de dos vectores de datos @var{x}-@var{y}.

Si @'unicamente un argumento es dado, es tomado como un vector de valores en @var{y} 
y las coordenadas en @var{x} son tomadas de los @'indices de los elementos.

El ancho predeterminado de 0.8 para las barras puede ser cambiado usando @var{w}.

Si @var{y} es una matriz, entonces cada columna de @var{y} es tomada como un 
gr@'afico de barras separado y es graficado en la misma gr@'afica. En forma 
predeterminada, las columnas son graficadas de lado a lado. Este comportamiento 
puede ser alterado mediante el argumento @var{style}, el cual toma los valores 
de @code{"grouped"} (predeterminado) o @code{"stacked"}.

El valor opcional retornado @var{h} provee un manejador al objeto de tipo patch.
Mientras que la opci@'on de entrada del manejador @var{h} permite que un manejador 
de ejes sea pasado. Las propiedades del objeto gr@'afico patch pueden ser modificadas 
usando las parejas @var{prop} y @var{val}.

@seealso{bar, plot}
@end deftypefn
