md5="3258d723b4d4217e6349e42015cc6860";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} bar (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {} bar (@var{y})
@deftypefnx {Archivo de funci@'on} {} bar (@var{x}, @var{y}, @var{w})
@deftypefnx {Archivo de funci@'on} {} bar (@var{x}, @var{y}, @var{w}, @var{style})
@deftypefnx {Archivo de funci@'on} {@var{h} =} bar (@dots{}, @var{prop}, @var{val})
@deftypefnx {Archivo de funci@'on} {} bar (@var{h}, @dots{})
Produce un gr@'afico de barras a partir de los datos @var{x}-@var{y} de dos vectores.

Si @'unicamente un argumento es dado, es tomado como un vector de valores @var{y},
y las coordenadas @var{x} son tomadas de los @'indices de los elementos.

El ancho predeterminado de 0.8 para las barras puede ser cambiado usando @var{w}.

Si @var{y} es una matriz, entonces cada columna de @var{y} es tomada como un 
gr@'afico de barras separado y es graficado en la misma gr@'afica. En forma 
predeterminada las columnas son graficadas de lado a lado. Este comportamiento 
puede ser cambiado mediante el agumento @var{style}, el cual toma los valores code{"grouped"} 
(predeterminado), o @code{"stacked"}.

El valor retornado opcional @var{h} provee un manejador al objeto de tipo patch.
Mientras que la opci@'on manejador de entrada @var{h} permite que un majenador de ejes sea pasado.
Las propiedades de los objetos gr@'ficos patch pueden ser cambiados usando las parejas
@var{prop}, @var{val}.

@seealso{barh, plot}
@end deftypefn
